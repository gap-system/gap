/* cpoly.h header */

typedef long double Cdouble;

int cpoly( const Cdouble *opr, const Cdouble *opi, int degree, Cdouble *zeror, Cdouble *zeroi, Cdouble *heap );

void rpoly(Cdouble *op, int *degree, Cdouble *zeror, Cdouble *zeroi );
