#############################################################################
##
#W  hash.gi                     GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Hash tables module, implementation part. 
##


#############################################################################
##
#I   InfoHashTables . . . . . . . . . . . . . . . . . . . . . . . . InfoClass
##

DeclareInfoClass("InfoHashTables");



#############################################################################
##
##   Part 1   Generic Methods for constructors
##
##   Not much here because there is no ExtRep. Most generic methods would 
##   come from mappings anyway
##
#N   Should there be an ExtRep for finite mappings?
##

#############################################################################
##
#M  HashTable( <source>, <range>, <hash-function> )
##
##     fall back on making a shrinkable hash table if we don't know how to
##     make a non-shrinkable one
##


InstallMethod( HashTable, true, [IsCollection, IsCollection, IsFunction], -1,
        function(source, range, hash)
    return ShrinkableHashTable(source, range, hash);
end);

#############################################################################
##
#M  SingleValuedHashTable( <source>, <range>, <hash-function> )
##
##     fall back on making a shrinkable hash table if we don't know how to
##     make a non-shrinkable one
##


InstallMethod( SingleValuedHashTable, true, 
        [IsCollection, IsCollection, IsFunction], -1,
        function(source, range, hash)
    return ShrinkableSingleValuedHashTable(source, range, hash);
end);


#############################################################################
##
##  Part 2 generic methods for all hash table representations
##
##  All representations have a few basic features in common, like the
##  source and range components. We install a few methods based on this
##

#############################################################################
##
#R  IsHashTable(obj)                                       The representation
##
##
##  note that we do NOT inherit from IsAttributeStoringRep, as hash tables are
##  usually mutable
##
##  All of the components should be pretty obvious. "entries" is used to hold 
##  a count of the size of the PreImageRange of the mapping, ie the number of
##  points with one or more images
##
##  The structure and interpretation of table is representation dependent
##

DeclareRepresentation("IsHashTable",
    IsComponentObjectRep, 
    [ "source", "range", "hashFunc", "entries", "table" ]);


#############################################################################
##
#M Source( <ht> )                                      source of a hash table
##

InstallMethod(Source, true, [IsHashTable and IsGeneralMapping], 
        0, ht->ht!.source);
          
#############################################################################
##
#M Range( <ht> )                                        range of a hash table
##

InstallMethod(Range, true, [IsHashTable and IsGeneralMapping], 
        0, ht->ht!.range);
          

#############################################################################
##
#M  ViewObj( <ht> )                                          printing methods
##
#N  Is there a nicer way of installing a method for immutable objects only?
##

InstallMethod( ViewObj,
    "for mutable flexible hash table",
    true, 
        [IsHashTable and IsFlexibleGeneralMapping and IsMutable], 0,
        function(ht)
    Print("<<flexible hash table -- ",ht!.entries," entries>>");
end);
    
InstallMethod( ViewObj,
    "for mutable extensible hash table",
    true, 
        [IsHashTable and IsExtensibleGeneralMapping and IsMutable], 0,
        function(ht)
    Print("<<extensible hash table -- ",ht!.entries," entries>>");
end);
    
InstallMethod( ViewObj,
    "for immutable hash table",
    true, [IsHashTable and IsGeneralMapping], 0,
        function(ht)
    if not IsMutable(ht) then
        Print("<<immutable hash table -- ",ht!.entries," entries>>");
    else
        TryNextMethod();
    fi;
end);


#############################################################################
##
#M  PrintObj( <ht> )                                         printing methods
##
#N  Is there a nicer way of installing a method for immutable objects only?
##

InstallMethod( PrintObj,
    "for a hash table",
    true, 
    [ IsHashTable ], 0,
    function(ht)
    Print( "HashTable( ", ht!.source, ", ", ht!.range, ", ",
           ht!.hashFunc, " )" );
    end);
#T how to print a function call that constructs an isomorphic hash table?


#############################################################################
##
##   Part 3   ListHashTables
##
##   A list hashtable is (basically) a list indexed by hash values of lists 
##   of lists. For each hash value there is a list of zero or more entries,
##   alternating objects and sets of images:
##  
##   The whole table grows and shrinks dynamically,  as needed
##


#############################################################################
##
#V  ListHashParams                    control parameters for hashtable growth
##
##  ListHashParams.BASIC_HASH_RANGE   is the starting size of list hashtables
##                                    tables will not shrink to become smaller
##                                    than this
##  ListHashParams.HASH_GROW_MARGIN   the hash table will grow to ensure that 
##                                    the number of hash buckets always exceeds
##                                    the number of entries by this factor
##  ListHashParams.HASH_GROW_FACTOR   the hash table will grow by this multiple
##                                    when it grows
##  ListHashParams.HASH_SHRINK_MARGIN if the number of entries times this factor 
##                                    is less than the number of hash buckets
##                                    then the table will shrink
##  ListHashParams.HASH_SHRINK_FACTOR by this factor
##
#T  tune these for reasonable performance
##

ListHashParams := rec(
                      BASIC_HASH_RANGE := 16,
                      HASH_GROW_MARGIN := 5/4,
                      HASH_GROW_FACTOR := 3/2,
                      HASH_SHRINK_MARGIN := 3,
                      HASH_SHRINK_FACTOR := 2);

#############################################################################
##
#R  IsListHashTable(obj)                                   The representation
##
##
##

DeclareRepresentation("IsListHashTable", IsHashTable, []);

#############################################################################
##
#M  ShrinkableHashTable( <source>, <range>, <hash-function> )
##                                              make an empty list hash table
##
##  Note that we make the hash table expressly mutable by setting 
##  IsMutable. See the declarations file for comments of choice
##  of <source> and <range> and obligations of <hash-function>.
##


InstallMethod(ShrinkableHashTable,
    true,
    [IsCollection, IsCollection, IsFunction], 0,
        function(source, range, hash)
    local sourcefam, rangefam;
    sourcefam := ElementsFamily(FamilyObj(source));
    rangefam := ElementsFamily(FamilyObj(source));
    Info(InfoHashTables, 1, "Creating a list hash table");
    Info(InfoHashTables, 2, "Source: ", source, " Range: ",range);
    return Objectify(NewType(GeneralMappingsFamily(sourcefam, rangefam), 
                   IsFlexibleGeneralMapping and IsListHashTable and
                   HasSource and HasRange and IsMutable),
                   rec(
                       source := Immutable(source),
                       range := Immutable(range),
                       hashFunc := Immutable(hash),
                       entries := 0,
                       table := List([1..ListHashParams.BASIC_HASH_RANGE], 
                               x->[])));
end);

#############################################################################
##
#F  ResizeListHashTable( <ht>, <newsize> ) local    Adjust size of hash table
##                                                
##


ResizeListHashTable := function( ht, newsize)
    local newtable  # new hash table under construction
          , list    # hash table entry being transferred
          , datapos # index into list
          , newlist # new hash table netry to add to
          , key;    # key of entry being transferred
    
    Info(InfoHashTables,2,
         "Resizing list hash table from ",
         Length(ht!.table),
         " to ",
         newsize);
    newtable := List([1..newsize],x->[]);
    for list in ht!.table do
        for datapos in [1,3..Length(list)-1] do
            key := list[datapos];
            newlist := newtable[1 + ht!.hashFunc(key) mod newsize];
            Add(newlist, key);
            Add(newlist, list[datapos+1]);
        od;
    od;
    ht!.table := newtable;
end;

#############################################################################
##
#M  ImagesElm( <ht>, <obj> )                                  look up a point
##


InstallMethod(ImagesElm, 
        FamSourceEqFamElm,
        [ IsListHashTable and IsFlexibleGeneralMapping, IsObject], 
        0,
        function(ht, obj)
    local h             # hash value of object 
          ,list         # all entries in that hash bucket
          ,datapos;     # index into list
    
    Info(InfoHashTables,3,"Looking up ",obj," in hash table");
    h := ht!.hashFunc(obj);
    if h = fail then 
        return fail;
    fi;
    list := ht!.table[1 + h mod Length(ht!.table)];
    for datapos  in [ 1,3..Length(list)-1 ]  do
        if list[datapos] = obj then
            Info(InfoHashTables,3,"Found ",list[datapos+1]);
            return Immutable(list[datapos+1]);
        fi;
    od;
    Info(InfoHashTables,3,"Found no images");
    return Immutable([]);
end);

#############################################################################
##
#M  AddImage( <ht>, <pt>, <im> )    add an image to a mutable list hash table
##
##
##

InstallMethod(AddImage, FamMapFamSourceFamRange,
  [ IsListHashTable and IsExtensibleGeneralMapping and IsMutable, 
    IsObject, IsObject], 0,
  function(ht, obj, val)
    local h,list, entrypos;
    Info(InfoHashTables,3,"Adding ", obj, "->", val, " to list hash table");
    h := ht!.hashFunc(obj);
    if h = fail then
        Error("Object not in source");
    fi;
    if not val in ht!.range then
        Error("Image not in range");
    fi;
    list := ht!.table[1 +  h mod Length(ht!.table)];
    for entrypos in [1,3..Length(list)-1] do
        if list[entrypos] = obj then
            if val in list[entrypos+1] then
                return ht;
            fi;    
            AddSet(list[entrypos+1], Immutable(val));
            return ht;
        fi;
    od;
    ht!.entries := ht!.entries+1;
    if Length(ht!.table) < ht!.entries * ListHashParams.HASH_GROW_MARGIN then
        ResizeListHashTable(ht, 
                1+Int(Length(ht!.table)*ListHashParams.HASH_GROW_FACTOR));
        list :=  ht!.table[1 +  h mod Length(ht!.table)];
    fi;
    Add(list, Immutable(obj));
    Add(list, [Immutable(val)]);
    return ht;
end);

#############################################################################
##
#M  AddImageNC( <ht>, <pt>, <im> )                  add an image non-checking
##

InstallMethod(AddImageNC, FamMapFamSourceFamRange,
  [ IsList and IsExtensibleGeneralMapping and IsMutable, 
    IsObject, IsObject], 0,
  function(ht, obj, val)
    local h,list, entrypos;
    Info(InfoHashTables,3,"Adding ", obj, "->", val, " to list hash table");
    h := ht!.hashFunc(obj);
    Assert(2, h <> fail);
    Assert(2, val in ht!.range);
    list := ht!.table[1 +  h mod Length(ht!.table)];
    for entrypos in [1,3..Length(list)-1] do
        if list[entrypos] = obj then
            AddSet(list[entrypos+1], Immutable(val));
            return ht;
        fi;
    od;
    ht!.entries := ht!.entries+1;
    if Length(ht!.table) < ht!.entries * ListHashParams.HASH_GROW_MARGIN then
        ResizeListHashTable(ht, 
                1+Int(Length(ht!.table)*ListHashParams.HASH_GROW_FACTOR));
        list :=  ht!.table[1 +  h mod Length(ht!.table)];
    fi;
    Add(list, Immutable(obj));
    Add(list, [Immutable(val)]);
    return ht;
end);

#############################################################################
##
#M  DeleteImage( <ht>, <pt>, <im> )                           delete an image
##

InstallMethod(DeleteImage, FamMapFamSourceFamRange,
  [ IsListHashTable and IsFlexibleGeneralMapping and IsMutable, 
    IsObject, IsObject], 0,
  
  function(ht, obj, val)
    local h         # hash value of obj
          ,list     # bucket for that hash value
          ,entrypos # index into list
          ,entry    # all images of obj
          ,pos      # position of val in entry
          ,i        # local loop counter
          ,newsize; # size to shrink to if necessary
    
    Info(InfoHashTables,3,"Deleting ", obj, "->", val, "from hash table");
    h := ht!.hashFunc(obj);
    if h = fail then
        Error("Object not in source");
    fi;
    list := ht!.table[1 +  h mod Length(ht!.table)];
    
    # list has alternating points and lists of images
    # we look for obj in one of the odd positions
    
    for entrypos in [1,3..Length(list)-1] do
        if list[entrypos] = obj then
            entry := list[entrypos+1];
            pos := Position(entry, val);
            if pos = false then
                Error("Image not present to be deleted");
            fi;
            
            # now we have found the image we want to delete
            # obj may have no images left, in which case we remove it
            # completely, and possibly shrink the table
            
            if Length(entry) = 1  then
                
                # remove two entries from list
                
                for i in [entrypos+2..Length(list)] do
                    list[i-2] := list[i];
                od;
                Unbind(list[Length(list)]);
                Unbind(list[Length(list)]);
                
                # shrink the table if necessary
                
                ht!.entries := ht!.entries - 1;
                if Length(ht!.table) > ListHashParams.BASIC_HASH_RANGE 
                   and ht!.entries*ListHashParams.HASH_SHRINK_MARGIN < Length(ht!.table) 
                then
                    newsize := Maximum(1+Int(Length(ht!.table) / 
                                       ListHashParams.HASH_SHRINK_FACTOR),
                                       ListHashParams.BASIC_HASH_RANGE);
                    ResizeListHashTable(ht, newsize );
                fi;
                return ht;
            fi;
            
            # Here obj still has another image, so we simply need to 
            # delete this one
            
            RemoveSet(entry,val);
            return ht;
        fi;
    od;
    
    # here we ran right through the hash bucket without finding obj
    
    Error("Image not present to be deleted");
end);

    
#############################################################################
##
#M  IsSingleValued( <ht> )                    at most one value at each point
##

InstallMethod( IsSingleValued, true, [ IsListHashTable and IsGeneralMapping ], 0,
        function( ht )
    local list  # runs through hash buckets
          ,i    # index into hash bucket
          ;
    for list in ht!.table do
        for i in [2,4..Length(list)] do
            if Length(list[i]) > 1 then
                return false;
            fi;
        od;
    od;
    return true;
end);

#############################################################################
##
#M  ImagesSource( <ht> )                                           all images 
##

InstallMethod(ImagesSource, true, [IsListHashTable and IsGeneralMapping], 0,
        function(ht)
    local result    # used to build up result
          , list    # runs through hash buckets
          , i       # index into list
          ;
    result := [];
    for list in ht!.table do
        for i in [2,4..Length(list)] do
            UniteSet(result, list[i]);
        od;
    od;
    return Immutable(result);
end);
            
#############################################################################
##
#M  PreImagesRange( <ht> )                    all pts with one or more images
##

InstallMethod(PreImagesRange, true, [IsListHashTable and IsGeneralMapping], 0,
        function(ht)
    local result    # used to build up result
          , list    # runs through hash buckets
          , i       # index into list
          ;
    result := [];
    for list in ht!.table do
        for i in [1,3..Length(list)-1] do
            AddSet(result, list[i]);
        od;
    od;
    return Immutable(result);
end);

#############################################################################
##
#M  ShallowCopy( <ht> ) . . . . . . .  . . . . . . . . . Shallow Mutable Copy
##

InstallMethod( ShallowCopy, true, [ IsListHashTable ], 0, 
        function(ht)
    local CopyBucket; # local function to copy a hash bucket
    
    CopyBucket := function( bucket )
        local i, dup;
        dup := [];
        for i in [1,3..Length(bucket)-1] do
            Add(dup, bucket[i]);
            Add(dup, ShallowCopy(bucket[i+1]));
        od;
        return dup;
    end;
    Info(InfoHashTables,2,"Copying list hash table ",ht!.entries," entries");

    return Objectify(NewType(FamilyObj(ht),
                   IsFlexibleGeneralMapping and IsListHashTable and
                   HasSource and HasRange and IsMutable),
                   rec(
                       source   := ht!.source,
                       range    := ht!.range,
                       hashFunc := ht!.hashFunc,
                       entries  := ht!.entries,
                       table    := List( ht!.table, CopyBucket )));
end);

#############################################################################
##
##   Part 3   FlatHashTables
##
##   A flat hashtable is a fast hash table for partial mappings, and 
##   without deletion. It is a list of alternating points and images. If a 
##   hash collision occurs the first free place (cyclically) to the right is 
##   used. It should be faster and smaller than a list hash table, but is 
##   less general
##  
##   The whole table grows dynamically,  as needed
##


#############################################################################
##
#V  FlatHashParams                    control parameters for hashtable growth
##
##  FlatHashParams.BASIC_HASH_RANGE   is the starting size of list hashtables
##                                    tables will not shrink to become smaller
##                                    than this
##  FlatHashParams.HASH_GROW_MARGIN   the hash table will grow to ensure that 
##                                    the number of hash buckets always exceeds
##                                    the number of entries by this factor
##  FlatHashParams.HASH_GROW_FACTOR   the hash table will grow by this multiple
##                                    when it grows
##
#T  tune these for reasonable performance
##

FlatHashParams := rec(
                      BASIC_HASH_RANGE := 50,
                      HASH_GROW_MARGIN := 3/2,
                      HASH_GROW_FACTOR := 2
                      );

#############################################################################
##
#R  IsFlatHashTable(obj)                                   The representation
##
##
##

DeclareRepresentation("IsFlatHashTable",
                            IsHashTable, ["tabSize"]);

#############################################################################
##
#M  SingleValuedHashTable( <source>, <range>, <hash-function> )
##                                              make an empty flat hash table
##
##  Note that we make the hash table expressly mutable by setting 
##  IsExtensiblePartialMapping. See the declarations file for comments of choice
##  of <source> and <range> and obligations of <hash-function>.
##


InstallMethod(SingleValuedHashTable, true, [IsCollection, IsCollection, IsFunction], 0,
        function(source, range, hash)
    local sourcefam, rangefam, obj;
    Info(InfoHashTables, 1, "Creating a list hash table");
    Info(InfoHashTables, 2, "Source: ", source, " Range: ",range);
    sourcefam := ElementsFamily(FamilyObj(source));
    rangefam := ElementsFamily(FamilyObj(range));
    obj := Objectify(NewType(GeneralMappingsFamily(sourcefam, rangefam), 
                   IsExtensiblePartialMapping and IsFlatHashTable and
                   HasSource and HasRange and IsMutable),
                   rec(
                       source := Immutable(source),
                       range := Immutable(range),
                       hashFunc := Immutable(hash),
                       entries := 0,
                       tabSize := FlatHashParams.BASIC_HASH_RANGE,
                       table := []
                       ));
    
    # force the list to grow now to the size we want
    obj!.table[2*obj!.tabSize+1] := 0; 
    return obj;
end);

#############################################################################
##
#F  ResizeFlatHashTable( <ht>, <newsize> ) local    Adjust size of hash table
##                                                
##


ResizeFlatHashTable := function( ht, newsize)
    local table       # old hash table
          , hash      # local copy of hash function
          , newtable  # new hash table under construction
          , i         # index into old table
          , key       # key of entry being transferred
          , h         # hash value of key
          ;
    Info(InfoHashTables,2,"Resizing Flat Hash Table from ", 
         ht!.tabSize, " to ", newsize);
    table := ht!.table;
    hash := ht!.hashFunc;
    newtable := [];
    newtable[2*newsize+1] := 0;
    for i in [1,3..ht!.tabSize*2-1] do
        if IsBound(table[i]) then
            key := table[i];
            h := hash(key) mod newsize;
            while IsBound(newtable[2*h+1]) do
                h := (h + 1) mod newsize;
            od;
            newtable[2*h+1] := key;
            newtable[2*h+2] := table[i+1];
        fi;
    od;
    ht!.table := newtable;
    ht!.tabSize := newsize;
end;

#############################################################################
##
#M  ImagesElm( <ht>, <obj> )                                  look up a point
##


InstallMethod(ImagesElm, 
        FamSourceEqFamElm,
        [ IsFlatHashTable and IsGeneralMapping and IsSingleValued, IsObject], 
        0,
        function(ht, obj)
    local h             # hash value of object 
          , table       # local copy of hash table
          , size        # local copy of table size
          ;
    Info(InfoHashTables,3,"Looking up ",obj," in hash table");
    h := ht!.hashFunc(obj);
    if h = fail then 
        return fail;
    fi;
    table := ht!.table;
    size  := ht!.tabSize;
    h := h mod size;
    while IsBound(table[2*h+1]) do
        if table[2*h+1] = obj then
            Info(InfoHashTables,3,"Found ",table[2*h+2]);
            return Immutable([table[2*h+2]]);
        fi;
        h := (h+1) mod size;
    od;
    Info(InfoHashTables,3,"Nothing Found");
    return Immutable([]);
end);



#############################################################################
##
#M  AddImage( <ht>, <pt>, <im> )         add an image to a mutable hash table
##

InstallMethod(AddImage, FamMapFamSourceFamRange,
  [ IsFlatHashTable and IsExtensiblePartialMapping and IsMutable, 
    IsObject, IsObject], 0,
  function(ht, obj, val)
    local h, table, size;
    Info(InfoHashTables,3,"Adding ", obj, "->", val, " to flat hash table");
    h := ht!.hashFunc(obj);
    if h = fail then
        Error("Object not in source");
    fi;
    if not val in ht!.range then
        Error("Image not in range");
    fi;
    table := ht!.table;
    size := ht!.tabSize;
    h := h mod size;
    while IsBound(table[2*h+1]) do
        if table[2*h+1] = obj then
            Error("Object already has an image");
        fi;
        h := (h+1) mod size;
    od;
    table[2*h+1] := Immutable(obj);
    table[2*h+2] := Immutable(val);
    ht!.entries := ht!.entries + 1;
    if ht!.tabSize < ht!.entries * FlatHashParams.HASH_GROW_MARGIN then
        ResizeFlatHashTable(ht, 
                1+Int(ht!.tabSize*FlatHashParams.HASH_GROW_FACTOR));
    fi;
    return ht;
end);

#############################################################################
##
#M  AddImageNC( <ht>, <pt>, <im> )       add an image to a mutable hash table
##

InstallMethod(AddImageNC, FamMapFamSourceFamRange,
  [ IsFlatHashTable and IsExtensiblePartialMapping and IsMutable, 
    IsObject, IsObject], 0,
  function(ht, obj, val)
    local h
          ,table
          ,size
          ;
    Info(InfoHashTables,3,"Adding ", obj, "->", val, " to flat hash table");
    h := ht!.hashFunc(obj);
    Assert(2, h <> fail);
    Assert(2, val in ht!.range);
    table := ht!.table;
    size := ht!.tabSize;
    h := h mod size;
    while IsBound(table[2*h+1]) do
        Assert(2, table[2*h+1] <> obj);
        h := (h+1) mod size;
    od;
    table[2*h+1] := Immutable(obj);
    table[2*h+2] := Immutable(val);
    ht!.entries := ht!.entries + 1;
    if ht!.tabSize < ht!.entries * FlatHashParams.HASH_GROW_MARGIN then
        ResizeFlatHashTable(ht, 
                1+Int(ht!.tabSize*FlatHashParams.HASH_GROW_FACTOR));
    fi;
    return ht;
end);

#############################################################################
##
#M  SetImage( <ht>, <pt>, <im> )      change an image in a mutable hash table
##

InstallMethod(SetImage, FamMapFamSourceFamRange,
  [ IsFlatHashTable and IsExtensiblePartialMapping and IsMutable, 
    IsObject, IsObject], 0,
  function(ht, obj, val)
    local h
          ,table
          ,size
          ;
    Info(InfoHashTables,3,"Setting ", obj, "->", val, " in flat hash table");
    h := ht!.hashFunc(obj);
    if h = fail then
        Error("Object not in source");
    fi;
    if not val in ht!.range then
        Error("Image not in range");
    fi;
    table := ht!.table;
    size := ht!.tabSize;
    h := h mod size;
    while IsBound(table[2*h+1]) do
        if table[2*h+1] = obj then
            table[2*h+2] := Immutable(val);
            return ht;
        fi;
        h := (h+1) mod size;
    od;
    table[2*h+1] := Immutable(obj);
    table[2*h+2] := Immutable(val);
    ht!.entries := ht!.entries + 1;
    if ht!.tabSize < ht!.entries * FlatHashParams.HASH_GROW_MARGIN then
        ResizeFlatHashTable(ht, 
                1+Int(ht!.tabSize*FlatHashParams.HASH_GROW_FACTOR));
    fi;
    return ht;
end);


#############################################################################
##
#M  ImagesSource( <ht> )                                           all images 
##

InstallMethod(ImagesSource, true, [IsFlatHashTable and IsSingleValued], 0,
        function(ht)
    local table     # local copy of hash table
          , i       # index into table
          , result  # builds up result
          ;
    result := [];
    table := ht!.table;
    for i in [2,4..2*ht!.tabSize] do
        if IsBound(table[i]) then
            AddSet(result, table[i]);
        fi;
    od;
    return Immutable(result);
end);

#############################################################################
##
#M PreImagesRange( <ht> )                               all pts with an image
##

InstallMethod(PreImagesRange, true, [IsFlatHashTable and IsSingleValued], 0,
        function(ht)
    local table     # local copy of hash table
          , i       # index into table
          , result  # builds up result
          ;
    result := [];
    table := ht!.table;
    for i in [1,3..2*ht!.tabSize-1] do
        if IsBound(table[i]) then
            AddSet(result, table[i]);
        fi;
    od;
    return Immutable(result);
end);
            
#############################################################################
##
#M  ShallowCopy( <ht> )                                          mutable copy
##

InstallMethod(ShallowCopy, true, [IsFlatHashTable and IsSingleValued], 0,
        function(ht)
    
    return Objectify(NewType(FamilyObj(ht),
                   IsExtensiblePartialMapping and IsFlatHashTable and
                   HasSource and HasRange and IsMutable),
                   rec(
                       source := ht!.source,
                       range := ht!.range,
                       hashFunc := ht!.hashFunc,
                       entries := ht!.entries,
                       tabSize := ht!.tabSize,
                       table := ShallowCopy(ht!.table)
                       ));
end);

#############################################################################
##
#E  hash.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

