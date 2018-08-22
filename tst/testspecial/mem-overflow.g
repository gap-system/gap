# double a list until there is a memory overflow
l:=[1];; while true do Append(l,l); od;
# ... then we should be in a break loop. Exit that, perform some other computations.
quit;
Factorial(42);
