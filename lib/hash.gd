#############################################################################
##
#W  hash.gd                     GAP library                      Steve Linton
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  Hash tables module, declarations part. 
##
##  The basic idea of the hash tables module is that hash tables are a
##  representation of general mappings. Unlike many representations of
##  mappings they are often mutable (and, indeed only likely to be a sensible
##  choice of representation when mutability is needed)
##
Revision.hash_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsExtensibleGeneralMapping(obj)  category of general mappings (relations) 
##                                     to which new (source, image) pairs can
##                                     be added using AddImage
##
##  We cannot imply IsMutable because Immutable may take it away at any time
##

IsExtensibleGeneralMapping := NewCategory("IsExtensibleGeneralMapping", 
                                      IsGeneralMapping 
                                      and IsFinite 
                                      and IsCopyable);	

#############################################################################
##
#C  IsFlexibleGeneralMapping(obj)  category of general mappings (relations) 
##                                     to which new (source, image) pairs can
##                                     be added using AddImage and from which
##                                     they can be deleted using DeleteImage 
##

IsFlexibleGeneralMapping := NewCategory("IsFlexibleGeneralMapping",
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

AddImage := NewOperation("AddImage", 
                    [ IsExtensibleGeneralMapping and IsMutable, 
                      IsObject, IsObject ]);

#############################################################################
##
#O  AddImageNC( <map>, <srcpt>, <im> )  add a new pair to an extensible 
##                                         general mapping  without checks
##
##  This makes two assumptions -- firstly that <srcpt> and <im> are in the 
##  source and  range of the map, and secondly that if <map> is required to
##  be single-valued then <srcpt> currently has no images under <map>

AddImageNC := NewOperation("AddImageNC", 
                      [ IsExtensibleGeneralMapping and IsMutable, 
                        IsObject, IsObject ]);

#############################################################################
##
#O  SetImage( <map>, <srcpt>, <im> )  set the image of <srcpt> under the 
##                                     extensible single-valued mapping <map>
##
##

SetImage := NewOperation("SetImage", 
                    [ IsExtensiblePartialMapping and IsMutable, 
                      IsObject, IsObject ]);

#############################################################################
##
#O  SetImageNC( <map>, <srcpt>, <im> )  set the image of <srcpt> under the 
##                                     extensible single-valued mapping <map>
##
##  This assumes that <srcpt> and <im> are in the source and range 
##  respectively

SetImage := NewOperation("SetImage", 
                    [ IsExtensiblePartialMapping and IsMutable, 
                      IsObject, IsObject ]);

#############################################################################
##
#O  DeleteImage( <map>, <srcpt>, <im> )         remove a pair from a flexible 
##                                                          general mapping
##
##  Raises an error if the pair is not present
##

DeleteImage := NewOperation("DeleteImage",  
                       [ IsFlexibleGeneralMapping and IsMutable, 
                         IsObject, IsObject ]);

#############################################################################
##
#O  UnSetImage( <map>, <srcpt> )      unbind the image of <srcpt> under a 
##                                          flexible single-values mapping
##

UnSetImage := NewOperation("UnSetImage", 
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
  
HashTable := NewOperation("HashTable", [IsCollection, IsCollection, IsFunction]);

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

ShrinkableHashTable := NewOperation("ShrinkableHashTable", 
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

SingleValuedHashTable := NewOperation("SingleValuedHashTable", 
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

ShrinkableSingleValuedHashTable := NewOperation("ShrinkableSingleValuedHashTable", 
                               [IsCollection, IsCollection, IsFunction]);


#############################################################################
##
#E  hash.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



