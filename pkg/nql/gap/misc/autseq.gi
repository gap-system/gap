############################################################################
##
#W  autseq.gi			NQL				René Hartung
## 								Bettina Eick
##
#H   @(#)$Id: autseq.gi,v 1.3 2010/03/17 12:48:31 gap Exp $
##
Revision.("nql/misc/autseq_gi"):=
  "@(#)$Id: autseq.gi,v 1.3 2010/03/17 12:48:31 gap Exp $";

############################################################################
##
#F NQL_AutGroupPGroup( <PcGroup> )
##
############################################################################
InstallGlobalFunction( NQL_AutGroupPGroup,
  function( G )
  local p, r, pcgs, first, n, iso, F, f, Auts, A, Q, epi, H, h,
        s, t, P, M, N, U, baseN, baseU, i;

  if Size( G ) = 1 then return Group( [], IdentityMapping(G) ); fi;

  # set up
  p := PrimePGroup( G );
  r := RankPGroup( G );

  # flags
  CHOP_MULT := true;
  NICE_STAB := true; 
  USE_LABEL := false;

  # special pcgs 
  pcgs  := SpecialPcgs( G );
  first := LGFirst( SpecialPcgs(G) );
  n     := Length(pcgs);

  # fp group
  iso := IsomorphismFpGroupByPcgs( pcgs, "f" );
  F   := Range( iso );
  f   := List( pcgs, x -> Image( iso, x ) );
  
  # results
  Auts := [];

  # init automorphism group - compute Aut(G/G_1)
  Info( InfoAutGrp, 2, 
        "step 1: ",p,"^", first[2]-1, " -- init automorphisms ");

  # class 1
  #A := InitAutomorphismGroupFull(G);
  A := InitAutomorphismGroupOver(G);
  Q := PQuotient( F, p, 1 );
  epi := EpimorphismQuotientSystem( Q );
  H := Range(epi);
  h := List( f, x -> Image(epi,x) );

  # store
  Auts[1] := ConvertAutGroup( A, H );
  Auts[1].nathom := GroupHomomorphismByImages( G, H, AsList(pcgs), h );

  # loop
  for i in [2..Length(first)-1] do

      # print info
      s := first[i];
      t := first[i+1];
      Info( InfoAutGrp, 1, 
            "step ",i,": ",p,"^", t-s, " -- aut grp has size ", A.size );
    
      # the cover
      Info( InfoAutGrp, 2, "  computing cover");
      P := PCover( Q );
      M := PMultiplicator( Q, P );
      N := Nucleus( Q, P );
      U := AllowableSubgroup( Q, P );
      AddInfoCover( Q, P, M, U );

      # induced action of A on M
      Info( InfoAutGrp, 2, "  computing matrix action");
      LinearActionAutGrp( A, P, M );

      # compute stabilizer
      Info( InfoAutGrp, 2, "  computing stabilizer of U");
      baseN := GeneratorsOfGroup(N);
      baseU := GeneratorsOfGroup(U);
      baseN := List(baseN, x -> ExponentsOfPcElement(Pcgs(M), x))*One(GF(p));
      baseU := List(baseU, x -> ExponentsOfPcElement(Pcgs(M), x))*One(GF(p));
      baseU := EcheloniseMat( baseU );
      PGOrbitStabilizer( A, baseU, baseN, false );

      # next step of p-quotient
      IncorporateCentralRelations( Q );
      RenumberHighestWeightGenerators( Q );

      # induce to next factor
      Info( InfoAutGrp, 2, "  induce autos and add central autos");
      A := InduceAutGroup( A, Q, P, M, U );

      # compute the natural homomorphism onto the class-<i> quotient
      epi := EpimorphismQuotientSystem( Q );
      H := Range(epi);
      h := List( f, x -> Image(epi,x) );
      Auts[i] := ConvertAutGroup( A, H );
      Auts[i].nathom := GroupHomomorphismByImages( G, H, AsList(pcgs), h );
  od;

  # that's it
  return( Auts );
end);

############################################################################
##
#M AutomorphismGroupSequence( <PcpGroup> )
##
############################################################################
InstallMethod( AutomorphismGroupSequence,
  "for a PcGroup",
  true, 
  [ IsPcGroup ], 0, 
  function( G )
  local A, t, B, I, fac, F, f, Emb, i, j, auts, conc, prei, inds, aut, 
        imgH, imgF, b, g;

  # we only deal with groups so that the lower- and the p-central series 
  # coincide
  if Length( Set( AbelianInvariants( G ) ) ) <> 1 then
    TryNextMethod();
  fi;

  # get all relevant aut groups
  A   := NQL_AutGroupPGroup( G );

  # find first quotient with solvable aut group
  t := First([1..Length(A)], x -> Length(A[x].glAutos)=0);
  if t = fail then Print("Aut group still solvable!\n"); return(); fi;
  A := A{[t..Length(A)]};

  # quotients
  B   := List( A, PcGroupAutPGroup );
  I   := List( B, InnerAutGroupPGroup );
  fac := List( [ 1 .. Length( B ) ], 
               x -> NaturalHomomorphismByNormalSubgroup( B[x], I[x] ) );
  F   := List( A, x -> Range( x.nathom ) );
  f   := List( A, x -> List( Pcgs(G), y -> Image(x.nathom,y) ) ); 

  # embedding the automorphism groups
  Emb := List( [1..Length(A)], x -> [] );
  for i in [t..Length(A)-1] do 
      for j in [i+1..Length(A)] do 
          auts := Concatenation( A[j].glAutos, A[j].agAutos );
          conc := GroupHomomorphismByImages( F[j], F[i], f[j], f[i] );
          prei := List( Pcgs(F[i]), x -> PreImagesRepresentative(conc, x ) );
          inds := [];

          for aut in auts do
              imgH := List( prei, x -> Image( aut, x ) );
              imgF := List( imgH, x -> Image( conc, x ) );
              b := PGAutomorphism( F[i], Pcgs( F[i] ), imgF );
              g := ImageAutPGroup( B[i]!.autrec, B[i], b );
              Add( inds, g );
          od;

          Emb[i][j] := Image( fac[i], Subgroup( B[i], inds ));

          if IsAbelian( Emb[i][j] ) then 
              Print( "[",i,",",j,"]: ab ", Collected(AbelianInvariants(Emb[i][j])),"\n");
          elif Size( Emb[i][j] ) <= 100 then 
              Print( "[",i,",",j,"]: id ", IdSmallGroup(Emb[i][j]),"\n");
          else
              Print( "[",i,",",j,"]: sz ", Size(Emb[i][j]),"\n");
          fi;
      od;
      Print("\n");
  od;
  return( Emb );
  end);

############################################################################
##
#M AutomorphismGroupSequence( <PcpGroup> )
##
############################################################################
InstallMethod( AutomorphismGroupSequence,
  "for a PcpGroup",
  true, 
  [ IsPcpGroup ], 0, 
  G -> AutomorphismGroupSequence( Range( IsomorphismPcGroup( G ) ) ));

############################################################################
##
#M AutomorphismGroupSequence( <LpGroup>, <int> )
##
############################################################################
InstallOtherMethod( AutomorphismGroupSequence,
  "for an LpGroup and a positive integer",
  true, 
  [ IsLpGroup, IsPosInt ], 0, 
  function( G, c )
  return( AutomorphismGroupSequence( NilpotentQuotient( G, c ) ) );
  end);
