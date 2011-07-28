############################################################################
##
#W runt.gi		IsoPcp					René Hartung
##
#H   @(#)$Id: rtimes.gi,v 1.1 2010/07/26 05:18:46 gap Exp $
##
Revision.("isopcp/gap/solv/runt_gi"):=
  "@(#)$Id: rtimes.gi,v 1.1 2010/07/26 05:18:46 gap Exp $";

############################################################################
##
#F CheckRuntime
##
CheckRuntime := function( arg )
  local solH,solB,solS,solSE,time,K,ftl,
	hom,imgs,H,i,n,m,b,solP,L,R,sols,prime,rtim;


  if Length( arg ) = 1 then 
    R := arg[1];
    L := [ 1 .. 4 ];;
  else
    R := arg[1];
    L := arg[2];
  fi;

  rtim := [];

  prime := FactorsInt( R.modulus[1] )[1];

  for i in L do 
    if i = 1 then 
      time := Runtime();
      solH := SolutionPGroup_Hensel( R.matrix, R.rhs, R.modulus );
      rtim[1] := Runtime()-time;;
      Print( "Via Hensel: ", TimeToString( rtim[1] ), "\n");
    elif i = 2 then 
      time := Runtime();
      solB := SolutionPGroup_Block( R.matrix, R.rhs, R.modulus );
      rtim[2] := Runtime()-time;;
      Print( "Via Block: ", TimeToString( rtim[2] ), "\n");
    elif i = 3 then 
      time := Runtime();
      solS := SolutionPGroup_SNF( R.matrix, R.rhs, R.modulus );
      rtim[3] := Runtime()-time;;
      Print( "Via SNF: ", TimeToString( rtim[3] ), "\n");
    elif i = 4 then 
      time := Runtime();
      solP := SolutionPGroup_Polycyclic( R.matrix, R.rhs, R.modulus );
      rtim[4] := Runtime() - time;;
      Print( "Via Polycyclic: ", TimeToString( rtim[4] ), "\n" );
    fi;
  od;
  
  Print( "Timings: ", rtim, "\n" );;
  Print( "Checking results...\n" );

  n := Length( R.matrix[1] );
  m := Length( R.matrix );
  ftl := FromTheLeftCollector( Length( R.modulus ) );
  for i in [ 1 .. Length(R.modulus) ] do
    SetRelativeOrder( ftl, i, R.modulus[i] );
  od;
  UpdatePolycyclicCollector( ftl );
  H := PcpGroupByCollectorNC( ftl );

  imgs := [];;
  for i in [ 1 .. n ] do
    Add( imgs, PcpElementByExponents( ftl, R.matrix{[1..m]}[i] ) );
  od;

  hom := GroupHomomorphismByImagesNC( H, H, GeneratorsOfGroup( H ), imgs );

  b := PcpElementByExponents( ftl, R.rhs );
  if b in Image( hom ) then 
    K := Kernel( hom );;
    for i in L do   
      if i = 1 then 
        if solH = fail then
          Print("Hensel: false\n"); 
          Error( "Hensel returns fail" );
        else 
          if Length( solH.homogeneous ) <> LogInt( Size( K ), prime ) then
            Print( "Hensel: false\n" );
            Error( "Hensel: not an independent generating set for the kernel" );
          else 
            if K = Subgroup( H, List( solH.homogeneous, 
                             x -> PcpElementByExponents( ftl, x ) ) ) then 
              Print( "Hensel: true \n");
            else
              Print( "Hensel: false\n");
              Error( "Hensel: kernels differ" );
            fi;
          fi;
        fi;
      elif i = 2 then 
        if solB = fail then 
          Print("Block: false\n"); 
        else
          Print( "Block: ", K = Subgroup( H, List( solB.homogeneous, 
                              x -> PcpElementByExponents( ftl, x ) ) ),"\n");
        fi;
      elif i = 3 then 
        if solS = fail then 
          Print("SNF: false\n"); 
        else
          Print( "SNF: ", K = Subgroup( H, List( solS.homogeneous, 
                            x -> PcpElementByExponents( ftl, x ) ) ),"\n");
        fi;
      elif i = 4 then 
#   if IsBound( solSE ) then 
#     if solSE = fail then 
#       Print("SNF_EDIM: false\n");
#     else
#       Print( "SNF_EDIM: ", K = Subgroup( H, List( solSE.homogeneous, 
#                             x -> PcpElementByExponents( ftl, x ) ) ),"\n");
#     fi;
#   fi;
        if solP = fail then
          Print("Polycyclic: false\n");
        else
          Print( "Polycyclic: ", K = Subgroup( H, List( solP.homogeneous, 
                             x -> PcpElementByExponents( ftl, x ) ) ),"\n");
        fi;
      fi;
    od;
  else
    for i in L do 
      if i = 1 then 
        Print( "Hensel: ", solH = fail, "\n");
      elif i = 2 then 
        Print( "Block: ", solB = fail, "\n");
      elif i = 3 then 
        Print( "SNF: ", solS = fail, "\n");
      elif i = 4 then 
        Print( "Polycyclic: ", solP = fail, "\n");
      fi;
    od;
#   Print( "SNF_EDIM: ", solSE = fail, "\n");
  fi;
  
  sols := rec();
  if IsBound( solH ) then sols.hensel := solH; fi;
  if IsBound( solB ) then sols.block := solB; fi;
  if IsBound( solS ) then sols.snf := solS; fi;
  if IsBound( solS ) then sols.snf := solS; fi;
  if IsBound( solSE ) then sols.snf_edim := solSE; fi;
  if IsBound( solP ) then sols.polycyclic := solP; fi;

  if sols.hensel <> fail then 
    if Size( K ) <= 10000 then 
      Print( "Size( Ker ) = ", Size( K ), "\n" );
    else 
      Print( "Size( Ker ) = ", Collected( FactorsInt( Size( K ) ) ), "\n" );
    fi;
  fi;;
    
  return( sols );
  end;

############################################################################
##
#F AnalyseGrowingKernel( R )
##
AnalyseGrowingKernel := function( R )
  local time, Times, A, b, modulus, Ze, j, Sols, m;

  A := StructuralCopy( R.matrix );;
  b := StructuralCopy( R.rhs );;
  modulus := StructuralCopy( R.modulus );;
  m := Length( modulus );

  Times := [];
  Ze := [];
  
  time := Runtime();;
  Sols := SolutionPGroup_Hensel( A, b, modulus );
  Print( "Runtime with zero-rows ", Length( Ze ), " ");;
  Print( TimeToString( Runtime()-time ),"\n");
  Add( Times, Runtime() - time );

  while Length( Ze ) < m do
    j := Random( Difference( [1..m], Ze ) );
    A[j] := 0 * A[j];;
    b[j] := 0 * b[j];;
    Add( Ze, j );
    time := Runtime();
    Sols := SolutionPGroup_Hensel( A, b, modulus );
    Add( Times, Runtime()-time );;
    Print( "Runtime with zero-rows ", Length( Ze ), " ");;
    Print( TimeToString( Runtime()-time ),"\n");
  od;
  return( Times );;
  end;
