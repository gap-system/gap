#
# test iterating over an empty cartesian product;
# see https://github.com/gap-system/gap/issues/2420
#
gap> it:=IteratorOfCartesianProduct([[1,2],[]]);
<iterator>
gap> IsDoneIterator(it);
true
