1          #set up start information
prime 2
class 2
generators {a, b}
relations  {a^4, b^2 = [b, a, b]};

2          #standardise presentation 
Standard   #file name for iteration information 

10         #standardise to what class?
3          #number of automorphisms?

1 0 0 1
0 1 0 0 

1 0 0 0
0 1 0 1

1 1 1 0
0 1 1 1


1        #PAG-generating sequence for aut gp

4        #display standard presentation for class 10 2-quotient
0        #exit
