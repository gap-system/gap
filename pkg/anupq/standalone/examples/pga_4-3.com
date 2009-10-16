
#set up c3 x c3 x c3 x c3

1         #set up group presentation 
c3c3c3c3
3
1
1
{a, b,c ,d }
{}
0
  
7        #compute its 3-covering group 

9        #enter p-group generation 


1        #supply automorphisms 
2        #number of automorphisms 

 2 0 0 0  
 0 1 0 0  
 0 0 1 0  
 0 0 0 1  

 2 0 0 1  
 2 0 0 0  
 0 2 0 0  
 0 0 2 0  

0       #number of soluble automorphisms
 
5       #iteration 
2       #class bound 
1       #all descendants?
1       #order bound?
5       #order bound
0       #PAG-generating sequence 

0       #default?
0       #char subgroup
1       #process terminal groups

0       #enforce exponent law
0       #enforce metabelian law      

1
0       #exit 

0
