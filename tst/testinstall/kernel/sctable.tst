#
# Tests for functions defined in src/sctable.c
#
gap> START_TEST("kernel/sctable.tst");

#
gap> T := EmptySCTable(2,0*Z(2));
[ [ [ [  ], [  ] ], [ [  ], [  ] ] ], [ [ [  ], [  ] ], [ [  ], [  ] ] ], 0, 
  0*Z(2) ]

#
gap> SCTableEntry(false, false, false, false);
Error, SC_TABLE_ENTRY: <table> must be a small list (not the value 'false')
gap> SCTableEntry([], false, false, false);
Error, SCTableEntry: <table> must be a list with at least 3 elements
gap> SCTableEntry(T, false, false, false);
Error, SC_TABLE_ENTRY: <i> must be an integer between 1 and 2 (not the value '\
false')
gap> SCTableEntry(T, 10, false, false);
Error, SC_TABLE_ENTRY: <i> must be an integer between 1 and 2 (not the integer\
 10)
gap> SCTableEntry(T, 1, false, false);
Error, SC_TABLE_ENTRY: <j> must be an integer between 1 and 2 (not the value '\
false')
gap> SCTableEntry(T, 1, 10, false);
Error, SC_TABLE_ENTRY: <j> must be an integer between 1 and 2 (not the integer\
 10)
gap> SCTableEntry(T, 1, 1, false);
Error, SC_TABLE_ENTRY: <k> must be an integer between 1 and 2 (not the value '\
false')
gap> SCTableEntry(T, 1, 1, 10);
Error, SC_TABLE_ENTRY: <k> must be an integer between 1 and 2 (not the integer\
 10)
gap> SCTableEntry(T, 1, 1, 1);
0*Z(2)
gap> SCTableEntry([], 1, 1, 1);
Error, SCTableEntry: <table> must be a list with at least 3 elements
gap> SCTableEntry([1,2,3], 1, 1, 1);
Error, SCTableEntry: <table>[1] must be a list with 1 elements
gap> SCTableEntry([[1],2,3], 1, 1, 1);
Error, SCTableEntry: <table>[1][1] must be a basis/coeffs list
gap> SCTableEntry([[[0,1]],2,3], 1, 1, 1);
Error, SCTableEntry: <table>[1][1][1] must be a basis list
gap> SCTableEntry([[[[0],1]],2,3], 1, 1, 1);
Error, SCTableEntry: <table>[1][1][2] must be a coeffs list
gap> SCTableEntry([[[[0],[0,1]]],2,3], 1, 1, 1);
Error, SCTableEntry: <table>[1][1][1], ~[2] must have equal length
gap> SCTableEntry([[[[0],[1]]],2,3], 1, 1, 1);
3

#
gap> STOP_TEST("kernel/sctable.tst", 1);
