############################################################################
##
#W misc.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: misc.gi,v 1.1 2010/07/26 05:18:45 gap Exp $
##
Revision.("isopcp/gap/solv/misc_gi"):=
  "@(#)$Id: misc.gi,v 1.1 2010/07/26 05:18:45 gap Exp $";

############################################################################
##
## StoreEquation( <file>, <Eqn> )
##
StoreEquation := function( file, R )
  PrintTo( file, "return( rec( matrix := ", R.matrix, ",\n" );
  AppendTo( file, " rhs := ", R.rhs, ",\n" );;
  AppendTo( file, " modulus := ", R.modulus, ",\n" );;
  AppendTo( file, " prime := ", R.prime, "));\n" );
  end;
