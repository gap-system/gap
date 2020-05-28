gap> START_TEST("ListBlist.tst");

#
gap> ListBlist([],[false,true]);
Error, LIST_BLIST: <blist> must have the same length as <list> (lengths are 2 \
and 0)
gap> ListBlist([],[1,2]);
Error, LIST_BLIST: <blist> must be a boolean list (not a plain list of cycloto\
mics)
gap> ListBlist([],[]);
[  ]
gap> ListBlist([1,2],[false,true]);
[ 2 ]
gap> ListBlist([false,true],[false,true]);
[ true ]
gap> ListBlist([1..5],[false,true,false,true,false]);
[ 2, 4 ]
gap> ListBlist([1..5],[true,false,true,false,true]);
[ 1, 3, 5 ]

#
gap> STOP_TEST("ListBlist.tst", 1);
