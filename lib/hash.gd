#############################################################################
##
#W  hash.gd                     GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Hash tables module, declarations part. 
##
##  The basic idea of the hash tables module is that hash tables are a
##  representation of general mappings. Unlike many representations of
##  mappings they are often mutable (and, indeed only likely to be a sensible
##  choice of representation when mutability is needed)
##


#############################################################################
##
#C  IsExtensibleGeneralMapping(obj)  category of general mappings (relations) 
##                                     to which new (source, image) pairs can
##                                     be added using AddImage
##
##  We cannot imply IsMutable because Immutable may take it away at any time
##

DeclareCategory("IsExtensibleGeneralMapping", 
                                      IsNonSPGeneralMapping 
                                      and IsFinite 
                                      and IsCopyable);	

#############################################################################
##
#C  IsFlexibleGeneralMapping(obj)  category of general mappings (relations) 
##                                     to which new (source, image) pairs can
##                                     be added using AddImage and from which
##                                     they can be deleted using DeleteImage 
##

DeclareCategory("IsFlexibleGeneralMapping",
                                               IsExtensibleGeneralMapping);

#############################################################################
##
#C  IsExtensiblePartialMapping                 single-valued mutable mappings
#C  IsFlexiblePartialMapping
##
##  AddImage may signal an error for these mappings if an image is already 
##  present. SetImage will over-ride an existing image
##

IsExtensiblePartialMapping := IsExtensibleGeneralMapping and IsSingleValued;

IsFlexiblePartialMapping := IsFlexibleGeneralMapping and IsSingleValued;

#############################################################################
##
#O  AddImage( <map>, <srcpt>, <im> )  add a new pair to an extensible 
##                                         general mapping  
##
##  This should signal an error if the mapping is single-valued 
##  by representation and <srcpt> has an image already
##

DeclareOperation("AddImage", 
                    [ IsExtensibleGeneralMapping and IsMutable, 
                      IsObject, IsObject ]);

#############################################################################
##
#O  AddImageNC( <map>, <srcpt>, <im> )  add a new pair to an extensible 
##                                         general mapping  without checks
##
##  This makes two assumptions.
##  Firstly that <srcpt> and <im> are in the 
##  source and  range of the map, and secondly that if <map> is required to
##  be single-valued then <srcpt> currently has no images under <map>.
##
DeclareOperation("AddImageNC", 
                      [ IsExtensibleGeneralMapping and IsMutable, 
                        IsObject, IsObject ]);

#############################################################################
##
#O  SetImage( <map>, <srcpt>, <im> )  set the image of <srcpt> under the 
##                                     extensible single-valued mapping <map>
##
##  This assumes that <srcpt> and <im> are in the source and range 
##  respectively
DeclareOperation("SetImage", 
                    [ IsExtensiblePartialMapping and IsMutable, 
                      IsObject, IsObject ]);

#############################################################################
##
#O  DeleteImage( <map>, <srcpt>, <im> )         remove a pair from a flexible 
##                                                          general mapping
##
##  Raises an error if the pair is not present
##
DeclareOperation("DeleteImage",  
                       [ IsFlexibleGeneralMapping and IsMutable, 
                         IsObject, IsObject ]);

#############################################################################
##
#O  UnSetImage( <map>, <srcpt> )      unbind the image of <srcpt> under a 
##                                          flexible single-values mapping
##

DeclareOperation("UnSetImage", 
                      [IsFlexiblePartialMapping and IsMutable, IsObject]);

#############################################################################
##
#O  HashTable( <source>, <range>, <hash-function> )   create a hash table
##
##  These hash tables are extensible, but not necessarily flexible general
##  mappings. See the other constructors for other possibilities
##  
##  They are created empty. 
##
##  The hash function must be a one argument function that takes an object of
##  the family of the elements of <source> and returns either fail, implying that
##  the argument was not in source, or an integer which will be used for hashing.
##
##  It is the decision of the supplier of <hash-function> 
##  whether to test for membership in 
##  <source> in <hash-function>, to hash every element of the family, or to 
##  take care never to pass a point not in <source>
##
##  Methods for  AddImage will normally test for membership in the <range>. 
##  Those for AddImageNC will not. The user may additionally wish to enlarge 
##  the range to a domain with a faster membership test.
##
#T  Supply a selection of general-purpose hash functions
##
  
DeclareOperation("HashTable", [IsCollection, IsCollection, IsFunction]);

#############################################################################
##
#O  ShrinkableHashTable( <source>, <range>, <hash-function> )
##                                             create a shrinkable hash table
##
##  These hash tables are flexible  general
##  mappings. See the other constructors for other possibilities
##
##  See HashTable for the specification of the arguments
##

DeclareOperation("ShrinkableHashTable", 
                               [IsCollection, IsCollection, IsFunction]);

#############################################################################
##
#O  SingleValuesHashTable( <source>, <range>, <hash-function> )
##                                          create a single-valued hash table
##
##  These hash tables are extensible  partial
##  mappings. See the other constructors for other possibilities
##
##  See HashTable for the specification of the arguments
##

DeclareOperation("SingleValuedHashTable", 
                               [IsCollection, IsCollection, IsFunction]);

#############################################################################
##
#O  ShrinkableSingleValuesHashTable( <source>, <range>, <hash-function> )
##                               create a shrinkable single-valued hash table
##
##  These hash tables are flexible  partial
##  mappings. See the other constructors for other possibilities
##
##  See HashTable for the specification of the arguments
##

DeclareOperation("ShrinkableSingleValuedHashTable", 
                               [IsCollection, IsCollection, IsFunction]);

#############################################################################
##
#F  HashKeyBag(<obj>,<factor>,<skip>,<maxread>)
##
##  returns a hash key which is given by the bytes in the bag storing <obj>
##  in <factor>-adic representation. The result is reduced modulo $2^{28}$
##  to obtain a small integer.
##  As some objects carry excess data in their bag, the first <skip> bytes
##  will be skipped and <maxread> bytes (a value of -1 represents infinity)
##  will be read at most. (The proper values for these numbers might depend on
##  the internal representation used as well as on the word length of the
##  machine on which {\GAP} is running and care has to be taken when using
##  `HashKeyBag' to ensure identical key values for equal objects.)
##
##  The values returned by `HashKeyBag' are not guaranteed to be portable
##  between different runs of {\GAP} and no reference to their absolute
##  values ought to be made.
##
BindGlobal("HashKeyBag",HASHKEY_BAG);


#############################################################################
##
#E  hash.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



