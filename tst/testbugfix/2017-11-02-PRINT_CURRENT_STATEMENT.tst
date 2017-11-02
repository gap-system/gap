# PRINT_CURRENT_STATEMENT could lead to crashes when invoked on
# kernel functions.
# See <https://github.com/gap-system/gap/issues/1844>
gap> G:=SymmetricGroup(5);; SylowSubgroup(G,12);
Error, SylowSubgroup: <p> must be a prime
