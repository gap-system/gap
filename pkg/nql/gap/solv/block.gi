############################################################################
##
#W block.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: block.gi,v 1.1 2010/07/26 05:18:44 gap Exp $
##
Revision.("isopcp/gap/solv/block_gi"):=
  "@(#)$Id: block.gi,v 1.1 2010/07/26 05:18:44 gap Exp $";

############################################################################
##
#F SolutionPGroup_Block( <Mat>, <rhs>, <mod>
##
SolutionPGroup_Block := function( Mat, rhs, modulus )
  local Block, 	# block structure of the group
	vec,
	modi,
	hom,
	sol,	# the solution
	Ker,
	b, 
	A, 
	n,m,	# dimensions of <Mat>
 	prime,	# the prime number
	pos,	#
	PrPw, PSol, prpw, new,
	i,j,k;	# loop variables

  # initialization
  n := Length( Mat[1] );
  m := Length( Mat );
  prime := FactorsInt( modulus[1] )[1];

  if not IsSortedList( modulus ) then Error("<mod> should be sorted!"); fi;

  # determine the `block structure' of the group
  Block := Collected( modulus );

  # solution for the first block
  pos  := 1;;
  new  := Remove( Block, pos );
  prpw := new[1];
  modi := List( [ 1 .. m ], x -> prpw );  # current modulus

  # determine the homocyclic solution of the first block
  sol := SolutionPGroup_Homcyc( Mat, rhs, modi );
  if sol = fail then return( fail ); fi;

  # generators for the kernel
  Ker := sol.homogeneous;
  for i in [ new[2]+1 .. m ] do 
    vec := ListWithIdenticalEntries( n, 0 );
    vec[i] := prpw;
    Add( Ker, vec );
  od;

  # lift the solutions 
  while IsBound( Block[1] ) do
    pos := pos + new[2];
    new := Remove( Block, 1 );
    modi{[pos..m]} := ListWithIdenticalEntries( m - pos + 1, new[1] );

    # reduce the number of generators of the kernel
    Ker := Set( List( Ker, x -> x mod modi ) );

    b := ( Mat{[ pos .. m ]} * sol.special - rhs{[ pos .. m ]} ) / prpw;
    A := ( Mat{[ pos .. m ]} * TransposedMat( Ker ) ) / prpw; 
  
    PrPw := new[1] / prpw;
    PSol := SolutionPGroup_Homcyc( A, b, List( [ pos .. m ], x -> PrPw ) );
    if PSol = fail then return( fail ); fi;

    # modify the special solution
    sol.special  := sol.special - PSol.special * Ker;

    Ker := Concatenation( List( Ker, x -> ( PrPw * x ) ), 
                          List( PSol.homogeneous, x -> x * Ker ));

    sol.homogeneous := Ker;
  od;

  return( sol ); 
  end;
