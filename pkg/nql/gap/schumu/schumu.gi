############################################################################
##
#W  schumu.gi			NQL				René Hartung
##
#H   @(#)$Id: schumu.gi,v 1.2 2009/08/31 07:55:23 gap Exp $
##
Revision.("nql/gap/schumu_gi"):=
  "@(#)$Id: schumu.gi,v 1.2 2009/08/31 07:55:23 gap Exp $";

# TODO: inducing endomorphisms of the group to endomorphisms of the Schur
# multiplier (Psi!)

############################################################################
##
#A  GeneratingSetOfMultiplier( <LpGroup> )
##
## computes a generating set for the Schur multiplier by modifying the 
## L-presentation of <LpGroup>
##
InstallMethod( GeneratingSetOfMultiplier,
  "for an invariantly L-presented group", true,
  [ IsLpGroup and HasIsInvariantLPresentation and 
    IsInvariantLPresentation ], 0,
  function( G )
  local GensMultiplier,# generators of the multiplier
	frels,	# fixed relators of <G>
        frelsEV,# exponent vectors of the fixed relators of <G>
        irels,	# iterated relators of <G>
        irelsEV,# exponent vectors of the iterated relators of <G>
        irel,	# an iterated relator of <G>
        irelEV, # an exponent vector of an iterated relator of <G>
	obj,	# external representation of a free group element
	mat,	# an induced endomorphism of the free abelian group
	endo,	# an endomorphism of the LpGroup <G>
	endos,	# the induced endomorphisms of the free abelian group
	n,	# number of generators of <G>
	HNF,hnf,# Hermite normal forms
	basis,  # current basis for the free abelian complement
	basN,	# updated basis for the free abelian complement
	elm,	# an element of the free group
	i,j,k;	# loop variables

  GensMultiplier := rec( FixedGens     := [],
                         IteratedGens  := [] );

  # the number of generators of <G>
  n := Length( GeneratorsOfGroup( G ) );

  # the exponent vectors of the fixed relators
  frels   := ShallowCopy( FixedRelatorsOfLpGroup( G ) );
  frelsEV := NullMat( Length( frels ), n );
  i := 1;;
  while i <= Length( frels ) do 
    obj := ExtRepOfObj( frels[i] );
    for j in [ 1, 3..Length(obj)-1 ] do 
      frelsEV[i][ obj[j] ] := frelsEV[i][ obj[j] ] + obj[j+1];
    od;

    # filter which relators are already contained in the derived subgroup
    if IsZero( frelsEV[i] ) then 
      Add( GensMultiplier.FixedGens, frels[i] );
      Remove( frels, i );
      Remove( frelsEV, i );
    else
      i := i + 1;
    fi;
  od;

  # the exponent vectors of the iterated relators
  irels   := ShallowCopy( IteratedRelatorsOfLpGroup( G ) );
  irelsEV := NullMat( Length( irels), n );
  i := 1;
  while i <= Length( irels ) do 
    obj := ExtRepOfObj( irels[i] );
    for j in [ 1, 3 .. Length(obj)-1 ] do 
      irelsEV[i][ obj[j] ] := irelsEV[i][ obj[j] ] + obj[j+1];
    od;
    # filter which relators are already contained in the derived subgroup
    if IsZero( irelsEV[i] ) then
      Add( GensMultiplier.IteratedGens, irels[i] );
      Remove( irels, i ); 
      Remove( irelsEV, i ); 
    else 
      i := i + 1;
    fi;
  od;

  # induce the endomorphisms to endomorphisms of the free abelian group
  endos := [];
  for endo in EndomorphismsOfLpGroup( G ) do
    mat := NullMat( n, n );
    obj := List( GeneratorsOfGroup( G ), 
                 x -> ExtRepOfObj( UnderlyingElement( x ) ^ endo ) );
    for i in [ 1 .. n ] do 
      for j in [ 1, 3 .. Length(obj[i])-1 ] do
        mat[i][ obj[i][j] ] := mat[i][ obj[i][j] ] + obj[i][j+1] ;;
      od;
    od;
    Add( endos, mat );
  od;

  # initialize the basis and the Hermite normal form (of basis elements)
  basis := [];
  HNF   := rec( mat := [], Heads := [] );

  # check the fixed relators for basis elements
  while IsBound( frels[1] ) do 
    if IsEmpty( HNF.Heads ) then
      NQL_AddRow( HNF, frelsEV[1] );
      Add( basis, frels[1] );
    else
      hnf := ShallowCopy( HNF.mat );
      if NQL_AddRow( HNF, frelsEV[1] ) then 
        # obtained a new basis-element...
          # either we just add frels[1]
          # or we move a basis element to GensMultiplier.FixedGens
        Add( hnf, frelsEV[1] );
        Add( basis, frels[1] );
        hnf  := HermiteNormalFormIntegerMatTransform( hnf );

        # initialize the new basis
        basN := ListWithIdenticalEntries( Length(HNF.Heads), 
                                          One( FreeGroupOfLpGroup( G ) ) );
 
        for i in [ 1 .. Length(hnf.normal) ] do 
          if IsZero( hnf.normal[i] ) then 
            elm := One( FreeGroupOfLpGroup( G ) );
            for j in [1..Length(hnf.rowtrans[i])] do
              elm := elm * basis[j] ^ hnf.rowtrans[i][j];
            od;
            Add( GensMultiplier.FixedGens, elm );
          else 
            for j in [1..Length(hnf.rowtrans[i])] do 
              basN[i] := basN[i] * basis[j] ^ hnf.rowtrans[i][j];
            od;
          fi;
        od;
        basis := basN;
      else
        # already contained in the span...
        
        # reduce and add modified relator to GensMultiplier.FixedGens
        i := PositionNonZero( frelsEV[1] );;
        while i <= n do 
          j := Position( HNF.Heads, i );
          k := frelsEV[1][i] / HNF.mat[j][HNF.Heads[j]];
          frels[1]   := frels[1] * basis[j] ^ -k;
          frelsEV[1] := frelsEV[1] - k * HNF.mat[j];
          i := PositionNonZero( frelsEV[1] );
        od;
        if not frels[1] = One( FreeGroupOfLpGroup( G ) ) then 
          Add( GensMultiplier.FixedGens, frels[1] );
        fi;
      fi;
    fi;
    Remove( frels, 1 );
    Remove( frelsEV, 1 );
  od;

  # check the iterated relators for basis elements (use spinning)
  while IsBound( irels[1] ) do 
    if IsEmpty( HNF.Heads ) then
      NQL_AddRow( HNF, irelsEV[1] );
      Add( basis, irels[1] );
      Append( irels, List( EndomorphismsOfLpGroup( G ), x -> irels[1] ^ x ));
      Append( irelsEV, List( endos, x -> irelsEV[1] * x ));
    else
      hnf := ShallowCopy( HNF.mat );
      if NQL_AddRow( HNF, irelsEV[1] ) then 
        # obtained a new basis-element...
          # either we just add frels[i]
          # or we move a basis element to GensMultiplier.FixedGens
        Add( hnf, irelsEV[1] );
        Add( basis, irels[1] );
        hnf  := HermiteNormalFormIntegerMatTransform( hnf );

        # initialize the new basis
        basN := ListWithIdenticalEntries( Length(HNF.Heads), 
                                          One( FreeGroupOfLpGroup( G ) ) );
 
        for i in [ 1 .. Length(hnf.normal) ] do 
          if IsZero( hnf.normal[i] ) then 
            elm := One( FreeGroupOfLpGroup( G ) );
            for j in [1..Length(hnf.rowtrans[i])] do
              elm := elm * basis[j] ^ hnf.rowtrans[i][j];
            od;
            Add( GensMultiplier.IteratedGens, elm );
          else 
            for j in [1..Length(hnf.rowtrans[i])] do 
              basN[i] := basN[i] * basis[j] ^ hnf.rowtrans[i][j];
            od;
            Append( irels, List( EndomorphismsOfLpGroup( G ), 
                                 x -> irels[1] ^ x ));
            Append( irelsEV, List( endos, x -> irelsEV[1] * x ));
          fi;
        od;
        basis := basN;
      else
        # already contained in the span...
        irel := ShallowCopy( irels[1] );
        irelEV := ShallowCopy( irelsEV[1] );
        
        # reduce and add modified relator to GensMultiplier.FixedGens
        i := PositionNonZero( irelsEV[1] );;
        while i <= n do 
          j := Position( HNF.Heads, i );
          k := irelsEV[1][i] / HNF.mat[j][HNF.Heads[j]];
          irels[1]   := irels[1] * basis[j] ^ -k;
          irelsEV[1] := irelsEV[1] - k * HNF.mat[j];
          i := PositionNonZero( irelsEV[1] );
        od;

        if not irels[1] = One( FreeGroupOfLpGroup( G ) ) then 
          Add( GensMultiplier.IteratedGens, irels[1] );
        else
          # since we may loose the images of irel, we need to add its
          # image as iterated relators (for FpGroups there's only the 
          # identity in EndomorphismsOfLpGroup
          if not HasIsFinitelyPresentable( G ) or 
             not IsFinitelyPresentable( G ) then
            Append( irels, List( EndomorphismsOfLpGroup( G ),
                                 x -> irel ^ x ) );
            Append( irelsEV, List( endos, x -> irelEV * x ) );
          fi;
#         Append( irels, List( EndomorphismsOfLpGroup( G ),
#                              x -> irels[1] ^ x ) );
#         Append( irelsEV, List( endos, x -> irelsEV[1] * x ) );
        fi;
      fi;
    fi;
    Remove( irels, 1 );
    Remove( irelsEV, 1 );
  od;
  GensMultiplier.BasisGens     := basis;
  GensMultiplier.Endomorphisms := EndomorphismsOfLpGroup( G );
  return(GensMultiplier);
  end);

############################################################################
##
#M  FiniteRankSchurMultiplier( <LpGroup>, <int> )
##
## computes the image of the Schur multiplier of <LpGroup> in the Schur
## multiplier of the class-<int> quotient of <LpGroup>.
##
InstallMethod( FiniteRankSchurMultiplier, 
  "for invariantly L-presented groups", true,
  [ IsLpGroup and HasIsInvariantLPresentation and
    IsInvariantLPresentation, IsPosInt ], 0,
  function( G, c ) 
  local endos; # a list of the induced endomorphisms
  endos := EndomorphismsOfFRSchurMultiplier( G, c );
  if endos = fail then 
    return( fail );
  else
    if not IsBound( endos[1] ) then Error("list of induced endomorphisms"); fi; 
    return( Source( endos[1] ) );
  fi;
  end);

############################################################################
##
#M  EndomorphismsOfFRSchurMultiplier( <LpGroup>, <int> )
##
## induces the endomorphisms of the invariant L-presentation of <LpGroup>
## to the `FiniteRankSchurMultiplier' of <LpGroup>.
##
InstallMethod( EndomorphismsOfFRSchurMultiplier,
  "for invariantly L-presented groups", true,
  [ IsLpGroup and HasIsInvariantLPresentation and
    IsInvariantLPresentation, IsPosInt ], 0,
  function( G, c )
  local Q, QS,	# weighted nilpotent quotient systems for nilpotent quotients
	weights,# list of weights of the generators of <Q>
 	Defs,	# list of definitions of the generators of <Q>
	Imgs,	# images of the generators of <G> 
	ftl,	# <FromTheLeftCollector> of the covering group
	b,	# Position of the tails in the generating set of <ftl>
 	HNF,	# Hermite normal form of the consistency relations and relations
	H, 	# the covering group
	gens,	# generators of the covering group <H> or the image of M(G)
	T,	# the multiplier of the covering group <H>
	stack,	# stack for the spinning algorithm
	g,gImg,	# an iterated relators and its image in <T>
	GensMultiplier,# generators of the multiplier 
	endo,	# an endomorphism of the free group underlying <G>
	imgs,	# for inducing the endomorphisms
	endos,	# the induced endomorphisms of the covering group
	SchuMu,	# a finitely generated quotient of the Schur multiplier of <G>
	Cov,	# covering groups (Attribute)
	i;	# loop variables

  if HasCoveringGroups( G ) then 
    if IsBound( CoveringGroups( G )[c] ) then
      if IsBound( CoveringGroups( G )[c].IndEndosOfFRMult ) then 
        return( CoveringGroups( G )[c].IndEndosOfFRMult );
      fi;
      QS := CoveringGroups( G )[c];
    else
      if HasNilpotentQuotientSystem( G ) and 
         Maximum( NilpotentQuotientSystem( G ).Weights ) > c then
        Q := SmallerQuotientSystem( NilpotentQuotientSystem( G ), c );;
      else 
        if NilpotencyClassOfGroup( NilpotentQuotient( G, c ) ) < c then 
          Info( InfoNQL, 1, "The group has a maximal nilpotent quotient of",
                            " class ", Maximum( Q.Weights ) );
          return( fail );
        fi;
        Q := NilpotentQuotientSystem( G );
      fi;

      QS := NQL_QSystemOfCoveringGroup( Q );
   
      Cov    := ShallowCopy( CoveringGroups( G ) );
      Cov[c] := QS;
      ResetFilterObj( G, CoveringGroups );
      SetCoveringGroups( G, Cov );
    fi;
  else
    if HasNilpotentQuotientSystem( G ) and
       Maximum( NilpotentQuotientSystem( G ).Weights ) > c then 
      Q := SmallerQuotientSystem( NilpotentQuotientSystem( G ), c );
    else 
      if NilpotencyClassOfGroup( NilpotentQuotient( G, c ) ) < c then 
        Info( InfoWarning, 0, "The group has a maximal nilpotent quotient of",
                              " class ", Maximum( Q.Weights ) );
        return( fail );
      fi;
      Q := NilpotentQuotientSystem( G );
    fi;

    QS := NQL_QSystemOfCoveringGroup( Q );
  
    Cov := []; Cov[c] := QS;
    SetCoveringGroups( G, Cov );
  fi;

  # the covering group
  H := Range( QS.Epimorphism );

  # induce EndomorphismsOfLpGroup to endomorphisms of the covering group <H>
# endos := NQL_InduceEndosToCover( QS, Q.Lpres );
  endos := NQL_InduceEndosToCover( G, EndomorphismsOfLpGroup( G ), c );

  # modify the invariant L-presentation 
  GensMultiplier := GeneratingSetOfMultiplier( G );;

  # start the spinning algorithm
##  gens   := Set ( List( Concatenation( GensMultiplier.FixedGens, 
##                  GensMultiplier.IteratedGens ), x -> x ^ QS.Epimorphism ) );
##  SchuMu := Subgroup( H, gens );

##  stack  := ShallowCopy( GensMultiplier.IteratedGens );
##  while IsBound( stack[1] ) do 
##    for endo in GensMultiplier.Endomorphisms do
##      g    := stack[1] ^ endo;
##      gImg := g ^ QS.Epimorphism;
##      if not gImg in SchuMu then 
##        Add( gens, gImg );
##        SchuMu := Subgroup( H, gens );
##        Add( stack, g );
##      fi;
##    od;
##    Remove( stack, 1 );
##  od;

##  stack := List( GensMultiplier.IteratedGens, x -> Image( QS.Epimorphism, x ) );
##  while IsBound( stack[1] ) do
##    for endo in endos do
##      g := Image( endo, stack[1] );
##      if not g in SchuMu then 
##        Add( gens, g );
##        SchuMu := Subgroup( H, gens );
##        Add( stack, g );
##      fi;
##    od;
##    Remove( stack, 1 );
##  od;

  SchuMu := NQL_SchuMuFromCover( QS, GensMultiplier, endos );;

  # return the restriction of the induced endomorphisms to the subgroup <SchuMu>
  for i in [ 1 .. Length( endos ) ] do
    endos[i] := GroupGeneralMappingByImages( SchuMu, SchuMu, 
                GeneratorsOfGroup( SchuMu ),
                List( GeneratorsOfGroup( SchuMu ), x -> Image( endos[i], x )));
  od;

  # store as an attribute
  Cov := ShallowCopy( CoveringGroups( G ) );
  Cov[c] := ShallowCopy( Cov[c] );
  Cov[c].IndEndosOfFRMult := endos; 
  ResetFilterObj( G, CoveringGroups );
  SetCoveringGroups( G, Cov );

  return( endos );
  end);

############################################################################
##
#F  NQL_SchuMuFromCover( <QS>, <GensMult>, <Endos> )
##
InstallGlobalFunction( NQL_SchuMuFromCover, 
  function( QS, GensMult, endos )
  local SchuMu, # the (finite rank) Schur multiplier
	b,	# position of the first generators of the multiplier
	H, 	# the covering group (represented by <QS>)
	orders,	# relative orders of the covering group
	n,	# number of generators of the covering group
	ev,	# exponent vector of an element in the covering group <H>
	mat, 	# an endomorphism of the multiplier written as a matrix
	Endos,	# endomorphisms of the multiplier written as matrices
	HNF,	# the Hermite normal form
	stack,	# stack of exponent vectors for the spinning algorithm
	gens,	# generators of the finite rank Schur multiplier
	i,j;	# loop variables
  
  # position of the generators of the multiplier
  b := Position( QS.Weights, Maximum( QS.Weights ) );;
  n := Length( QS.Weights );;
  
  # the covering group with its relative orders
  H      := Range( QS.Epimorphism );;
  orders := RelativeOrders( QS.Pccol );;

  # compute the Hermite normal form from the covering group
  HNF := rec( mat := [], Heads := [] );
  for i in Filtered( [ b .. n ], x -> orders[x] <> 0 ) do
    ev := ExponentsByObj( QS.Pccol, GetPower( QS.Pccol, i ));;
    ev[i] := - orders[i];;
    NQL_AddRow( HNF, ev{[b..n]} );
  od;

  # compute a matrix for our endomorphisms (of the multiplier)
  Endos := [];;
  for i in [ 1 .. Length( endos ) ] do 
    mat := [];;
    for j in [ b .. n ] do 
      ev := Exponents( Image( endos[i], GeneratorsOfGroup( H )[j] ) );;
      if not IsZero( ev{[1..b-1]} ) then 
        Error("endos are not endomorphisms of the multiplier");
      fi;
      Add( mat, ev{[b..n]} );;
    od;
    Add( Endos, mat );
  od;

  gens  := List( GensMult.IteratedGens, x -> Image( QS.Epimorphism, x ) );
  stack := List( gens, x -> Exponents( x ){[b..n]} );

  Append( gens, List( GensMult.FixedGens, x -> Image( QS.Epimorphism, x ) ) );
  gens  := Filtered( gens, y -> y <> One( H ) );;

  # use spinning for computing a generating set of the (f.r.) Schur multiplier
  while IsBound( stack[1] ) do
    for mat in Endos do
      ev := stack[1] * mat;;
      if NQL_AddRow( HNF, ev ) then 
        Add( gens, PcpElementByExponents( QS.Pccol, 
                   Concatenation( ListWithIdenticalEntries( b-1, 0 ), ev ) ));
        Add( stack, ev );
      fi;
    od;
    Remove( stack, 1 );
  od;

  return( Subgroup( H, gens ) );
  end);

############################################################################
##
#F  NQL_BuildCoveringGroup( <Q>, <ftl>, <HNF>, <weights>, <Defs>, <Imgs> )
##
## computes the covering group from a given quotient system
## 
InstallGlobalFunction( NQL_BuildCoveringGroup, 
  function( Q, ftl, HNF, weights, Defs, Imgs )
  local col,	# collector of the covering group
	c,	# nilpotency class of the covering group
	b,	# position of the first tail in the generating set of <ftl>
	Gens, 	# tails which are still generators
	orders,	# relative orders of <Q.Pccol>
	QS,	# quotient system of the covering group
	rhs,	# right-hand-side of a relation
	rhsTails,# tails on the right-hand-side of a relation
	endo,	# an endomorphism of the LpGroup-presentation
	i,j,k;	# loop variables

  # nilpotency class of the covering group
  c := Maximum( weights );
  
  # position of the first tails in the generating set of <ftl>
  b :=  Position( weights, c );

  # relative orders of <Q.Pccol>
  orders := RelativeOrders( Q.Pccol );

  # find non-trivial tails from <HNF>
  Gens := HNF.Heads{ Filtered( [1..Length(HNF.Heads)],
                               x -> HNF.mat[x][HNF.Heads[x]] <> 1 ) };
  Append( Gens, Filtered( [ 1..Length( Filtered( weights, x -> x = c ) ) ],
                           x -> not x in HNF.Heads));
  Sort( Gens );
  
  if Length( Gens ) = 0 then
    return( Q );
  fi;

  QS := rec( Pccol := FromTheLeftCollector( b-1 + Length(Gens) ), 
             Imgs  := [] );

  # restore the images (these tails are part of the free abelian complement)
  for i in [ 1..Length(Imgs) ] do 
    if IsPosInt( Imgs[i] ) then 
      QS.Imgs[i] := Imgs[i];
    else
      rhs      := ExponentsByObj( ftl, Imgs[i] );
      rhsTails := rhs{[b..Length(rhs)]};
      if rhsTails <> NQL_RowReduce( rhsTails, HNF ) then 
        Error("got torsion from a tail of a non-defining image");
      else 
        rhs := Concatenation( rhs{[1..b-1]}, rhsTails{Gens} );
      fi;
      QS.Imgs[i] := ObjByExponents(QS.Pccol, rhs );
    fi;
  od;

  # the weights and definitions of the new quotient system
  QS.Definitions := Concatenation( Defs{[1..b-1]}, Defs{Gens+(b-1)} );
  QS.Weights     := Concatenation( weights{[1..b-1]}, weights{Gens+(b-1)} );
  
  # the power relations of the quotient system <Q>
  for i in Filtered( [1..Length(orders)], x -> orders[x] <> 0 ) do 
    rhs      := ExponentsByObj( ftl, GetPower( ftl, i ) );
    rhsTails := rhs{ [ b..Length(rhs) ] };
    if weights[i] = 1 and rhsTails <> NQL_RowReduce( rhsTails, HNF ) then
       Error("got torsion from a tail of a power relation with weight 1");
    fi;
    rhs := Concatenation( rhs{[1..b-1]}, NQL_RowReduce( rhsTails, HNF ){Gens} );
    SetRelativeOrder( QS.Pccol, i, orders[i] );
    SetPower( QS.Pccol, i, ObjByExponents( QS.Pccol, rhs ) );
  od;

  # set the conjugacy relations 
  for i in [1..(b-1)-1] do 
    for j in [i+1..(b-1)] do 
      # a_j a_i = a_i a_j  u_{ij}^++
      rhs      := ExponentsByObj( ftl, GetConjugate( ftl, j, i ) );
      rhsTails := rhs{[b..Length(rhs)]};
      if not IsZero( rhsTails ) then 
        rhs := Concatenation( rhs{[1..b-1]}, 
                              NQL_RowReduce( rhsTails, HNF ){Gens});
      else
        rhs := Concatenation( rhs{[1..b-1]}, 0 * Gens );
      fi;
      SetConjugate( QS.Pccol, j, i, ObjByExponents( QS.Pccol, rhs ) );

      if orders[i] = 0 then 
        # a_j a_i^-1 = a_i^-1 a_j u_{ij}^{-+}
        rhs      := ExponentsByObj( ftl, GetConjugate( ftl, j, -i ) );
        rhsTails := rhs{[b..Length(rhs)]};
        if not IsZero( rhsTails ) then 
          rhs := Concatenation( rhs{[1..b-1]},
                                NQL_RowReduce( rhsTails, HNF ){Gens} );
        else 
          rhs := Concatenation( rhs{[1..b-1]}, 0 * Gens );
        fi;
        SetConjugate( QS.Pccol, j, -i, ObjByExponents( QS.Pccol, rhs ) );
       
        if orders[i] = 0 then 
          # a_j^-1 a_i^-1 = a_i^-1 a_j^-1 u_{ij}^{--}
          rhs      := ExponentsByObj( ftl, GetConjugate( ftl, -j, -i ) );
          rhsTails := rhs{[b..Length(rhs)]};
          if not IsZero( rhsTails ) then
            rhs := Concatenation( rhs{[1..b-1]},
                                  NQL_RowReduce( rhsTails, HNF ){Gens} );
          else
            rhs := Concatenation( rhs{[1..b-1]}, 0 * Gens );
          fi;
          SetConjugate( QS.Pccol, -j, -i, ObjByExponents( QS.Pccol, rhs ) );
        fi;
      elif orders[j] = 0 then 
        # a_j^-1 a_i = a_i a_j^-1 u_{ij}^{+-}
        rhs      := ExponentsByObj( ftl, GetConjugate( ftl, -j, i ) );
        rhsTails := rhs{[1..b-1]};
        if not IsZero( rhsTails ) then 
          rhs := Concatenation( rhs{[1..b-1]}, 
                                NQL_RowReduce( rhsTails, HNF ){Gens} );
        else
          rhs := Concatenation( rhs{[1..b-1]}, 0 * Gens );
        fi;
        SetConjugate( QS.Pccol, -j, i, ObjByExponents( QS.Pccol, rhs ) );
      fi;
    od;
  od;

  # power relations for the tails
  for i in Filtered( [1..Length(HNF.Heads)], 
                     x -> HNF.mat[x][ HNF.Heads[x] ] <> 1 ) do
    k := Position( Gens, HNF.Heads[i] );
    SetRelativeOrder( QS.Pccol, k + (b-1), HNF.mat[i][ HNF.Heads[i] ] );
    rhs := ListWithIdenticalEntries( Length(weights)-(b-1), 0 );
    rhs[ HNF.Heads[i] ] := HNF.mat[i][ HNF.Heads[i] ];
    rhs := Concatenation( ListWithIdenticalEntries( b-1, 0 ), 
                          NQL_RowReduce( rhs, HNF ){Gens} );
    SetPower( QS.Pccol, k+(b-1), ObjByExponents( QS.Pccol, rhs ) );
  od;

  FromTheLeftCollector_SetCommute( QS.Pccol );
  SetFeatureObj( QS.Pccol, IsUpToDatePolycyclicCollector, true );
  FromTheLeftCollector_CompleteConjugate( QS.Pccol );
  FromTheLeftCollector_CompletePowers( QS.Pccol );

  SetFeatureObj( QS.Pccol, IsUpToDatePolycyclicCollector, true );

  # build the epimorphism from the free group onto the cover
  Imgs := [];
  for i in [1..Length(QS.Imgs)] do
    if IsInt( QS.Imgs[i] ) then
      Imgs[i] := PcpElementByGenExpList( QS.Pccol, [ QS.Imgs[i], 1 ] );
    else
      Imgs[i] := PcpElementByGenExpList( QS.Pccol, QS.Imgs[i] );
    fi;
  od;
  QS.Epimorphism := GroupHomomorphismByImagesNC( FreeGroupOfLpGroup( Q.Lpres ), 
                         PcpGroupByCollectorNC( QS.Pccol ),
                         GeneratorsOfGroup( FreeGroupOfLpGroup( Q.Lpres ) ),
                         Imgs );

  return( QS );
  end);

############################################################################
##
#F  NQL_InduceEndosToCover( <LpGroup>, <int> )
##
## induces the endomorphisms of the invariant L-presentation of <LpGroup>
## to the covering group of the class-<int> quotient.
##
InstallGlobalFunction( NQL_InduceEndosToCover, 
  function( G, Endos, c )
  local QS,	# quotient system of the covering group of the class-c quotient
	endos,	# the induced endomorphisms
	endo,	# an endomorphism of the L-presentation
	Defs,	# definitions of generators
	H, 	# the covering group
	imgs,	# images of the generators
	obj,w,	# 
	Cov,	# covering groups of the nilpotent quotients
	i,j;	# loop variables
 
  # if we already induced the endomorphism to the cover
  if IsBound( CoveringGroups( G )[c].IndEndosOfCover ) then 
    return( CoveringGroups( G )[c].IndEndosOfCover ); 
  fi;

  # the quotient system of the covering group of the class-c quotient
  QS   := CoveringGroups( G )[c];
  H    := Range( QS.Epimorphism );
  Defs := QS.Definitions;

  endos := [];
  for endo in Endos do
    imgs := [];
    for i in [ 1 .. Length( Defs ) ] do
      if IsPosInt( Defs[i] ) and QS.Weights[i] = 1 then 
        # a generator of G/G'
        imgs[i] := Image( QS.Epimorphism, Image( endo, 
                          FreeGeneratorsOfLpGroup( G )[ Defs[i] ] ));
      elif IsPosInt( Defs[i] ) and QS.Weights[i] > 1 then 
        # a tail added to an image
        w := QS.Imgs[ Defs[i] ];
        if not w{ [ Length(w)-1, Length(w) ] } = [ i, 1 ] then
          Error("in inducing the endomorphisms to the cover");
        fi;
        obj := PcpElementByGenExpList( QS.Pccol, [] );
        for j in [ 1, 3 .. Length( w ) - 3 ] do 
          obj := obj * imgs[ w[j] ] ^ w[j+1];
        od;
        imgs[i] := obj ^ -1 * Image( QS.Epimorphism, Image( endo, 
                              FreeGeneratorsOfLpGroup( G )[ Defs[i] ] ) );
      elif IsInt( Defs[i] ) and Defs[i] < 0 then 
        if not IsBound( imgs[ -Defs[i] ] ) then 
           Error("in inducing the endomorphisms to the cover");
        fi;
        w := GetPower( QS.Pccol, - Defs[i] );
        if not w{ [ Length( w ) - 1, Length( w ) ] } = [ i, 1 ] then
          Error("in inducing the endomorphisms to the cover");
        fi;
        obj := PcpElementByGenExpList( QS.Pccol, [] );
        for j in [ 1, 3 .. Length(w) - 3 ] do 
          obj := obj * imgs[ w[j] ] ^ w[j+1];;
        od;
       
        imgs[i] := obj^-1 * 
                   imgs[ - Defs[i] ] ^ RelativeOrders( QS.Pccol )[ - Defs[i] ];
      elif IsList( Defs[i] ) then 
        if not ( IsBound( imgs[ Defs[i][1] ] ) and 
                 IsBound( imgs[ Defs[i][2] ] ) ) then 
           Error("in inducing the endomorphisms to the cover");
        fi;
        w := GetConjugate( QS.Pccol, Defs[i][1], Defs[i][2] );
        if not w{ [ Length( w ) - 1, Length( w ) ] } = [ i, 1 ] then
          Error("in inducing the endomorphisms to the cover");
        fi;
        obj := PcpElementByGenExpList( QS.Pccol, [] );
        for j in [ 3, 5 .. Length( w ) - 3 ] do 
          obj := obj * imgs[ w[j] ] ^ w[j+1];
        od;
        imgs[i] := obj^-1 * Comm( imgs[ Defs[i][1] ], imgs[ Defs[i][2] ] );
      fi;
    od;
    if not IsDenseList( imgs ) then 
      Error("in inducing the endomorphisms to the cover");
    fi;
 
    Add( endos, GroupHomomorphismByImagesNC( H, H, 
                GeneratorsOfGroup(H), imgs ));
  od;  

  # store the induced endomorphisms of the L-presentation 
  if Endos = EndomorphismsOfLpGroup( G ) then 
    Cov := ShallowCopy( CoveringGroups( G ) );
    Cov[c] := ShallowCopy( Cov[c] );
    Cov[c].IndEndosOfCover := endos;    
    ResetFilterObj( G, CoveringGroups );
    SetCoveringGroups( G, Cov );
  fi;

  return( endos );
  end);

############################################################################
##
#F  NQL_QSystemOfCoveringGroup( <QS> )
##
## computes a quotient system of the covering group.
##
InstallGlobalFunction( NQL_QSystemOfCoveringGroup,
  function( Q )
  local QS,	# quotient system of the covering group
	weights,# weight function
	Imgs,	# images of the free group generators
	Defs,	# definitions of the nilpotent presentation
	ftl, 	# FromTheLeftCollector of the covering group
	HNF,	# Hermite normal form from the consistency checks
	b,	# position of the new generators
	i;	# loop variable

  # definitions for the covering algorithm 
  weights := ShallowCopy( Q.Weights );
  Defs    := ShallowCopy( Q.Definitions );
  Imgs    := ShallowCopy( Q.Imgs );

  # compute a polycyclic presentation for the covering group
  ftl := NQL_QSystemOfCoveringGroupByQSystem( Q.Pccol, weights, Defs, Imgs);

  # use tails routine to complete the polycyclic presentation <ftl>
  UpdateNilpotentCollector( ftl, weights, Defs );

  # enforce consistency of the polycyclic presentation for the covering group
  b   := Position( weights, Maximum( weights ) );
  HNF := NQL_CheckConsistencyRelations( ftl, weights );
  for i in [ 1 .. Length( HNF.mat ) ] do 
    HNF.mat[i]   := HNF.mat[i]{[ b .. Length( weights ) ]};
    HNF.Heads[i] := HNF.Heads[i] - b + 1;
  od;

  # consistent polycyclic presentation for the covering group and epimorphism
  QS := NQL_BuildCoveringGroup( Q, ftl, HNF, weights, Defs, Imgs );
  QS.Lpres := Q.Lpres;
  if Q.Weights = QS.Weights then
    Info( InfoNQL, 1, "failed in computing the covering group");
    return( fail );
  else 
    return( QS );
  fi;

  end);

  
############################################################################
##
#M  EpimorphismCoveringGroups( <LpGroup>, <int1>, <int2> )
##
## computes an epimorphism from the covering group of the class-<int1> 
## quotient onto the covering group of the class-<int2> quotient.
##
InstallMethod( EpimorphismCoveringGroups,
  "for invariantly L-presented groups", true, 
  [ IsLpGroup and HasIsInvariantLPresentation and 
    IsInvariantLPresentation, IsPosInt, IsPosInt ], 0, 
  function( G, d, c ) 
  local Qc,Qd,	# quotient systems of the nilpotent quotients
  	QSc,QSd,# quotient systems of the covering groups
	gens,	# generators that will be mapped
	imgs,	# images of the generators of the cover
	pos,	# generators of <QSc> corresponding to a tail (of an image)
	Cov,	# list of quotient systems of the covering groups
	i;	# loop variable
  
  if d <= c then return( fail ); fi;

  if HasCoveringGroups( G ) then 
    if IsBound( CoveringGroups( G )[d] ) then 
      QSd := CoveringGroups( G )[d];
    else
      if HasNilpotentQuotientSystem( G ) and 
         Maximum( NilpotentQuotientSystem( G ).Weights ) > d then 
        Qd := SmallerQuotientSystem( NilpotentQuotientSystem( G ), d );
      else
        if NilpotencyClassOfGroup( NilpotentQuotient( G, d ) ) < d then 
          Info( InfoNQL, 1, "The group has a maximal nilpotent quotient of",
                            " class ", Maximum( Qd.Weights ) );
          return( fail );
        fi;
        Qd  := NilpotentQuotientSystem( G );
      fi;

      # compute a q-system of the covering group (of the class-d quotient)
      QSd := NQL_QSystemOfCoveringGroup( Qd );

      # store the new covering group
      Cov    := ShallowCopy( CoveringGroups( G ) );; 
      Cov[d] := QSd;
      ResetFilterObj( G, CoveringGroups );
      SetCoveringGroups( G, Cov );
    fi;

    if IsBound( CoveringGroups( G )[c] ) then 
      QSc := CoveringGroups( G )[c];
    else
      # rebuild the quotient system of the class-c quotient (already known)
      Qc := SmallerQuotientSystem( NilpotentQuotientSystem( G ), c );

      # compute a q-system of the covering group (of the class-d quotient)
      QSc := NQL_QSystemOfCoveringGroup( Qc );

      # store the new covering group
      Cov    := ShallowCopy( CoveringGroups( G ) );; 
      Cov[c] := QSc;
      ResetFilterObj( G, CoveringGroups );
      SetCoveringGroups( G, Cov );
    fi;
  else
    if HasNilpotentQuotientSystem( G ) and 
       Maximum( NilpotentQuotientSystem( G ).Weights ) > d then 
      Qc := SmallerQuotientSystem( NilpotentQuotientSystem( G ), c );
      Qd := SmallerQuotientSystem( NilpotentQuotientSystem( G ), d );
    else
      if NilpotencyClassOfGroup( NilpotentQuotient( G, d ) ) < d then
        Info( InfoNQL, 1, "The group has a maximal nilpotent quotient of",
                          " class ", Maximum( Qd.Weights ) );
        return( fail );
      fi;
      Qc := SmallerQuotientSystem( NilpotentQuotientSystem( G ), c );
      Qd := NilpotentQuotientSystem( G );
    fi;   

    # compute quotient systems for the covering groups
    QSc := NQL_QSystemOfCoveringGroup( Qc );
    QSd := NQL_QSystemOfCoveringGroup( Qd );
    Cov := []; Cov[c] := QSc;; Cov[d] := QSd;
    SetCoveringGroups( G, Cov );
  fi;

  # compute the images of generators using their definitions
  gens := [];
  imgs := [];
  for i in Filtered( [ 1 .. Length( QSd.Weights ) ], 
                     x -> IsPosInt( QSd.Definitions[x] ) and 
                          QSd.Weights[x] = 1 ) do
    if not QSc.Definitions[i] = QSd.Definitions[i] then   
      Error("in computing corresponding generators");
    fi;
    Add( gens, GeneratorsOfGroup( Range( QSd.Epimorphism ) )[i] );
    Add( imgs, GeneratorsOfGroup( Range( QSc.Epimorphism ) )[i] );
  od;
 
  # the tails added to a non-defining image
  for i in Filtered( [ 1 .. Length( QSd.Weights ) ], 
                     x -> IsPosInt( QSd.Definitions[x] ) and 
                          QSd.Weights[x] > 1 ) do
    pos := Position( QSc.Definitions, QSd.Definitions[i] ); 

    Add( gens, GeneratorsOfGroup( Range( QSd.Epimorphism ) )[i] );
    Add( imgs, GeneratorsOfGroup( Range( QSc.Epimorphism ) )[pos] );
  od;

  return( GroupHomomorphismByImagesNC( Range( QSd.Epimorphism ),
          Range( QSc.Epimorphism ), gens, imgs ) );
  end);

############################################################################
##
#M  EpimorphismFiniteRankSchurMultipliers( <LpGroup>, <int1>, <int2> )
##
## computes an epimorphism from the FiniteRankSchurMultiplier of the class-
## <int1> quotient onto the FiniteRankSchurMultiplier of the class-<int2>
## quotient by restricting `EpimorphismCoveringGroups'.
##
InstallMethod( EpimorphismFiniteRankSchurMultipliers,
  "for invariantly L-presented groups", true, 
  [ IsLpGroup and HasIsInvariantLPresentation and 
    IsInvariantLPresentation, IsPosInt, IsPosInt ], 0, 
  function( G, d, c ) 
  if d < c then
    Error( "epimorphism from ", d," onto ",c," Schur multiplier");
  fi;
  return( GroupHomomorphismByImagesNC( FiniteRankSchurMultiplier( G, d ),
          FiniteRankSchurMultiplier( G, c ),
          GeneratorsOfGroup( FiniteRankSchurMultiplier( G, d ) ),
          List( GeneratorsOfGroup( FiniteRankSchurMultiplier( G, d ) ),
                x -> Image( EpimorphismCoveringGroups( G, d, c ), x ) ) ) );
  end);


############################################################################
##
#F  ImageInFiniteRankSchurMultiplier( <LpGroup>, <int>, <elm> )
##
## computes the image of <elm> in the <int>-th finite rank Schur multiplier
## of <LpGroup>.
##
InstallGlobalFunction( ImageInFiniteRankSchurMultiplier,
  function( G, c, elm )
  local M,	# the <c>-th finite rank Schur multiplier
	QS,	# covering group of the class-<c> quotient
	img;	# image of <elm> in the covering group

  M   := FiniteRankSchurMultiplier( G, c );
  QS  := CoveringGroups( G )[c];
  img := Image( QS.Epimorphism, elm );
 
  if not img in M then 
    return( fail );
  else
    return( img );
  fi;
  end);

############################################################################
##
#M DwyerQuotient
##
InstallMethod( DwyerQuotient, 
    "for an LpGroup", true,
    [ IsLpGroup, IsPosInt ], 0, 
    function( G, c ) 
    return( FiniteRankSchurMultiplier( G, c ) );
    end );

InstallMethod( DwyerQuotient, 
    "for an arbitrary group", true,
    [ IsGroup, IsPosInt ], 0, 
    function( G, c ) 
    return( FiniteRankSchurMultiplier( Range( IsomorphismLpGroup( G ) ), c ) );
    end );
