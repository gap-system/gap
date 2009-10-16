#############################
##
##  Some tests for efficiency
##
##############################

## This example used to go through the 
## enumerator for magmas - major time waster
## Now it goes through semigroup code.

fs := FreeSemigroup(2,"x");
x1 := GeneratorsOfSemigroup(fs)[1];;
x2 := GeneratorsOfSemigroup(fs)[2];;
g := fs/[[x1^5,x2],[x2^6,x1],[x1*x2,x2*x1]];
Elements(g);
time; # 680

