5
0

1
prime 11 
class 3 
generators {a, b, c}
relations {a^11, b^11, c^11, [b, a, a, a, b] = 1,
 [c, a] = 1, [c, b] = 1, [b, a, b]} ;

2
Standard

#classbound below was originally 9 ... but changed in accord with:
#On Wed, Aug 15, 2001 at 09:13:32PM +0100, Eamonn O'Brien wrote:
#> Dear Greg,
#> Thanks for the bug report. It is caused by the
#> fact that the degree of the permutations
#> constructed exceeds 2^31 - 1, the max value
#> of a signed positive integer. I am doing
#> some checks to try to avoid such problems
#> but they didn't pick this one up.
#> I suggest as a temporary fix to finish
#> the example at class 8, rather than 9.

8

11 

1 0 0 0 0 
0 1 0 0 1 
0 0 1 0 0 

1 0 0 0 0 
0 1 0 0 0 
0 0 1 0 1 

1 0 9 0 0 
0 1 0 0 0 
0 0 1 0 0 

1 7 8 0 0 
0 1 0 0 0 
0 0 1 0 0 

10 0 0 0 0 
0 1 0 0 0 
0 0 1 0 0 

2 0 0 0 0 
0 1 0 0 0 
0 0 1 0 0 

1 0 8 0 0 
0 1 3 0 0 
0 0 1 0 0 

1 0 9 0 0 
0 1 0 0 0 
0 0 3 0 0 

1 0 2 0 0 
0 1 0 0 0 
0 0 10 0 0 

1 9 10 0 0 
0 3 7 0 0 
0 0 6 0 0 

1 5 9 0 0 
0 7 4 0 0 
0 0 10 0 0 

1

0

