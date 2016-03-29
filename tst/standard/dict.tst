#############################################################################
##
#W  dict.tst                   GAP library                Markus Pfeiffer
##
##
#Y  Copyright (C)  2015, The GAP Group
##
gap> START_TEST("dict.tst");
gap> dict := NewDictionary(1, false);
<dictionary>
gap> AddDictionary(dict,1); AddDictionary(dict, 42);
gap> Enumerator(dict);
[ 1, 42 ]
gap> RemoveDictionary(dict, 1);
gap> Enumerator(dict);
[ 42 ]
gap> dict := NewDictionary(1, true, Integers);
Keys: [  ]
Values: [  ]
gap> AddDictionary(dict, 1, "hello"); AddDictionary(dict, 42, "world");
gap> dict;
Keys: [ 1, 42 ]
Values: [ "hello", "world" ]
gap> for i in [1..1000] do
> AddDictionary(dict, i, String(i));
> od;
gap> dict;
<sparse hash table of size 1002>
gap> STOP_TEST( "dict.tst", 1000);
#############################################################################
##
#E  
