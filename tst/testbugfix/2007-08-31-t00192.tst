# 2007/08/31 (FL)
gap> # Quotient to yield the same on 32- and 64-bit systems
gap> SHALLOW_SIZE([1])/GAPInfo.BytesPerVariable;
2
gap> SHALLOW_SIZE(List([1..160],i->i^2))/GAPInfo.BytesPerVariable;
161
gap> [ShrinkAllocationPlist, ShrinkAllocationString];;
gap> [EmptyPlist, EmptyString];;                                               
