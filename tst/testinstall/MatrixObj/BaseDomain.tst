gap> START_TEST("BaseDomain.tst");

#
gap> m := [[1,2],[3,4]];;
gap> BaseDomain(m);
Rationals
gap> BaseDomain(Matrix(m));
Rationals
gap> BaseDomain(Matrix(Rationals, m));
Rationals
gap> BaseDomain(Matrix(Integers, m));
Integers

# FIXME: BUG:
#gap> BaseDomain(Matrix(GF(2), m));
#Rationals

#
gap> m := [[1,2],[3,4/3]];;
gap> BaseDomain(m);
Rationals
gap> BaseDomain(Matrix(m));
Rationals
gap> BaseDomain(Matrix(Rationals, m));
Rationals

# FIXME: BUG:
# gap> BaseDomain(Matrix(Integers, m));
#Integers
#gap> BaseDomain(Matrix(GF(2), m));
#Rationals

#
gap> m := [[1,2],[3,4]] * Z(2);;
gap> BaseDomain(m);
GF(2)
gap> BaseDomain(Matrix(m));
GF(2)
gap> BaseDomain(Matrix(GF(2), m));
GF(2)

# FIXME: BUG:
#gap> BaseDomain(Matrix(Rationals, m));
#Rationals

#
gap> m := [[1,2],[3,Z(4)]] * Z(2);;
gap> BaseDomain(m);
GF(2^2)
gap> BaseDomain(Matrix(m));
GF(2^2)
gap> BaseDomain(Matrix(GF(4), m));
GF(2^2)
gap> BaseDomain(Matrix(GF(2), m));
Error, ConvertToVectorRepNC: Vector cannot be written over GF(2)

# FIXME: BUG:
#gap> BaseDomain(Matrix(Rationals, m));
#Rationals

#
gap> STOP_TEST("BaseDomain.tst");
