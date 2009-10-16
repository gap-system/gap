#descendants of c2 x c2 x c2

1         #set up group presentation 
c2c2c2
2
1
1
{a, b, c}
{}
0

7        #compute its 2-covering group 

9        #enter p-group generation 

1        #supply automorphisms 
2        #number of automorphisms 

 1 1 0   
 0 1 0   
 0 0 1   

 0 0 1  
 1 0 0  
 0 1 0   

0       #number of soluble automorphisms

5       #iteration option 
5       #class bound 
1       #all descendants?
1       #set order bound?
7       #order bound
0       #PAG-generating sequence 

1       #default algorithm?
1       #default output 

0       #exit 
0       #exit 
