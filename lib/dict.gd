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
##  This file contains the declarations for dictionaries and for improved
##  hash tables.
##
##  In the hash tables, we hash by keys and also store a value.  Keys
##  cannot be removed from the table, but the corresponding value can be
##  changed.  Fast access to last hash index allows you to efficiently store
##  more than one array of values -- this facility should be used with care.
##
##  This code works for any kind of object, provided you have a KeyIntDense
##  method to convert the key into a positive integer.
##  This method should ideally be implemented efficiently in the core.
##
##  Note that, for efficiency, it is currently impossible to create a
##  hash table with non-positive integers.
##
##  Requires: nothing
##  Exports:
##      Category IsHash.
##      Representations IsDenseHashRep and IsSparseHashRep.
##      Operations PrintHashWithNames, Iterator, GetHashEntry, AddHashEntry,
##        GetHashEntryAtLastIndex, SetHashEntryAtLastIndex, SetHashEntry,
##        [AddHashEntryAtLastIndex], HashFunct, KeyIntDense.
##      Functions DenseHash, SparseHash.
##      Variables MaxViewSize, LastHashIndex.
##

#############################################################################
##
#I  InfoHash
##
DeclareInfoClass( "InfoHash" );


#############################################################################
##
#C  IsDictionary(<obj>)
##
##  <#GAPDoc Label="IsDictionary">
##  <ManSection>
##  <Filt Name="IsDictionary" Arg='obj' Type='Category'/>
##
##  <Description>
##  A dictionary is a growable collection of objects that permits to add
##  objects (with associated values) and to check whether an object is
##  already known.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsDictionary",IsCollection);

#############################################################################
##
#C  IsLookupDictionary(<obj>)
##
##  <#GAPDoc Label="IsLookupDictionary">
##  <ManSection>
##  <Filt Name="IsLookupDictionary" Arg='obj' Type='Category'/>
##
##  <Description>
##  A <E>lookup dictionary</E> is a dictionary, which permits not only to check
##  whether an object is contained, but also to retrieve associated values,
##  using the operation <Ref Oper="LookupDictionary"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsLookupDictionary",IsDictionary);

#############################################################################
##
#C  IsHash(<obj>)
##
##  <ManSection>
##  <Filt Name="IsHash" Arg='obj' Type='Category'/>
##
##  <Description>
##  The category of hash tables for arbitrary objects (provided an <C>IntKey</C>
##  function
##  is defined).
##  </Description>
##  </ManSection>
##
DeclareCategory( "IsHash", IsLookupDictionary );

#############################################################################
##
##  <#GAPDoc Label="[1]{dict}">
##  There are several ways how dictionaries are implemented: As lists, as
##  sorted lists, as hash tables or via binary lists. A user however will
##  just have to call <Ref Func="NewDictionary"/> and obtain a <Q>suitable</Q> dictionary
##  for the kind of objects she wants to create. It is possible however to
##  create hash tables (see&nbsp;<Ref Sect="General Hash Tables"/>)
##  and dictionaries using binary lists (see&nbsp;<Ref Func="DictionaryByPosition"/>).
##  <P/>
##  <#/GAPDoc>
##

#############################################################################
##
#F  NewDictionary(<obj>,<look>[,<objcoll>])
##
##  <#GAPDoc Label="NewDictionary">
##  <ManSection>
##  <Func Name="NewDictionary" Arg='obj,look[,objcoll]'/>
##
##  <Description>
##  creates a new dictionary for objects such as <A>obj</A>. If <A>objcoll</A> is
##  given the dictionary will be for objects only from this collection,
##  knowing this can improve the performance. If <A>objcoll</A> is given, <A>obj</A>
##  may be replaced by <K>false</K>, i.e. no sample object is needed.
##  <P/>
##  The function tries to find the right kind of dictionary for the basic
##  dictionary functions to be quick.
##  If <A>look</A> is <K>true</K>, the dictionary will be a lookup dictionary,
##  otherwise it is an ordinary dictionary.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("NewDictionary");

#############################################################################
##
##  <#GAPDoc Label="[2]{dict}">
##  The use of two objects, <A>obj</A> and <A>objcoll</A> to parametrize the objects a
##  dictionary is able to store might look confusing. However there are
##  situations where either of them might be needed:
##  <P/>
##  The first situation is that of objects, for which no formal <Q>collection
##  object</Q> has been defined. A typical example here might be subspaces of
##  a vector space. &GAP; does not formally define a <Q>Grassmannian</Q> or
##  anything else to represent the multitude of all subspaces. So it is only
##  possible to give the dictionary a <Q>sample object</Q>.
##  <P/>
##  The other situation is that of an object which might represent quite
##  varied domains. The permutation <M>(1,10^6)</M> might be the nontrivial
##  element of a cyclic group of order 2, it might be a representative of
##  <M>S_{{10^6}}</M>.
##  In the first situation the best approach might be just to
##  have two entries for the two possible objects, in the second situation a
##  much more elaborate approach might be needed.
##  <P/>
##  An algorithm that creates a dictionary will usually know a priori, from what
##  domain all the objects will be, giving this domain permits to use a more
##  efficient dictionary.
##  <P/>
##  This is particularly true for vectors. From a single vector one cannot
##  decide whether a calculation will take place over the smallest field
##  containing all its entries or over a larger field.
##  <#/GAPDoc>
##


#############################################################################
##
#F  DictionaryByPosition(<list>,<lookup>)
##
##  <#GAPDoc Label="DictionaryByPosition">
##  <ManSection>
##  <Func Name="DictionaryByPosition" Arg='list,lookup'/>
##
##  <Description>
##  creates a new (lookup) dictionary which uses
##  <Ref Oper="PositionCanonical"/> in <A>list</A> for indexing.
##  The dictionary will have an entry <A>dict</A><C>!.blist</C>
##  which is a bit list corresponding to <A>list</A> indicating the known
##  values.
##  If <A>look</A> is <K>true</K>,
##  the dictionary will be a lookup dictionary,
##  otherwise it is an ordinary dictionary.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DictionaryByPosition");

#############################################################################
##
#V  DictionariesFamily
##
##  <ManSection>
##  <Var Name="DictionariesFamily"/>
##
##  <Description>
##  Is the family of all dictionaries.
##  </Description>
##  </ManSection>
##
BindGlobal("DictionariesFamily",NewFamily( "DictionariesFamily",IsDictionary));

#############################################################################
##
#O  KnowsDictionary(<dict>,<key>)
##
##  <#GAPDoc Label="KnowsDictionary">
##  <ManSection>
##  <Oper Name="KnowsDictionary" Arg='dict,key'/>
##
##  <Description>
##  checks, whether <A>key</A> is known to the dictionary <A>dict</A>,
##  and returns <K>true</K> or <K>false</K> accordingly.
##  <A>key</A> <E>must</E> be an object of the kind for
##  which the dictionary was specified, otherwise the results are
##  unpredictable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("KnowsDictionary",[IsDictionary,IsObject]);

#############################################################################
##
#O  AddDictionary(<dict>,<key>)
#O  AddDictionary(<dict>,<key>,<val>)
##
##  <#GAPDoc Label="AddDictionary">
##  <ManSection>
##  <Oper Name="AddDictionary" Arg='dict,key[,val]'/>
##
##  <Description>
##  adds <A>key</A> to the dictionary <A>dict</A>, storing the associated
##  value <A>val</A> in case <A>dict</A> is a lookup dictionary.
##  If <A>key</A> is not an object of the kind for
##  which the dictionary was specified, or if <A>key</A> is known already to
##  <A>dict</A>, the results are unpredictable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("AddDictionary",[IsDictionary and IsMutable, IsObject]);
DeclareOperation("AddDictionary",[IsDictionary and IsMutable, IsObject,IsObject]);
DeclareSynonym("AddHashEntry",AddDictionary);

#############################################################################
##
#O  RemoveDictionary( <dict>, <key> )
##
##  <ManSection>
##  <Oper Name="RemoveDictionary" Arg='key'/>
##
##  <Description>
##  Removes the given key and its associated value from the dictionary.
##  </Description>
##  </ManSection>
##
DeclareOperation( "RemoveDictionary", [ IsDictionary and IsMutable, IsObject ] );


#############################################################################
##
#O  LookupDictionary(<dict>,<key>)
##
##  <#GAPDoc Label="LookupDictionary">
##  <ManSection>
##  <Oper Name="LookupDictionary" Arg='dict,key'/>
##
##  <Description>
##  looks up <A>key</A> in the lookup dictionary <A>dict</A> and returns the
##  associated value.
##  If <A>key</A> is not known to the dictionary, <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("LookupDictionary",[IsDictionary,IsObject]);

DeclareSynonym("GetHashEntry",LookupDictionary);

DeclareRepresentation("IsDictionaryDefaultRep",
  IsDictionary and IsNonAtomicComponentObjectRep,[]);

#############################################################################
##
#R  IsListDictionary(<obj>)
#R  IsListLookupDictionary(<obj>)
##
##  <ManSection>
##  <Filt Name="IsListDictionary" Arg='obj' Type='Representation'/>
##  <Filt Name="IsListLookupDictionary" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A list dictionary uses a simple (unsorted) list and searching internally.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsListDictionary",IsDictionaryDefaultRep,
  ["entries"] );
DeclareRepresentation("IsListLookupDictionary",
  IsListDictionary and IsLookupDictionary,
  ["entries"] );

#############################################################################
##
#O  ListKeyEnumerator( <dict> )
##
##  <ManSection>
##  <Oper Name="ListKeyEnumerator" Arg='dict'/>
##
##  <Description>
##  Enumerates the keys of the list dictionary (Enumerator enumerates values).
##  </Description>
##  </ManSection>
##
DeclareOperation( "ListKeyEnumerator", [ IsListDictionary ] );

#############################################################################
##
#R  IsSortDictionary(<obj>)
#R  IsSortLookupDictionary(<obj>)
##
##  <ManSection>
##  <Filt Name="IsSortDictionary" Arg='obj' Type='Representation'/>
##  <Filt Name="IsSortLookupDictionary" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A sort dictionary uses a sorted list internally.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsSortDictionary",IsListDictionary,
  ["entries"] );
DeclareRepresentation("IsSortLookupDictionary",
  IsSortDictionary and IsListLookupDictionary and IsLookupDictionary,
  ["entries"] );

#############################################################################
##
#R  IsPositionDictionary(<obj>)
#R  IsPositionLookupDictionary(<obj>)
##
##  <ManSection>
##  <Filt Name="IsPositionDictionary" Arg='obj' Type='Representation'/>
##  <Filt Name="IsPositionLookupDictionary" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A hash dictionary uses <Ref Oper="PositionCanonical"/> in a list
##  internally.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsPositionDictionary",
  IsDictionaryDefaultRep,["domain","blist"] );
DeclareRepresentation("IsPositionLookupDictionary",
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
##  <ManSection>
##  <Oper Name="PrintHashWithNames" Arg='hash, keyName, valueName'/>
##
##  <Description>
##  Print a hash table with the given names for the keys and values.
##  </Description>
##  </ManSection>
##
DeclareOperation( "PrintHashWithNames", [ IsHash, IsString, IsString ] );

#############################################################################
##
#O  RandomHashKey( <hash> )
##
##  <ManSection>
##  <Oper Name="RandomHashKey" Arg='hash'/>
##
##  <Description>
##  Return a random Key from the hash table (Random returns a random value).
##  </Description>
##  </ManSection>
##
DeclareOperation( "RandomHashKey", [ IsHash ] );

#############################################################################
##
#O  HashKeyEnumerator( <hash> )
##
##  <ManSection>
##  <Oper Name="HashKeyEnumerator" Arg='hash'/>
##
##  <Description>
##  Enumerates the keys of the hash table (Enumerator enumerates values).
##  </Description>
##  </ManSection>
##
DeclareOperation( "HashKeyEnumerator", [ IsHash ] );

#############################################################################
##
#P  TableHasIntKeyFun(<hash>)
##
##  <ManSection>
##  <Prop Name="TableHasIntKeyFun" Arg='hash'/>
##
##  <Description>
##  If this filter is set, the hash table has an <C>IntKey</C> function in its
##  component <A>hash</A><C>!.intKeyFun</C>.
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Filt Name="IsDenseHashRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  The dense representation for hash tables.
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="DenseHashTable">
##  <ManSection>
##  <Func Name="DenseHashTable" Arg=''/>
##
##  <Description>
##  Construct an empty dense hash table.  This is the only correct way to
##  construct such a table.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DenseHashTable" );


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
##  <ManSection>
##  <Filt Name="IsSparseHashRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  The sparse representation for hash tables.
##  </Description>
##  </ManSection>
##
DeclareRepresentation( "IsSparseHashRep",
    # as we will call `Enumerator' to get the *current* value list, a hash
    # table may not be attribute storing.
    IsNonAtomicComponentObjectRep and IsHash,
    ["KeyArray", "ValueArray", "HashFunct", "LengthArray",
     "LengthArrayHalf", # so we dont need to *2 to see overflow
     "NumberKeys"] );

BindGlobal("DefaultSparseHashRepType",
  NewType( DictionariesFamily, IsSparseHashRep and IsMutable and IsCopyable ));

BindGlobal("DefaultSparseHashWithIKRepType",
        NewType( DictionariesFamily, IsSparseHashRep and TableHasIntKeyFun
                and IsMutable and IsCopyable));

#############################################################################
##
#F  SparseHashTable([<intkeyfun>[,<startlength>])
##
##  <#GAPDoc Label="SparseHashTable">
##  <ManSection>
##  <Func Name="SparseHashTable" Arg='[intkeyfun[,startlength]]'/>
##
##  <Description>
##  Construct an empty sparse hash table.  This is the only correct way to
##  construct such a table.
##  If the argument <A>intkeyfun</A> is given, this function will be used to
##  obtain numbers for the keys passed to it.
##  If also <A>startlength</A> is given, the hash table will be initialized
##  at that size.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "SparseHashTable" );

#############################################################################
##
#F  DoubleHashArraySize( <hash> )
##
##  <#GAPDoc Label="DoubleHashArraySize">
##  <ManSection>
##  <Func Name="DoubleHashArraySize" Arg='hash'/>
##
##  <Description>
##  Double the size of the hash array and rehash all the entries.
##  This will also happen automatically when the hash array is half full.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "DoubleHashDictSize" );
DeclareSynonym("DoubleHashArraySize", DoubleHashDictSize);

# almost duplicate without any extras - thus faster

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
##  <#GAPDoc Label="IntegerHashFunction">
##  <ManSection>
##  <Func Name="IntegerHashFunction" Arg='key, i, size'/>
##
##  <Description>
##  This will be a good double hashing function for any reasonable
##  <C>KeyInt</C> (see <Cite Key="CLR90" Where="p.235"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "IntegerHashFunction" );
DeclareSynonym( "HashFunct", IntegerHashFunction);

#############################################################################
##
#O  DenseIntKey(<objcoll>,<obj>)
##
##  <#GAPDoc Label="DenseIntKey">
##  <ManSection>
##  <Oper Name="DenseIntKey" Arg='objcoll,obj'/>
##
##  <Description>
##  returns a function that can be used as hash key function for objects
##  such as <A>obj</A> in the collection <A>objcoll</A>.
##  Typically, <A>objcoll</A> will be a large domain.
##  If the domain is not available, it can be given as
##  <K>false</K> in which case the hash key function will be determined only
##  based on <A>obj</A>. (For a further discussion of these two arguments
##  see&nbsp;<Ref Func="NewDictionary"/>).
##  <P/>
##  The function returned by <Ref Oper="DenseIntKey"/> is guaranteed to give different
##  values for different objects.
##  If no suitable hash key function has been predefined, <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("DenseIntKey",[IsObject,IsObject]);

#############################################################################
##
#O  SparseIntKey(<objcoll>,<obj>)
##
##  <#GAPDoc Label="SparseIntKey">
##  <ManSection>
##  <Oper Name="SparseIntKey" Arg='objcoll,obj'/>
##
##  <Description>
##  returns a function that can be used as hash key function for objects
##  such as <A>obj</A> in the collection <A>objcoll</A>.
##  In contrast to <Ref Oper="DenseIntKey"/>,
##  the function returned may return the same key value for different
##  objects.
##  If no suitable hash key function has been predefined,
##  <K>fail</K> is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
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
##  <ManSection>
##  <Oper Name="GetHashEntryAtLastIndex" Arg='hash'/>
##
##  <Description>
##  Returns the value of the last hash entry accessed.
##  </Description>
##  </ManSection>
##
DeclareOperation( "GetHashEntryAtLastIndex", [ IsHash ] );

#############################################################################
##
#O  SetHashEntryAtLastIndex( <hash>, <newValue> )
##
##  <ManSection>
##  <Oper Name="SetHashEntryAtLastIndex" Arg='hash, newValue'/>
##
##  <Description>
##  Resets the value of the last hash entry accessed.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SetHashEntryAtLastIndex", [ IsHash and IsMutable, IsObject ] );

#############################################################################
##
#O  SetHashEntry( <hash>, <key>, <value> )
##
##  <ManSection>
##  <Oper Name="SetHashEntry" Arg='hash, key, value'/>
##
##  <Description>
##  Resets the value corresponding to <A>key</A>.
##  </Description>
##  </ManSection>
##
DeclareOperation( "SetHashEntry", [ IsHash and IsMutable, IsObject, IsObject ] );

#############################################################################
##
##  AddHashEntryAtLastIndex( <hash>, <value> )
##
##  Check first if the last index has been set, and don't reset it if it has.
##  This operation has not yet been implemented
##
##DeclareOperation( "AddHashEntryAtLastIndex", [ IsHash and IsMutable, IsObject ] );
