gap> START_TEST("2018-12-06-GroupWithGenerators.tst");

# These are undocumented, but should still work
gap> GroupByGenerators( Group( (1,2) ) );
Group([ (), (1,2) ])
gap> GroupWithGenerators( Group( (1,2) ) );
Group([ (), (1,2) ])
gap> STOP_TEST("2018-12-06-GroupWithGenerators.tst", 1);
