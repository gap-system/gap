# 2012/11/02 (FL)
# Fix a crash on 32-bit systems when Log2Int(n) is not an immediate integer. 
gap> a:=(2^(2^15))^(2^14);;
gap> Log2Int(a);
536870912
