############################################################################
##
#W checks.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: checks.gi,v 1.1 2010/07/26 05:18:44 gap Exp $
##
Revision.("isopcp/gap/solv/checks_gi"):=
  "@(#)$Id: checks.gi,v 1.1 2010/07/26 05:18:44 gap Exp $";

CompareResult := ReturnTrue();

############################################################################
##
#F CheckMyFunctions
##
CheckMyFunctions := function( n, p )
  local R, Sols, ftl, i, H, imgs, K, hom, m;

  m := n;

  R := RandomEqnAbelianPGroup( n, p );
  PrintTo( "huhu.txt", " R :=  rec( matrix := ", R.matrix, ",\n");
  AppendTo( "huhu.txt", " rhs := ", R.rhs, ",\n");
  AppendTo( "huhu.txt", " modulus := ", R.modulus, ");\n");

  Sols := SolutionPGroup( StructuralCopy( R.matrix ), 
                          StructuralCopy( R.rhs ),
                          StructuralCopy( R.modulus ) );
  if Sols <> fail then 
    if ( R.matrix * Sols.special ) mod R.modulus <> R.rhs mod R.modulus then 
      Display( "The special solution seems to be wrong!" );
      return( false );
    fi;
    if ForAny( Sols.homogeneous,
               x -> ( R.matrix * x ) mod R.modulus <> 0 * R.modulus ) then
      Display( "The homogeneous solutions seem to be wrong!" );
      return( false );
    fi;
  fi;
 
  ftl := FromTheLeftCollector( Length( R.modulus ) );
  for i in [ 1 .. Length( R.modulus ) ] do
    SetRelativeOrder( ftl, i, R.modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, R.matrix{[1..m]}[i] ) );
  od;

  hom := GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup( H ), imgs );
  K := Kernel( hom );

  if Sols = fail then 
    return( not PcpElementByExponents( ftl, R.rhs ) in Image( hom ) );
  fi;

  if Sols.homogeneous = [] then 
    if R.matrix * Sols.special mod R.modulus <> R.rhs mod R.modulus then 
      return( false );
    fi;
  else
    if R.matrix * Sols.special mod R.modulus <> R.rhs mod R.modulus or
       ForAll( Sols.homogeneous, x -> R.matrix * x mod R.modulus <> 0 * R.modulus ) then
       return( false );
    fi;
    return( CompareResult( R.matrix, R.rhs, R.modulus, Sols ) );
  fi;
  return( true );
  end;

############################################################################
##
#F CompareResult . . . .  with SolutionsViaPolycyclic
##
CompareResult := function( A, b, modulus, Sols )
  local prime,spec,homs,i,j,sols;

  prime := FactorsInt( modulus[1] )[1];

  spec := Sols.special;
  homs := Sols.homogeneous;
  
  sols := [ spec mod modulus ];
  for i in [ 1 .. Length( homs ) ] do
    for j in [ 0 .. prime - 1 ] do
      Append( sols, List( sols, x -> ( x + j * homs[i] ) mod modulus ) );
    od;
  od;
  return( Set(sols) = Set( SolutionPGroup_Polycyclic( A, b, modulus ) ) );
  end;


############################################################################
##
#F CountSolutions
##
CountSolutions := function( Sols, modulus )
  local MySols, prime;
  
  prime := FactorsInt( modulus[1] )[1];

  MySols := Concatenation( [ Sols.special ], Sols.homogeneous );
  
  return( Length( Set( 
          List( Tuples( [ 0 .. prime-1 ], Length( Sols.homogeneous ) ),
          x -> ( Concatenation( [1], x ) * MySols ) mod modulus ) ) ) );
  end;

############################################################################
##
#F GeneratesKernel
##
GeneratesKernel := function( A, b, modulus, Sols )
  local ftl,i, H, imgs, hom, K, n;
   
  n := Length( modulus );

  ftl := FromTheLeftCollector( Length( modulus ) );
  for i in [ 1 .. Length( modulus ) ] do
    SetRelativeOrder( ftl, i, modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, A{[1..n]}[i] ) );
  od;

  hom := GroupHomomorphismByImages( H, H, GeneratorsOfGroup( H ), imgs );
  K := Kernel( hom );

  return( K = Subgroup( H, List( Sols.homogeneous, x -> PcpElementByExponents( ftl, x ) ) ) );

  end;


############################################################################
##
#F CheckAlgo 
##
CheckAlgo := function( n, prime )
  local m, R, Sols, ftl, H, K, hom, i, imgs;

  m := n;
  R := RandomEqnAbelianPGroup( n, prime );
  PrintTo( "/tmp/check.txt", "rec( matrix := ", R.matrix, ",\n");
  AppendTo( "/tmp/check.txt", " rhs := ", R.rhs, ",\n");
  AppendTo( "/tmp/check.txt", " modulus := ", R.modulus, ",\n");
  AppendTo( "/tmp/check.txt", " prime := ", prime, ");\n");

  Sols := SolutionPGroup( StructuralCopy( R.matrix ), 
                          StructuralCopy( R.rhs ),
                          StructuralCopy( R.modulus ) );

  # Check by multiplying
  if Sols <> fail then 
    if ( R.matrix * Sols.special ) mod R.modulus <> R.rhs mod R.modulus then 
      Display( "special solution" );
      return( false );
    fi;
    if ForAny( Sols.homogeneous,
               x -> ( R.matrix * x ) mod R.modulus <> 0 * R.modulus ) then
      Display( "homogeneous solution" );
      return( false );
    fi;
  fi;

  # check if <Sols.homogeneous> generate the kernel 
  ftl := FromTheLeftCollector( Length( R.modulus ) );
  for i in [ 1 .. n ] do
    SetRelativeOrder( ftl, i, R.modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, R.matrix{[1..n]}[i] ) );
  od;

  hom := GroupHomomorphismByImages( H, H, GeneratorsOfGroup( H ), imgs );
  if Sols = fail then 
    return( not PcpElementByExponents( ftl, R.rhs ) in Image( hom ) );
  fi;
  

  K := Kernel( hom );
  return( K = Subgroup( H, List( Sols.homogeneous, x -> PcpElementByExponents( ftl, x ) ) ) );
  end;

############################################################################
##
#F CheckSolution 
##
CheckSolution := function( A, b, modulus, Sols )
  local ftl,H,imgs,hom,i,K,n,m;

  n := Length( A[1] );
  m := Length( A );

  if Sols <> fail then 

    # check the special solution
    if ( A * Sols.special ) mod modulus <> b mod modulus then
      Display( "Problem with special solution" );
      return( false ); 
    fi;
  
    # check the homogeneous solutions
    if ForAny( Sols.homogeneous, x -> ( A * x ) mod modulus <> 0 * modulus) then
      Display( "Problem with homogeneous solutions" );
      return( false );
    fi;
  fi;
  
  # the image
  ftl := FromTheLeftCollector( m );
  for i in [ 1 .. m ] do
    SetRelativeOrder( ftl, i, modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. Length( A[1] ) ] do
    Add( imgs, PcpElementByExponents( ftl, A{[1..Length(A)]}[i] ) );
  od;

  hom := GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup( H ), imgs );
  K := Kernel( hom );

  # generates the kernel
  if Sols = fail then 
    return( not PcpElementByExponents( ftl, b ) in Image( hom ) );
  else
    return( K = Subgroup( H, List( Sols.homogeneous,
                x -> PcpElementByExponents( ftl, x )) ) );
  fi;
  end;


############################################################################
##
## CheckHenselAlgo
##
CheckHenselAlgo := function( R )
  local ftl, i, H, imgs, hom, K, n, m, sol, b, prime, j, Sols, SolsN, Bool, Rtimes, time;

  n := Length( R.matrix );;
  m := Length( R.matrix[1] );;
  prime := FactorsInt( R.modulus[1] )[1];

  ftl := FromTheLeftCollector( Length( R.modulus ) );
  for i in [ 1 .. Length( R.modulus ) ] do
    SetRelativeOrder( ftl, i, R.modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, R.matrix{[1..m]}[i] ) );
  od;

  hom := GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup( H ), imgs );
  b := PcpElementByExponents( ftl, R.rhs );;
  
  time := Runtime();;
  K := Kernel( hom );
  Bool := b in Image( hom );
  Rtimes := [ Runtime() - time ];

  time := Runtime();;
  sol := SolutionPGroup_Hensel( R.matrix, R.rhs, R.modulus );
  Rtimes[2] := Runtime() - time;

  Print( "Runtimes: ", List( Rtimes, TimeToString ) );
  Print( "  Size( K ) = ", Size( K ), "\n" );

  if not Bool then 
    if sol <> fail then 
      Error("does not fail" );
      return( false );
    else
      return( true );
    fi;
  fi;

  Sols := [ sol.special ];
  for i in [ 1 .. Length( sol.homogeneous ) ] do 
    SolsN := [];;
    for j in [ 0 .. prime - 1 ] do 
      Append( SolsN, List( Sols, x -> x + j * sol.homogeneous[i] ) );
    od;
    Sols := SolsN;
  od;

  List( Sols, x -> x mod R.modulus );
  if Size( K ) <> Length( Set( Sols ) ) then 
    Error("Size matters!");
    return( false );
  else 
    return( true );
  fi;
# return( Size( K ) = Length( Set( Sols ) ) );
  end;
