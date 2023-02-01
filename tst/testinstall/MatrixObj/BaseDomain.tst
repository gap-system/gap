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

# FIXME: BUG:  -> vecmat.gi, code does not check!
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
gap> BaseDomain(Matrix(Integers, m));
Error, the elements in <list> must lie in <basedomain>

# FIXME: BUG:  -> vecmat.gi, code does not check!
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
gap> BaseDomain(Matrix(Rationals, m));
Error, the elements in <list> must lie in <basedomain>

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
gap> BaseDomain(Matrix(Rationals, m));
Error, the elements in <list> must lie in <basedomain>

#
gap> STOP_TEST("BaseDomain.tst");
