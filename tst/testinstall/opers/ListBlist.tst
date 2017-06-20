gap> ListBlist([],[false,true]);
Error, ListBlist: <blist> must have the same length as <list> (0)
gap> ListBlist([],[1,2]);
Error, ListBlist: <blist> must be a boolean list (not a list (plain,cyc))
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
