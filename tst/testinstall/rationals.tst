#
gap> x := 2/3;
2/3
gap> NumeratorRat(x);
2
gap> DenominatorRat(x);
3
gap> NumeratorRat('c');
Error, NUMERATOR_RAT: <rat> must be a rational (not a character)
gap> DenominatorRat('c');
Error, DENOMINATOR_RAT: <rat> must be a rational (not a character)

#
gap> IsRat(x);
true
gap> IsRat(2);
true
gap> IsRat('c');
false

#
gap> One(x);
1
gap> OneImmutable(x);
1
gap> x^0;
1

#
# 'Rat' -- converting things to a rational
#
gap> Rat(1/2) = 1/2;
true
gap> Rat(1) = 1;
true
gap> Rat(0.5) = 1/2;
true
gap> Rat("1/2");
1/2
gap> Rat("0.565");
113/200
gap> Rat("3-5");
fail
gap> Rat(3.7e-1);                                                  
37/100
gap> Rat("-");
fail
gap> Rat("1/2/3");
fail
gap> Rat("1.2.3");
fail
gap> Rat("1.2/2");
3/5
gap> Rat("2.4/1.2");
2

# division by zero
gap> 0/0;
Error, Rational operations: <divisor> must not be zero
gap> 1/0;
Error, Rational operations: <divisor> must not be zero

#
# modular inverses of rationals
#
gap> 1/2 mod 3;
2
gap> 1/2 mod -3;
2
gap> -1/2 mod 3;
1
gap> -1/2 mod -3;
1
gap> 1/2 mod 2;
Error, ModRat: for <r>/<s> mod <n>, <s>/gcd(<r>,<s>) and <n> must be coprime

#
