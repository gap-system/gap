# the following code used to crash due to a signed/unsigned char bug in the
# GAP kernel. Found and reported by James Mitchell and Lukas Schnelle during
# GAP Days Summer 2025.
gap> while true do Print('\200'); Print("\n"); break; od;
'\200'
