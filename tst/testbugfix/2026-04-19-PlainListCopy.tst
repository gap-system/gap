# Fix PlainListCopy for lists which are small but do not know it yet know they
# are in filter `IsSmallList`; this is e.g. needed for the semigroups test
# suite
gap> l:=RightTransversal(Group([ (1,2) ]),Group([ () ]));;
gap> PlainListCopy(l);
[ (), (1,2) ]
