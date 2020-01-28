#
# Tests for functions defined in src/pperm.cc
#
gap> START_TEST("kernel/pperm.tst");

#
gap> SparsePartialPermNC(fail, fail);
Error, SparsePartialPermNC: <dom> must be a small list (not the value 'fail')
gap> SparsePartialPermNC([1,2], fail);
Error, SparsePartialPermNC: <img> must be a small list (not the value 'fail')
gap> SparsePartialPermNC([1,2], [2]);
Error, SparsePartialPermNC: <dom> must have the same length as <img> (lengths \
are 2 and 1)
gap> SparsePartialPermNC([1,2], [2,3]);
[1,2,3]
gap> dom:=[1..3]; img:=[2..4];
[ 1 .. 3 ]
[ 2 .. 4 ]
gap> SparsePartialPermNC(dom, img);
[1,2,3,4]
gap> dom; img;
[ 1 .. 3 ]
[ 2 .. 4 ]

#
gap> STOP_TEST("kernel/pperm.tst", 1);
