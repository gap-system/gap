gap> START_TEST("range_bigint.tst");

# Test that small integer ranges still work
gap> Length([1..10]);
10
gap> Length([1,3..9]);
5
gap> First([1..10]);
1
gap> Last([1..10]);
10

# Basic large integer ranges
gap> result := [2^64..2^64 + 10];;
gap> Length(result);
11
gap> First(result);
18446744073709551616
gap> Last(result);
18446744073709551626

# Element access for big int ranges
gap> result[1];
18446744073709551616
gap> result[5];
18446744073709551620
gap> result[11];
18446744073709551626

# Big int range with increment
gap> bigr := [2^64, 2^64+2 .. 2^64+10];;
gap> Length(bigr);
6
gap> First(bigr);
18446744073709551616
gap> Last(bigr);
18446744073709551626
gap> bigr[3];
18446744073709551620

# Negative big integer ranges
gap> negr := [-2^64 .. -2^64 + 5];;
gap> Length(negr);
6
gap> First(negr);
-18446744073709551616
gap> Last(negr);
-18446744073709551611

# Negative big int range with increment
gap> negr2 := [-2^64, -2^64+3 .. -2^64+9];;
gap> Length(negr2);
4
gap> First(negr2);
-18446744073709551616
gap> Last(negr2);
-18446744073709551607

# Decreasing big int range
gap> decr := [2^64+4, 2^64+2 .. 2^64];;
gap> Length(decr);
3
gap> First(decr);
18446744073709551620
gap> Last(decr);
18446744073709551616

# Range equality
gap> [2^64..2^64+5] = [2^64..2^64+5];
true
gap> [2^64..2^64+5] = [2^64..2^64+6];
false

# Range comparison
gap> [2^64..2^64+5] < [2^64+1..2^64+6];
true
gap> [2^64..2^64+5] < [2^64..2^64+5];
false

# IsBound for big int ranges
gap> r := [2^64..2^64+5];;
gap> IsBound(r[1]);
true
gap> IsBound(r[6]);
true
gap> IsBound(r[7]);
false

# Position in big int ranges
gap> r := [2^64..2^64+5];;
gap> Position(r, 2^64);
1
gap> Position(r, 2^64+3);
4
gap> Position(r, 2^64+10);
fail

# For loop over small big-int range (keep it small!)
gap> sum := 0;; for x in [2^64..2^64+4] do sum := sum + x; od; sum;
92233720368547758090
gap> sum = 5 * 2^64 + 10;
true

# For loop over negative big-int range
gap> sum := 0;; for x in [-2^64-2..-2^64] do sum := sum + x; od; sum;
-55340232221128654851
gap> sum = -3 * 2^64 - 3;
true

# For loop with increment
gap> vals := [];; for x in [2^64, 2^64+2..2^64+6] do Add(vals, x); od; vals;
[ 18446744073709551616, 18446744073709551618, 18446744073709551620, 
  18446744073709551622 ]

# List with function on big int range
gap> List([2^64..2^64+3], x -> x - 2^64);
[ 0, 1, 2, 3 ]
gap> List([2^64..2^64+3], x -> x mod 2);
[ 0, 1, 0, 1 ]

# List with function on negative big int range
gap> List([-2^64-2..-2^64], x -> x + 2^64);
[ -2, -1, 0 ]

# Filtered on big int range
gap> Filtered([2^64..2^64+5], x -> x mod 2 = 0);
[ 18446744073709551616, 18446744073709551618, 18446744073709551620 ]

# ForAll/ForAny on big int range
gap> ForAll([2^64..2^64+3], x -> x > 0);
true
gap> ForAny([2^64..2^64+3], x -> x mod 2 = 1);
true

# Number on big int range
gap> Number([2^64..2^64+5], x -> x mod 2 = 0);
3

# Sum/Product on small big-int range
gap> Sum([2^64..2^64+2]);
55340232221128654851
gap> Product([2^64..2^64+1]);
340282366920938463481821351505477763072

# in operator
gap> 2^64 in [2^64..2^64+5];
true
gap> 2^64+3 in [2^64..2^64+5];
true
gap> 2^64+10 in [2^64..2^64+5];
false
gap> 2^64-1 in [2^64..2^64+5];
false

# Print representation
gap> [2^64..2^64+3];
[ 18446744073709551616 .. 18446744073709551619 ]
gap> [2^64, 2^64+2..2^64+6];
[ 18446744073709551616, 18446744073709551618 .. 18446744073709551622 ]
gap> [-2^64..-2^64+2];
[ -18446744073709551616 .. -18446744073709551614 ]

# Empty ranges with big integers still work
gap> [2^64+5..2^64];
[  ]
gap> Length([2^64+5..2^64]);
0

# Singleton ranges with big integers
gap> [2^64..2^64];
[ 18446744073709551616 ]
gap> Length([2^64..2^64]);
1

# Concatenation with big int ranges (converted to plain lists)
gap> Concatenation([2^64..2^64+1], [2^64+2..2^64+3]);
[ 18446744073709551616, 18446744073709551617, 18446744073709551618, 
  18446744073709551619 ]
gap> STOP_TEST("range_bigint.tst");
