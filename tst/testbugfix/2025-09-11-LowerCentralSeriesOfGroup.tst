# Fix a bug in LowerCentralSeriesOfGroup for trivial groups
# See https://github.com/gap-system/gap/issues/6108
gap> D:=Group(());;
gap> LowerCentralSeriesOfGroup( D );
[ Group(()), Group(()) ]
gap> NilpotencyClassOfGroup(D);
0
