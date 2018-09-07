#
# Aborting parsing of a function expression failed to reset OffsBodyStack,
# which would eventually crash GAP (if you were lucky), or silently corrupt
# the heap.
#
gap> for i in [1..2000] do
>   Test(InputTextString("gap> function() QUIT; end;"), rec(reportDiff:=Ignore));
> od;
