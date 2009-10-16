1
prime 2 
class  1 
generators  {a, b, c, d}
relations {b^4, b^2 = [b, a, a], d^16 = 1, a^16 = (c * d), 
b^8 = (d * c^4), b = a^2 * b^-1 * a^2};


2
Standard 
10

2

0 1
1 1

0 1
1 0

1

0

