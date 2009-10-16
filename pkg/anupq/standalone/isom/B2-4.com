#compute standard presentation for B(2, 4)

1         #set up group presentation 
prime  2
generators  {a, b}
exponent  4
class  1;


2        #standard pcp option 
EXP4     #file

6        #end class for standardise 
2        #number of automorphisms 

0 1
1 1

0 1
1 0

1       #PAG-generating sequence?

0       #exit 
