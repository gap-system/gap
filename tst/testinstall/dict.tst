#@local dict,enum,f,i,v
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

# enumerators of combinations and tuples of small integers
gap> enum := EnumeratorOfCombinations( [ 1 .. 10 ], 3 );;
gap> IsPositionDictionary( NewDictionary( [ 1, 2, 3 ], true, enum ) );
true
gap> dict := NewDictionary( [ 1, 2, 3 ], true, enum : blistlimit := 100 );;
gap> IsHash( dict );
true
gap> for i in [ 1 .. Length( enum ) ] do AddDictionary( dict, enum[i], i ); od;
gap> ForAll( [ 1 .. Length( enum ) ], i -> LookupDictionary( dict, enum[i] ) = i );
true
gap> LookupDictionary( dict, [ 1, 2, 11 ] );
fail
gap> f := SparseIntKey( enum, [ 1, 2, 3 ] );;
gap> Length( Set( List( enum, f ) ) );
120
gap> enum := EnumeratorOfTuples( [ 1 .. 5 ], 3 );;
gap> f := SparseIntKey( enum, [ 1, 2, 3 ] );;
gap> Length( Set( List( enum, f ) ) );
125
gap> f( [ 1 .. 3 ] ) = f( [ 1, 2, 3 ] );
true
gap> SparseIntKey( EnumeratorOfTuples( [ 2^70, 2^71 ], 2 ), [ 2^70, 2^70 ] );
fail

# Size
gap> dict := NewDictionary( [ 1, 2 ], true );;
gap> IsSortLookupDictionary( dict );
true
gap> Size( dict );
0
gap> AddDictionary( dict, [ 1, 2 ], 1 );; AddDictionary( dict, [ 3 ], 2 );;
gap> Size( dict );
2
gap> dict := NewDictionary( [ 1, 2 ], false );;
gap> AddDictionary( dict, [ 1, 2 ] );; AddDictionary( dict, [ 3 ] );;
gap> Size( dict );
2
gap> dict := NewDictionary( "abc", true );;
gap> IsListLookupDictionary( dict ) and not IsSortLookupDictionary( dict );
true
gap> AddDictionary( dict, "abc", 1 );; AddDictionary( dict, "de", 2 );;
gap> Size( dict );
2
gap> RemoveDictionary( dict, "abc" );; Size( dict );
1
gap> v := Z(3)^0 * [ 1, 0, 1 ];;
gap> dict := NewDictionary( v, true, GF(3)^3 );;
gap> IsPositionLookupDictionary( dict );
true
gap> Size( dict );
0
gap> AddDictionary( dict, v, 1 );; AddDictionary( dict, 2 * v, 2 );;
gap> Size( dict );
2
gap> dict := NewDictionary( v, false, GF(3)^3 );;
gap> AddDictionary( dict, v );; AddDictionary( dict, 2 * v );;
gap> Size( dict );
2
gap> dict := NewDictionary( 1, true, [ 1 .. 100 ] );;
gap> IsHash( dict );
true
gap> AddDictionary( dict, 5, 1 );; AddDictionary( dict, 6, 2 );;
gap> Size( dict );
2
gap> STOP_TEST("dict.tst");
