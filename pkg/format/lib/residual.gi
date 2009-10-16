#############################################################################
##
#W  residual.gi                     FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/lib/residual.gi") :=
    "@(#)$Id: residual.gi,v 1.6 2000/10/31 17:16:29 gap Exp $";

#############################################################################
#M  ResidualFunctionOfFormation( <form> ) . . . . . . . . . . . . . . . . . . ##
   
InstallMethod(ResidualFunctionOfFormation, "from screen",
  true, [IsFormation and HasScreenOfFormation], 0,
function( form )
  return (G -> ResidualSubgroupFromScreen(G,form));
end);

#############################################################################
#M  ResidualSubgroupFromScreen( <group>, <formation> )
##

InstallMethod( ResidualSubgroupFromScreen, "generic", true,
  [IsGroup, IsFormation and HasScreenOfFormation], 0,
function(G, form)
  local primes, sub, gens, p, N, M;

  primes := Set(Factors(Size(G)));
  if HasSupportOfFormation(form) then
    sub := Intersection(primes, SupportOfFormation(form));
  else
    sub := primes;
  fi;

  gens := [];

  for p in Difference(primes, sub) do
    Append(gens, GeneratorsOfGroup(SylowSubgroup(G,p)));
  od;

  for p in sub do
    N := ScreenOfFormation(form)(G,p);
    M := PResidual(N,p);
    Append(gens, GeneratorsOfGroup(SylowSubgroup(M,p)));
  od;

  return NormalClosure(G, SubgroupNC(G, gens));
end);

#############################################################################
#M  ResidualSubgroupFromScreen( <group>, <formation> )
##

InstallMethod( ResidualSubgroupFromScreen, "pcgs", true,
  [IsGroup and CanEasilyComputePcgs, IsFormation and HasScreenOfFormation],0,
function(G, form)
  local primes, sub, gens, p, N, M, gensR, pcgsm, g, q;

  primes := RelativeOrders( Pcgs(G) );

  if HasSupportOfFormation(form) then
    sub := Intersection( Set( primes ), SupportOfFormation(form) );
  else
    sub := Set( primes );
  fi;

  # set up generators with sub' part
  gens := Pcgs(G){Filtered([1..Length(primes)],x->not primes[x] in sub)};

  # loop over primes
  for p in sub do

    # compute local residual
    N := ScreenOfFormation(form)( G, p );

    # compute O^p of it
    M := PResidual( N, p );

    # compute normal subgroup genset of O^p' of _that_
    gensR := [ ];
    pcgsm := Pcgs( M );          # InducedPcgsWrtSpecialPcgs can fail here
    for g  in pcgsm  do
      q := RelativeOrderOfPcElement( pcgsm, g );
      if q = p then
        Add( gensR, PrimePowerComponent( g, q ) );
      fi;
    od;

    # append it to the other generators
    Append( gens, gensR );
  od;

  # compute subgroup and normal closure
  return NormalClosure( G, SubgroupNC( G, gens ) );
end);

#############################################################################
#M  ResidualSubgroupFromScreen( <group>, <formation> )
##

SubgpMethodByNiceMonomorphismCollOther(ResidualSubgroupFromScreen,
  [IsGroup, IsFormation]);

#############################################################################
#M ResidualWrtFormationOp( <group>,<form> ) . <formation> residual of <group>
##

InstallMethod( ResidualWrtFormationOp, "generic",
true, [IsGroup,IsFormation], 0,
function( group, form )
  return ResidualFunctionOfFormation( form )( group );
end);


#E  End of residual.gi
