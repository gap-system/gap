# 2005/08/10 (TB)
#
# Up to now, the method installed for testing the membership of rationals
# in the field of rationals via <span class="code">IsRat</span>
# was not called; instead a more general method was used that called
# <span class="code">Conductor</span> and thus was much slower.
# Now the special method has been ranked up by changing the requirements
# in the method installation.
gap> ApplicableMethod( \in, [ 1, Rationals ] );
function( x, Rationals ) ... end
