############################################################################
##
#W solve.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: solve.gi,v 1.1 2010/07/26 05:18:46 gap Exp $
##
Revision.("isopcp/gap/solv/solve_gi"):=
  "@(#)$Id: solve.gi,v 1.1 2010/07/26 05:18:46 gap Exp $";


############################################################################
##
#F SolutionPGroup_Hensel( <mat>, <rhs>, <modulus> )
##
## - use the special form of the endomorphism-matrix
##
############################################################################
SolutionPGroup_Hensel := 
  function( A, b, modulus )
  local prime,	# THE prime ;)
	pos,	# position in modulus
	exps,	# exponents in <modulus>
	n,m,	# dimension of the matrix <A>
	AA,B, 	# copy of interesting rows of <A> and <b>, respectively
	Sys,	# echelonized matrix etc.
	Sols,	# the solutions
	Invert,	# inverts modulus a <prime>-power
	ell,l,	# current exponent in the <modulus>
	i,j,k;	# loop variables

  # initialization
  prime := FactorsInt( modulus[1] )[1];
  exps  := List( modulus, x -> LogInt( x, prime ) );
  n := Length( A[1] );
  m := Length( A );

  # solve the equation over the field GF(p)
  AA := StructuralCopy( A ); 
  B  := StructuralCopy( b );
  Sols := SolveOverField( AA, B, prime );
  if Sols = fail then return( fail ); fi;

  for ell in [ 2 .. Maximum( exps ) ] do
    pos := First( [ 1 .. Length( modulus ) ], 
                  x -> prime ^ ell <= modulus[x] );
    AA  := StructuralCopy( A{ [ pos .. Length( modulus ) ] } );
    B   := StructuralCopy( b{ [ pos .. Length( modulus ) ] } );
    Sys := EchelonizeHomcycBlock( AA, B, prime, prime ^ ell, pos );
    Sys.modulus   := modulus;
    Sys.solutions := Sols;
    Sys.prime     := prime;
 
    Sols := LiftSolutionByHensel( Sys, ell );
    if Sols = fail then return( fail ); fi;
  od;

# the following seems to be wrong ( the matrix L may be invertible modulo 
# p ^ e_m but not modulo p ^ l... ??
  # the current prime power
# l := 1;
#
# # lift the solutions via Hensel's lifting
# for ell in Set( exps ) do 
#  pos := First( [ 1 .. m ], x -> prime ^ ell <= modulus[x] );
#  AA  := StructuralCopy( A{ [ pos .. m ] } );
#  B   := StructuralCopy( b{ [ pos .. m ] } );
#  Sys := EchelonizeHomcycBlock( AA, B, prime, prime ^ ell, pos );
#  Sys.modulus   := modulus;
#  Sys.solutions := Sols;
#  Sys.prime     := prime;
#
#  for i in [ l+1 .. ell ] do 
#    Sols := LiftSolutionByHensel( Sys, i );
#    if Sols = fail then return( fail ); fi;  
#  od;
#  l := ell;;
# od;
  
  return( Sols );
end;

############################################################################
##
#F SolutionViaPolycyclic( A, b, modulus )
##
############################################################################
SolutionPGroup_Polycyclic := 
  function( A, b, modulus )
  local H,i,j,k, n,m, hom, imgs, ftl, K, Sols;
 
  n := Length( A[1] );
  m := Length( A );

  ftl := FromTheLeftCollector( Length( modulus ) );
  for i in [ 1 .. Length( modulus ) ] do
    SetRelativeOrder( ftl, i, modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, A{[1..m]}[i] ) );
  od;

  hom := GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup( H ), imgs );
  if not PcpElementByExponents( ftl, b ) in Image( hom ) then 
    return( fail );
  fi;

  K := Kernel( hom );

  return( rec( special := Exponents( PreImagesRepresentative( hom,
                                     PcpElementByExponents( ftl, b ) ) ),
               homogeneous := List( GeneratorsOfGroup( K ), Exponents ) ) );

  end;
