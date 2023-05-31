#@local u,v, check
gap> START_TEST("table.tst");
gap> check := {m} -> [IsTable(m), IsRectangularTable(m), HasIsRectangularTable(m) ];
function( m ) ... end
gap> check( [ ]);
[ false, false, false ]
gap> check( [ [] ]);
[ false, false, false ]
gap> check( [ [], [] ]);
[ false, false, false ]
gap> check([ [1,2], [3,4] ]);
[ true, true, true ]
gap> check( [ [1,2], [3]]);
[ true, false, false ]
gap> check( [ "ab", "cd" ]);
[ true, true, true ]
gap> check( [ ['a', 'b'], "cd"]);
[ true, true, true ]
gap> check( [ "ab", ['a', 'b']]);
[ true, true, true ]
gap> check( [ [1,2], "cd"]);
[ false, false, false ]
gap> check( [ [1,2], 3]);
[ false, false, false ]
gap> check(InfiniteListOfNames("a"));
[ false, false, true ]
gap> check([InfiniteListOfNames("a")]);
[ true, true, true ]
gap> check([ ["a","b"], InfiniteListOfNames("a")]);
[ false, false, false ]
gap> STOP_TEST( "table.tst", 1);
