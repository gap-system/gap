#############################################################################
##
#W  grp.gi                      GAP library                     Thomas Breuer
#W                                                               Frank Celler
#W                                                               Bettina Eick
#W                                                             Heiko Theissen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for groups.
##
Revision.grp_gi :=
    "@(#)$Id$";


ClosureSubgroup := OperationSubdomain( "ClosureSubgroup",
                           ClosureGroup, true );
ConjugateSubgroup := OperationSubdomain( "ConjugateSubgroup",
                             ConjugateGroup, IsCollsElms );


#############################################################################
##
#M  IsFinitelyGeneratedGroup( <G> ) . . test if a group is finitely generated
##
InstallImmediateMethod( IsFinitelyGeneratedGroup,
    IsGroup and HasGeneratorsOfGroup, 0,
    G -> Length( GeneratorsOfGroup( G ) ) < infinity );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
InstallImmediateMethod( IsCyclic, IsGroup and HasGeneratorsOfGroup, 0,
    function( G )
    if Length( GeneratorsOfGroup( G ) ) = 1 then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsCyclic,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )

    # if <G> is not commutative it is certainly not cyclic
    if not IsCommutative( G )  then
        return false;

    # if <G> is finite, test if the <p>-th powers of the generators
    # generate a subgroup of index <p> for all prime divisors <p>
    elif IsFinite( G )  then
        return ForAll( Set( FactorsInt( Size( G ) ) ),
                p -> Index( G, SubgroupNC( G,
                                 List( GeneratorsOfGroup( G ),g->g^p)) ) = p );

    # otherwise test if the abelian invariants are that of $Z$
    else
      return AbelianInvariants( G ) = [ 0 ];
    fi;
    end );


#############################################################################
##
#M  IsElementaryAbelian(<G>)  . . . . . test if a group is elementary abelian
##
InstallMethod( IsElementaryAbelian,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   isEla,      # 'true' if <G> is elementary abelian, result
            p;          # order of one generator of <G>

    # if <G> is not commutative it is certainly not elementary abelian
    if not IsCommutative( G )  then
        return false;

    # if <G> is trivial it is certainly elementary abelian
    elif IsTrivial( G )  then
        return true;

    # if <G> is infinite it is certainly not elementary abelian
    elif HasIsFinite( G ) and not IsFinite( G )  then
        return false;

    # otherwise compute the order of the first generator
    else
        p := Order( GeneratorsOfGroup( G )[1] );

        # if the order is not a prime <G> is certainly not elementary abelian
        if not IsPrime( p )  then
            return false;

        # otherwise test that all other generators have order <p>
        else
            return ForAll( GeneratorsOfGroup( G ), gen -> gen^p = One( G ) );
        fi;

    fi;
    end );


#############################################################################
##
#M  IsMonomialGroup( <G> )  . . . . . . . . . . . test if a group is monomial
##


#############################################################################
##
#M  IsNilpotentGroup( <G> ) . . . . . . . . . .  test if a group is nilpotent
##
#T InstallImmediateMethod( IsNilpotentGroup, IsGroup and HasSize, 10,
#T     function( G )
#T     G:= Size( G );
#T     if IsInt( G ) and IsPrimePowerInt( G ) then
#T       return true;
#T     fi;
#T     TryNextMethod();
#T     end );
#T This method does *not* fulfill the condition to be immediate,
#T factoring an integer may be expensive.
#T (Can we install a more restrictive method that *is* immediate,
#T for example one that checks only small integers?)

InstallMethod( IsNilpotentGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   S;          # lower central series of <G>

    # give a warning if the group is infinite
    if not IsFinite( G )  then
        Info( InfoWarning, 1,
              "IsNilpotentGroup: may not stop for infinite group <G>" );
    fi;

    # compute the lower central series
    S := LowerCentralSeriesOfGroup( G );

    # <G> is nilpotent if the lower central series reaches the trivial group
    return IsTrivial( S[ Length( S ) ] );
    end );


#############################################################################
##
#M  IsPerfectGroup( <G> ) . . . . . . . . . . . .  test if a group is perfect
##
InstallImmediateMethod( IsPerfectGroup,
    IsGroup and IsSolvableGroup and HasSize,
    0,
    grp -> Size( grp ) = 1 );

InstallMethod( IsPerfectGroup,
    "method for finite groups",
    true, [ IsGroup and IsFinite ], 0,
    G -> Index( G, DerivedSubgroup( G ) ) = 1 );

InstallMethod( IsPerfectGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> IsEmpty( AbelianInvariants( CommutatorFactorGroup( G ) ) ) );


#############################################################################
##
#M  IsSimpleGroup( <G> )  . . . . . . . . . . . . . test if a group is simple
##
InstallMethod( IsSimpleGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   C,          # one conjugacy class of <G>
            g;          # representative of <C>

    # loop over the conjugacy classes
    for C  in ConjugacyClasses( G )  do
        g := Representative( C );
        if g <> One( G )
            and NormalClosure( G, SubgroupNC( G, [ g ] ) ) <> G
        then
            return false;
        fi;
    od;

    # all classes generate the full group
    return true;
    end );


#############################################################################
##
#M  IsSolvableGroup( <G> )  . . . . . . . . . . . test if a group is solvable
##
##  For finite groups, supersolvability implies monomiality, and this implies
##  solvability.
##  But monomiality is defined only for finite groups, for the general case
##  we need the direct implication from supersolvability to solvability.
##
InstallImmediateMethod( IsSolvableGroup, IsGroup and HasSize, 10,
    function( G )
    G:= Size( G );
    if IsInt( G ) and G mod 2 = 1 then
      return true;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsSolvableGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   S;          # derived series of <G>

    # give a warning for infinite groups, where this may run forever
    if not IsFinite( G )  then
        Info( InfoWarning, 1,
              "IsSolvable: may not stop for infinite group <G>" );
    fi;

    # compute the derived series of <G>
    S := DerivedSeriesOfGroup( G );

    # the group is solvable if the derived series reaches the trivial group
    return IsTrivial( S[ Length( S ) ] );
    end );


#############################################################################
##
#M  IsSupersolvableGroup( <G> ) . . . . . .  test if a group is supersolvable
##
InstallMethod( IsSupersolvableGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> IsTrivial( SupersolvableResiduum( G ) ) );


#############################################################################
##
#M  IsTrivial( <G> )  . . . . . . . . . . . . . .  test if a group is trivial
##
InstallMethod( IsTrivial, true, [ IsGroup ], 0,
        G -> ForAll( GeneratorsOfGroup( G ), gen -> gen = One( G ) ) );
        

#############################################################################
##
#M  AbelianInvariants( <G> )  . . . . . . . . . abelian invariants of a group
##
InstallMethod( AbelianInvariants,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   H,  p,  l,  r,  i,  j,  gns,  inv,  ranks, g,  cmm;

    if not IsFinite(G)  then
        TryNextMethod();
    elif IsTrivial( G )  then
        return [];
    fi;

    gns := GeneratorsOfGroup( G );
    inv := [];
    cmm := DerivedSubgroup(G);
    for p  in Set( FactorsInt( Size( G ) ) )  do
        ranks := [];
        repeat
            H := cmm;
            for g  in gns  do
                H := ClosureSubgroup( H, g ^ p );
            od;
            r := Size(G) / Size(H);
            Info( InfoGroup, 2,
                  "AbelianInvariants: |<G>| = ", Size( G ),
                  ", |<H>| = ", Size( H ) );
            G   := H;
            gns := GeneratorsOfGroup( G );
            if r <> 1  then
                Add( ranks, Length(FactorsInt(r)) );
            fi;
        until r = 1;
        Info( InfoGroup, 2,
              "AbelianInvariants: <ranks> = ", ranks );
        if 0 < Length(ranks)  then
            l := List( [ 1 .. ranks[1] ], x -> 1 );
            for i  in ranks  do
                for j  in [ 1 .. i ]  do
                    l[j] := l[j] * p;
                od;
            od;
            Append( inv, l );
        fi;
    od;

    Sort( inv );
    return inv;
    end );


#############################################################################
##
#M  AsGroup( <D> ) . . . . . . . . . . . . . . .  domain <D>, viewed as group
##
InstallMethod( AsGroup, true, [ IsGroup ], 100, IdFunc );

InstallMethod( AsGroup,
    "generic method for collections",
    true, [ IsCollection ], 0,
    function ( D )
    local   G,  L;

    D := AsList( D );
    L := ShallowCopy( D );
    G := TrivialSubgroup( GroupByGenerators( D ) );
    SubtractSet( L, AsListSorted( G ) );
    while 0 < Length(L)  do
        G := ClosureGroupDefault( G, L[1] );
        SubtractSet( L, AsListSorted( G ) );
    od;
    if Length( AsList( G ) ) <> Length( D )  then
        Error( "the elements of <D> must form a group" );
    fi;
    G := GroupByGenerators( GeneratorsOfGroup( G ), D[1]^0 );
    SetAsListSorted( G, D );
    SetIsFinite( G, true );
    SetSize( G, Length( D ) );

    # return the group
    return G;
    end );


#############################################################################
##
#M  ChiefSeries( <G> )  . . . . . . . .  delegate to 'ChiefSeriesUnderAction'
##
InstallMethod( ChiefSeries,
    "method for a group (delegate to 'ChiefSeriesUnderAction'",
    true,
    [ IsGroup ], 0,
    G -> ChiefSeriesUnderAction( G, G ) );


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
InstallMethod( CommutatorFactorGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> FactorGroup( G, DerivedSubgroup( G ) ) );


#############################################################################
##
#M  CompositionSeries( <G> )  . . . . . . . . . . . composition series of <G>
##
InstallMethod( CompositionSeries,
    "using DerivedSubgroup",
    true,
    [ IsGroup and IsFinite ],
    0,

function( grp )
    local   der,  series,  i,  comp,  low,  elm,  pelm,  o,  p,  x,  
            j,  qelm;

    # this only works for solvable groups
    if HasIsSolvableGroup(grp) and not IsSolvableGroup(grp)  then
        TryNextMethod();
    fi;
    der := DerivedSeriesOfGroup(grp);
    if not IsTrivial(der[Length(der)])  then
        TryNextMethod();
    fi;

    # build up a series
    series := [ grp ];
    for i  in [ 1 .. Length(der)-1 ]  do
        comp := [];
        low  := der[i+1];
        while low <> der[i]  do
            repeat
                elm := Random(der[i]);
            until not elm in low;
            for pelm  in PrimePowerComponents(elm)  do
                o := Order(pelm);
                p := Factors(o)[1];
                x := LogInt(o,p);
                for j  in [ x-1, x-2 .. 0 ]  do
                    qelm := pelm ^ ( p^j );
                    if not qelm in low  then
                        Add( comp, low );
                        low := ClosureSubgroup( low, qelm );
                    fi;
                od;
            od;
        od;
        Append( series, Reversed(comp) );
    od;

    return series;
            
end );


#############################################################################
##
#M  ConjugacyClasses( <G> )
##

#############################################################################
##
#M  ConjugacyClassesMaximalSubgroups( <G> )
##


##############################################################################
##
#M  DerivedLength( <G> ) . . . . . . . . . . . . . . derived length of a group
##
InstallMethod( DerivedLength,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> Length( DerivedSeriesOfGroup( G ) ) - 1 );


#############################################################################
##
#M  DerivedSeriesOfGroup( <G> ) . . . . . . . . . . derived series of a group
##
InstallMethod( DerivedSeriesOfGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   S,          # derived series of <G>, result
            D;          # derived subgroups

    # print out a warning for infinite groups
    if not IsFinite( G )  then
      Info( InfoWarning, 1,
            "DerivedSeriesOfGroup: may not stop for infinite group <G>" );
    fi;

    # compute the series by repeated calling of 'DerivedSubgroup'
    S := [ G ];
    Info( InfoGroup, 2, "DerivedSeriesOfGroup: step ", Length(S) );
    D := DerivedSubgroup( G );
    while D <> S[ Length(S) ]  do
        Add( S, D );
        Info( InfoGroup, 2, "DerivedSeriesOfGroup: step ", Length(S) );
        D := DerivedSubgroup( D );
    od;

    # return the series when it becomes stable
    return S;
    end );

#############################################################################
##
#M  DerivedSubgroup( <G> )  . . . . . . . . . . . derived subgroup of a group
##
InstallMethod( DerivedSubgroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   D,          # derived subgroup of <G>, result
            gens,       # group generators of <G>
            i,  j,      # loops
            comm;       # commutator of two generators of <G>

    # find the subgroup generated by the commutators of the generators
    D := TrivialSubgroup( G );
    gens:= GeneratorsOfGroup( G );
    for i  in [ 2 .. Length( gens ) ]  do
        for j  in [ 1 .. i - 1 ]  do
            comm := Comm( gens[i], gens[j] );
            if not comm in D  then
                D := ClosureSubgroup( D, comm );
            fi;
        od;
    od;

    # return the normal closure of <D> in <G>
    D := NormalClosure( G, D );
    if D = G  then D := G;  fi;
    return D;
    end );

#T ##########################################################################
#T ##
#T #M  DimensionsLoewyFactors( <G> )  . . . . . . dimension of the Loewy factors
#T ##
#T InstallMethod( DimensionsLoewyFactors,
#T     "generic method for groups",
#T     true, [ IsGroup ], 0,
#T     function( G )
#T
#T     local   p,  J,  x,  P,  i,  s,  j;
#T
#T     # <G> must be a p-group
#T     if not IsFinite(G) or not IsPrimePowerInt(Size(G))  then
#T      Error( "<G> must be a p-group" );
#T     fi;
#T
#T     # get the prime and the Jennings series
#T     p := FactorsInt(Size(G))[1];
#T     J := JenningsSeries(G);
#T
#T     # construct the Jennings polynomial over the rationals
#T     x := X(Rationals);
#T     P := x^0;
#T     for i  in [ 1 .. Length(J)-1 ]  do
#T         s := 0*x;
#T         for j  in [ 0 .. p-1 ]  do
#T             s := s + x^(j*i);
#T         od;
#T         P := P * s^LogInt( Index( J[i], J[i+1] ), p );
#T     od;
#T
#T     # the coefficients are the dimension of the loewy series
#T     return ShiftedCoeffs( P.coefficients, P.valuation );
#T #T !!
#T     end );

#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
InstallOtherMethod( ElementaryAbelianSeries,
    "method for lists",
    true, [ IsList ], 0,
    function( G )

    local i, A, f;

    # if <G> is a list compute a elementary series through a given normal one
    if not IsSolvableGroup( G[1] )  then
      Error( "<G> must be solvable" );
    fi;
    for i  in [ 1 .. Length(G)-1 ]  do
      if not IsNormal(G[1],G[i+1]) or not IsSubgroup(G[i],G[i+1])  then
        Error( "<G> must be normal series" );
      fi;
    od;

    # convert all groups in that list
    f := IsomorphismPcGroup( G[ 1 ] );
    A := ElementaryAbelianSeries(List(G,x->Image(f,x)));

    # convert back into <G>
    return List( A, x -> PreImage( f, x ) );
    end );

InstallMethod( ElementaryAbelianSeries,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function( G )
    local f;

    # compute an elementary series if it is not known
    if not IsSolvableGroup( G )  then
      Error( "<G> must be solvable" );
    fi;

    f := IsomorphismPcGroup( G );

    # convert back into <G>
    return List( ElementaryAbelianSeries( Image( f ),
                   x -> PreImage( f, x ) ) );
    end );

#############################################################################
##
#M  Exponent( <G> ) . . . . . . . . . . . . . . . . . . . . . exponent of <G>
##
InstallMethod( Exponent,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> Lcm( List( ConjugacyClasses(G), x -> Order(Representative(x)) ) ) );

#############################################################################
##
#M  FittingSubgroup( <G> )  . . . . . . . . . . . Fitting subgroup of a group
##
InstallMethod( FittingSubgroup, true, [ IsGroup and IsTrivial ], 0, IdFunc );

InstallMethod( FittingSubgroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> SubgroupNC( G, Union( List( Set( FactorsInt( Size( G ) ) ),
                         p -> GeneratorsOfGroup( PCore( G, p ) ) ) ) ) );

#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
InstallMethod( FrattiniSubgroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> Intersection( List( ConjugacyClassesMaximalSubgroups( G ),
                             C -> Core( G, Representative(C) ) ) ) );


#############################################################################
##
#M  JenningsSeries( <G> ) . . . . . . . . . . .  jennings series of a p-group
##
InstallMethod( JenningsSeries,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function( G )

    local   p,  n,  i,  C,  L;

    # <G> must be a p-group
    if not IsFinite(G) or not IsPrimePowerInt(Size(G))  then
        Error( "<G> must be a p-group" );
    fi;

    # get the prime
    p := FactorsInt(Size(G))[1];

    # and compute the series
    L := [ G ];
    while not IsTrivial( L[Length(L)] )  do
        n := Length(L)+1;
        i := QuoInt( n+p-1, p );
        C := CommutatorSubgroup( L[n-1], G );
        L[n] := ClosureSubgroup( C, AgemoAbove( L[i], C, p ) );
    od;

    # and return
    return L;
    end );


#############################################################################
##
#M  LowerCentralSeriesOfGroup( <G> )  . . . . lower central series of a group
##
InstallMethod( LowerCentralSeriesOfGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   S,          # lower central series of <G>, result
            C;          # commutator subgroups

    # print out a warning for infinite groups
    if not IsFinite( G )  then
      Info( InfoWarning, 1,
          "LowerCentralSeriesOfGroup: may not stop for infinite group <G>" );
    fi;

    # compute the series by repeated calling of 'CommutatorSubgroup'
    S := [ G ];
    Info( InfoGroup, 2, "LowerCentralSeriesOfGroup: step ", Length(S) );
    C := DerivedSubgroup( G );
    while C <> S[ Length(S) ]  do
        Add( S, C );
        Info( InfoGroup, 2, "LowerCentralSeriesOfGroup: step ", Length(S) );
        C := CommutatorSubgroup( G, C );
    od;

    # return the series when it becomes stable
    return S;
    end );

#############################################################################
##
#M  MaximalSubgroups( <G> )
##

#############################################################################
##
#M  NrConjugacyClasses( <G> ) . . no. of conj. classes of elements in a group
##
InstallImmediateMethod( NrConjugacyClasses, IsGroup and HasConjugacyClasses,
    0,
    G -> Length( ConjugacyClasses( G ) ) );

InstallMethod( NrConjugacyClasses,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> Length( ConjugacyClasses( G ) ) );

#############################################################################
##
#M  Omega( <G> )  . . . . . . . . . . . . . . . . .  for an abelian $p$-group
##
#T the code should be cleaned,
#T especially one should avoid the many unnecessary calls of 'Difference'
##
InstallMethod( Omega,
    "method for a p-group (abelian)",
    true,
    [ IsGroup ], 0,
    function( G )

    local facts,  # prime factors of the size of 'G'
          p,      # unique prime divisor of the size of 'G'
          pcgs,   # PCGS of 'G'
          i, j, rel, rl, rc, ng, ml, mc, m, k, q,
          one;    # identity of 'G'

    if not IsAbelian( G ) then
      TryNextMethod();
    fi;
#T should be changed as soon as a generic method for p-groups is available.

    # Check that 'G' is a 'p'-group.
    facts:= Set( Factors( Size( G ) ) );
    if 1 < Length( facts ) then
      Error( "<G> must be a p-group" );
    fi;

    p:= facts[1];
    pcgs:= Pcgs( G );
    ng:= ShallowCopy( pcgs );

    # 'rel' is the relation matrix of 'G'.
    rel:= List( ng, x -> ShallowCopy( AdditiveInverse(
                             ExponentsOfPcElement( pcgs, x^p ) ) ) );
    for i in [ 1 .. Length( rel ) ] do
      rel[i][i]:= rel[i][i] + p;
    od;
    # rel:= List( ng, x -> List( ng, function(y) if x=y then return p;
    #           else return 0; fi; end)-ExponentsOfPcElement( ng, x^p ) );

    # rl, rc are the remaining lines and columns of rel to be used
    rl:= [ 1 .. Length( ng ) ];
    rc:= [ 1 .. Length( ng ) ];
    while 1 < Length( rl ) do

      # find empty column, find min entry
      m:= AbsInt( Maximum( rel[ rl[1] ] ) ) + 1;
      for i in rl do
        for j in rc do
          if rel[i][j] <> 0 and AbsInt( rel[i][j] ) < m then
            # 'rel[ml][mc]' is minimal entry of 'rel'
            ml:= i;
            mc:= j;
            m:= AbsInt( rel[i][j] );
          fi;
        od;
      od;
      while Maximum(List(Difference(rl,[ml]),x->AbsInt(rel[x][mc])))>0 do
        for i in Difference(rl,[ml]) do
          AddRowVector( rel[i], rel[ml], -QuoInt(rel[i][mc],rel[ml][mc]) );
          # rel[i]:=rel[i]-QuoInt(rel[i][mc],rel[ml][mc])*rel[ml];
        od;    
        # find min entry
        m:=AbsInt(Maximum(rel[rl[1]]))+1;
        for i in rl do
          for j in rc do
            if rel[i][j] <> 0 and AbsInt(rel[i][j]) < m then
              # rel[ml][mc] is minimal entry of rel
              ml:=i; mc:=j; m:=AbsInt(rel[i][j]);
            fi;
          od;
        od;
      od;
      for i in Difference(rc,[mc]) do
        q:= QuoInt(rel[ml][i],rel[ml][mc]);
        rel[ml][i]:= rel[ml][i] - q*rel[ml][mc];
        ng[mc]:=ng[mc]*ng[i]^q;
      od;
      if Maximum(List(Difference(rc,[mc]),x->AbsInt(rel[ml][x])))=0 then
        RemoveSet( rl, ml );
        RemoveSet( rc, mc );
      fi;
    od;

    # Construct the generators.
    m:= [];
    one:= One( G );
    for i in ng do
      if i <> one then
        Add( m, i^(Order(i)/p) );
      fi;
    od;

    return SubgroupNC( G, m );
    end );


#############################################################################
##
#M  RadicalGroup( <G> ) . . . . . . . . . . . . . . . . .  radical of a group
##
InstallMethod( RadicalGroup, true, [ IsGroup ], 0,
    function ( G )
    Error( "sorry, cannot compute the radical of <G>" );
    end );

InstallMethod( RadicalGroup, true, [ IsGroup and IsSolvableGroup ], 100,
    IdFunc );
#T ?

#############################################################################
##
#M  OrdersClassRepresentatives( <G> )
##
InstallMethod( OrdersClassRepresentatives,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> List( ConjugacyClasses( G ), c -> Order( Representative( c ) ) ) );


#############################################################################
##
#M  ComputedPCentralSeriess( <G> )
##
InstallMethod( ComputedPCentralSeriess, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  ComputedPRumps( <G> )
##
InstallMethod( ComputedPRumps, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  ComputedPCores( <G> )
##
InstallMethod( ComputedPCores, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  RationalClasses( <G> )
##

#############################################################################
##
#M  SizesCentralizers( <G> )
##
InstallMethod( SizesCentralizers,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> List( ConjugacyClasses( G ), c -> Size( G ) / Size( c ) ) );


#############################################################################
##
#M  SizesConjugacyClasses( <G> )
##
InstallMethod( SizesConjugacyClasses,
    "generic method for groups",
    true, [ IsGroup ], 0,
    G -> List( ConjugacyClasses( G ), Size ) );


#############################################################################
##
#M  GeneratorsSmallest( <G> ) . . . . . smallest generating system of a group
##
InstallMethod( GeneratorsSmallest,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   gens,       # smallest generating system of <G>, result
            gen,        # one generator of <gens>
            H;          # subgroup generated by <gens> so far

    # start with the empty generating system and the trivial subgroup
    gens := [];
    H := TrivialSubgroup( G );

    # loop over the elements of <G> in their order
    for gen  in EnumeratorSorted( G )  do

        # add the element not lying in the subgroup generated by the previous
        if not gen in H  then
            Add( gens, gen );
            H := ClosureSubgroup( H, gen );

            # it is important to know when to stop
            if Size( H ) = Size( G )  then
                return gens;
            fi;

        fi;

    od;

    if Size(G)=1 then
      # trivial subgroup case
      return [];
    fi;

    # well we should never come here
    Error( "panic, <G> not generated by its elements" );
    end );

#############################################################################
##
#M  SupersolvableResiduum( <G> )
##

#############################################################################
##
#M  ComplementSystem( <G> ) . . . . . Sylow complement system of finite group
##
InstallMethod( ComplementSystem,
    "generic method for finite groups",
    true,
    [ IsGroup and IsFinite ],
    0,

function( G )
    local pcgs, spec, weights, primes, comp, i, m, gens, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    pcgs := Pcgs( G );
    spec := SpecialPcgs( pcgs );
    weights := LGWeights( spec );
    primes := Set( List( weights, x -> x[3] ) );
    comp := List( primes, x -> false );
    for i in [1..Length( primes )] do
        gens := spec{Filtered( [1..Length(spec)], 
                     x -> weights[x][3] <> primes[i] )};
        sub  := InducedPcgsByPcSequenceNC( spec, gens );
        comp[i] := SubgroupByPcgs( G, sub );
    od;
    return comp;
end );


#############################################################################
##
#M  SylowSystem( <G> ) . . . . . . . . . . . . . Sylow system of finite group
##
InstallMethod( SylowSystem,
    "generic method for finite groups",
    true,
    [ IsGroup and IsFinite ],
    0,

function( G )
    local pcgs, spec, weights, primes, comp, i, m, gens, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    pcgs := Pcgs( G );
    spec := SpecialPcgs( pcgs );
    weights := LGWeights( spec );
    primes := Set( List( weights, x -> x[3] ) );
    comp := List( primes, x -> false );
    for i in [1..Length( primes )] do
        gens := spec{Filtered( [1..Length(spec)], 
                           x -> weights[x][3] = primes[i] )};
        sub  := InducedPcgsByPcSequenceNC( spec, gens );
        comp[i] := SubgroupByPcgs( G, sub );
    od;
    return comp;
end );

#############################################################################
##
#M  HallSystem( <G> ) . . . . . . . . . . . . . . Hall system of finite group
##
InstallMethod( HallSystem,
    "generic method for finite groups",
    true,
    [ IsGroup and IsFinite ],
    0,

function( G )
    local pcgs, spec, weights, primes, comp, i, m, gens, pis, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    pcgs := Pcgs( G );
    spec := SpecialPcgs( pcgs );
    weights := LGWeights( spec );
    primes := Set( List( weights, x -> x[3] ) );
    pis    := Combinations( primes );
    comp   := List( pis, x -> false );
    for i in [1..Length( pis )] do
        gens := spec{Filtered( [1..Length(spec)], 
                           x -> weights[x][3] in pis[i] )};
        sub  := InducedPcgsByPcSequenceNC( spec, gens );
        comp[i] := SubgroupByPcgs( G, sub );
    od;
    return comp;
end );

#############################################################################
##
#M  ComputedSylowSubgroups( <G> ) . . . . . . . list of known Sylow subgroups
##
InstallMethod( ComputedSylowSubgroups, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  ComputedSylowComplements( <G> ) . . . . . .list of known Sylow complement
##
InstallMethod( ComputedSylowComplements, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  ComputedHallSubgroups( <G> ) . . . . . . . . list of known Hall subgroups
##
InstallMethod( ComputedHallSubgroups, true, [ IsGroup ], 0,
    G -> [] );


#############################################################################
##
#M  UpperCentralSeriesOfGroup( <G> )  . . . . upper central series of a group
##
InstallMethod( UpperCentralSeriesOfGroup,
    "generic method for groups",
    true, [ IsGroup ], 0,
    function ( G )
    local   S,          # upper central series of <G>, result
            C,          # centre
            hom;        # homomorphisms of <G> to '<G>/<C>'

    # print out a warning for infinite groups
    if not IsFinite( G )  then
      Info( InfoWarning, 1,
          "UpperCentralSeriesOfGroup: may not stop for infinite group <G>");
    fi;

    # compute the series by repeated calling of 'CommutatorSubgroup'
    S := [ TrivialSubgroup( G ) ];
    Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
    C := Centre( G );
    while C <> S[ Length(S) ]  do
        Add( S, C );
        Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
        hom := NaturalHomomorphismByNormalSubgroup( G, C );
        C := PreImages( hom, Centre( Image( hom ) ) );
    od;

    # return the series when it becomes stable
    return Reversed( S );
    end );

#############################################################################
##
#M  Agemo( <G>, <p> ) . . . . . . . . . . . . . . .  agemo of a <p>-group <G>
#T why not attribute?
##
InstallMethod( Agemo,
    "generic method for groups",
    true, [ IsGroup, IsPosRat and IsInt ], 0,
    function( G, p )

    local   C;

    # <G> must be a <p>-group
    if 1 < Length(Set(FactorsInt(Size(G))))  then
        Error( "<G> must be a p-group" );
    fi;
    if Size(G) mod p <> 0  then
        Error( "<G> must be a <p>-group" );
    fi;

    # if <G> is abelian,  raise the generators to the p.th power
    if IsAbelian(G)  then
        return SubgroupNC( G, List( GeneratorsOfGroup( G ), x -> x^p ) );

    # otherwise compute the conjugacy classes of elements
    else
        C := Set( List( ConjugacyClasses(G), x -> Representative(x)^p ) );
        return NormalClosure( G, SubgroupNC( G, C ) );
    fi;
    end );


#############################################################################
##
#M  AgemoAbove( <G>, <C>, <p> ) . . . . . . . . . . . . . . . . . . . . local
##
AgemoAbove := function( G, C, p )
    local   A;

#T     # if we know the agemo,  return
#T     if HasAgemo( G )  then
#T         return Agemo( G );
#T     fi;
#T (is not an attribute...)

    # if the derived subgroup of <G> is contained in <C> it is easy
    if IsSubgroup( C, DerivedSubgroup(G) )  then
        return SubgroupNC( G, List( GeneratorsOfGroup( G ), x -> x^p ) );

    # otherwise use 'Agemo'
    else
        Info( InfoGroup, 2, "computing conjugacy classes for agemo" );
        return Agemo( G, p );
    fi;
end;

#############################################################################
##
#M  AsSubgroup( <G>, <U> )
##
InstallMethod( AsSubgroup,
    "generic method for groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, U )
    local S;
    if not IsSubset( G, U ) then
      Error( "<U> must be a subset of <G>" );
#T or fail?
    fi;
    S:= SubgroupNC( G, GeneratorsOfGroup( U ) );
    UseIsomorphismRelation( U, S );
    UseSubsetRelation( U, S );
    return S;
    end );


#############################################################################
##
#F  ClosureGroupDefault( <G>, <elm> ) . . . . . closure of group with element
##
ClosureGroupDefault := function( G, elm )

    local   C,          # closure '\< <G>, <obj> \>', result
            gens,       # generators of <G>
            gen,        # generator of <G> or <C>
            Celements,  # intermediate list of elements
            reps,       # representatives of cosets of <G> in <C>
            rep;        # representative of coset of <G> in <C>

    gens:= GeneratorsOfGroup( G );

    # try to avoid adding an element to a group that already contains it
    if   elm in gens
      or elm^-1 in gens
      or ( HasAsListSorted( G ) and elm in AsListSorted( G ) )
      or elm = One( G )
    then
        return G;
    fi;

    # make the closure group
    C:= GroupByGenerators( Concatenation( gens, [ elm ] ) );
    UseSubsetRelation( C, G );
    
    # if the elements of <G> are known then extend this list
    if HasAsListSorted( G ) then

        # if <G>^<elm> = <G> then <C> = <G> * <elm>
        if ForAll( gens, gen -> gen ^ elm in AsListSorted( G ) )  then
            Info( InfoGroup, 2, "new generator normalizes" );
            Celements := ShallowCopy( AsListSorted( G ) );
            rep := elm;
            while not rep in AsListSorted( G ) do
                Append( Celements, AsListSorted( G ) * rep );
                rep := rep * elm;
            od;
            SetAsListSorted( C, AsListSorted( Celements ) );
            SetIsFinite( C, true );
            SetSize( C, Length( Celements ) );

        # otherwise use a Dimino step
        else
            Info( InfoGroup, 2, "new generator normalizes not" );
            Celements := ShallowCopy( AsListSorted( G ) );
            reps := [ One( G ) ];
            Info( InfoGroup, 2, "   |<cosets>| = ", Length(reps) );
            for rep  in reps  do
                for gen  in GeneratorsOfGroup( C ) do
                    if not rep * gen in Celements  then
                        Append( Celements, AsListSorted( G ) * (rep * gen) );
                        Add( reps, rep * gen );
                        Info( InfoGroup, 2,
                              "   |<cosets>| = ", Length(reps) );
                    fi;
                od;
            od;
            SetAsListSorted( C, AsListSorted( Celements ) );
            SetIsFinite( C, true );
            SetSize( C, Length( Celements ) );

        fi;
    fi;

    # return the closure
    return C;
end;


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . . . .  default method for group and element
##
InstallMethod( ClosureGroup,
    "generic method for group and element",
    IsCollsElms, [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, elm )
    local   C,  gens;

    gens := GeneratorsOfGroup( G );

    # try to avoid adding an element to a group that already contains it
    if   elm in gens
      or elm^-1 in gens
      or ( HasAsListSorted( G ) and elm in AsListSorted( G ) )
      or elm = One( G )  then
        return G;
    fi;

    # make the closure group
    C := GroupByGenerators( Concatenation( gens, [ elm ] ) );
    UseSubsetRelation( C, G );
    
    # return the closure
    return C;
    end );


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . .  for group that contains the whole family
##
InstallMethod( ClosureGroup,
    "method for group that contains the whole family",
    IsCollsElms,
    [ IsGroup and IsWholeFamily, IsMultiplicativeElementWithInverse ],
    SUM_FLAGS,
    function( G, g )
    return G;
    end );


#############################################################################
##
#M  ClosureGroup( <G>, <U> )  . . . . . . . . . . closure of group with group
##
InstallMethod( ClosureGroup,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )

    local   C,   # closure '\< <G>, <H> \>', result
            gen; # generator of <G> or <C>

    C:= G;
    for gen in GeneratorsOfGroup( H ) do
      C:= ClosureGroup( C, gen );
    od;
    return C;
    end );

InstallMethod( ClosureGroup,
    "method for two groups, the bigger conatining the whole family",
    IsIdentical, [ IsGroup and IsWholeFamily, IsGroup ], 100,
    function( G, H )
    return G;
    end );
    
InstallMethod( ClosureGroup,
    "method for group and element list",
    IsIdentical,
    [ IsGroup,
      IsList and IsMultiplicativeElementWithInverseCollection ], 0,
    function( G, gens )
    local   gen;
    
    for gen  in gens  do
        G := ClosureGroup( G, gen );
    od;
    return G;
end );

InstallMethod( ClosureGroup,
    "method for group and empty element list",
    true,
    [ IsGroup,
      IsList and IsEmpty ], 0,
    function( G, nogens )
    return G;
end );

#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )  . . . . commutator subgroup of two groups
##
InstallMethod( CommutatorSubgroup,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( U, V )
    local   C, u, v, c;

    # [ <U>, <V> ] = normal closure of < [ <u>, <v> ] >.
    C := TrivialSubgroup( U );
    for u  in GeneratorsOfGroup( U ) do
        for v  in GeneratorsOfGroup( V ) do
            c := Comm( u, v );
            if not c in C  then
                C := ClosureSubgroup( C, c );
            fi;
        od;
    od;
    return NormalClosure( ClosureGroup( U, V ), C );
    end );

#############################################################################
##
#M  '\^( <G>, <g> )
##
InstallOtherMethod( \^,
    "generic method for groups and element",
    IsCollsElms,
    [ IsGroup,
      IsMultiplicativeElementWithInverse ],
    0,
    ConjugateGroup );

#############################################################################
##
#M  ConjugateGroup( <G>, <g> )
##
#T compat3.g ?
##
InstallMethod( ConjugateGroup, "<G>, <g>", IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
    function( G, g )
    local   H;

    H := GroupByGenerators( OnTuples( GeneratorsOfGroup( G ), g ), One(G) );
    UseIsomorphismRelation( G, H );
    return H;
end );

#############################################################################
##
#M  Core( <G>, <U> )  . . . . . . . . . . . . . core of a subgroup in a group
##
InstallMethod( Core,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, U )

    local   C,          # core of <U> in <G>, result
            i,          # loop variable
            gens;       # generators of 'G'

    Info( InfoGroup, 1,
          "Core: of ", GroupString(U,"U"), " in ", GroupString(G,"G") );

    # start with the subgroup <U>
    C := U;

    # loop until all generators normalize <C>
    i := 1;
    gens:= GeneratorsOfGroup( G );
    while i <= Length( gens )  do

        # if <C> is not normalized by this generator take the intersection
        # with the conjugate subgroup and start all over again
        if not ForAll( GeneratorsOfGroup( C ), gen -> gen ^ gens[i] in C ) then
            C := Intersection( C, C ^ gens[i] );
            Info( InfoGroup, 2, "Core: approx. is ",GroupString(C,"C") );
            i := 1;

        # otherwise try the next generator
        else
            i := i + 1;
        fi;

    od;

    # return the core
    Info( InfoGroup, 1, "Core: returns ", GroupString(C,"C") );
    return C;
    end );


#############################################################################
##
#M  FactorGroup( <G>, <N> )
#M  \/( <G>, <N> )
##
InstallMethod( FactorGroup,
    "generic method for two groups",
    IsIdentical,
    [ IsGroup, IsGroup ], 0,
    function( G, N )
    return ImagesSource( NaturalHomomorphismByNormalSubgroup( G, N ) );
    end );

InstallOtherMethod( \/,
    "generic method for two groups",
    IsIdentical,
    [ IsGroup, IsGroup ], 0,
    FactorGroup );


#############################################################################
##
#M  Index( <G>, <H> )
##
InstallMethod( Index,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )
    if not IsSubset( G, H ) then
      Error( "<H> must be contained in <G>" );
    fi;
    return Size( G ) / Size( H );
#T 'IndexNC' without check whether 'H' is really contained in 'G' ?
    end );

#############################################################################
##
#M  IsConjugate( <G>, <x>, <y> )
##

#############################################################################
##
#M  IsNormal( <G>, <U> )
##
InstallMethod( IsNormal,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )
    return ForAll(GeneratorsOfGroup(G),
             i->ForAll(GeneratorsOfGroup(H),j->j^i in H));
    end );

#############################################################################
##
#M  IsPNilpotent( <G>, <p> )
##

#############################################################################
##
#M  IsPSolvable( <G>, <p> )
##

#############################################################################
##
#M  IsSubgroup( <G>, <U> )
##
InstallOtherMethod( IsSubgroup,
    "generic method for two groups",
    true, [ IsGroup, IsObject ], 0,
    function( G, U ) return IsGroup( U ) and IsSubset( G, U ); end );
#T necessary at all?

#############################################################################
##
#F  RightTransversal( <G>, <U> )  . . . . . . . . . . . . . right transversal
##
InstallMethod( PrintObj, true, [ IsRightTransversal ], 0,
    function( cs )
    Print( "RightTransversal( ", cs!.group, ", ", cs!.subgroup, " )" );
end );

InstallMethod( Length, true, [ IsRightTransversal ], 0,
    t -> Index( t!.group, t!.subgroup ) );

#############################################################################
##
#M  IsSubnormal( <G>, <U> )
##

#############################################################################
##
#M  NormalClosure( <G>, <U> ) . . . . normal closure of a subgroup in a group
##
InstallMethod( NormalClosure,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, N )
    local   gensG,      # generators of the group <G>
            genG,       # one generator of the group <G>
            gensN,      # generators of the group <N>
            genN,       # one generator of the group <N>
            cnj;        # conjugated of a generator of <U>

    Info( InfoGroup, 1,
          "NormalClosure: of ", GroupString(N,"U"), " in ",
          GroupString(G,"G") );

    # get a set of monoid generators of <G>
    gensG := GeneratorsOfGroup( G );
    if not IsFinite( G )  then
        gensG := Concatenation( gensG, List( gensG, gen -> gen^-1 ) );
    fi;
    Info( InfoGroup, 2, " |<gens>| = ", Length( GeneratorsOfGroup( N ) ) );

    # loop over all generators of N
    gensN := ShallowCopy( GeneratorsOfGroup( N ) );
    for genN  in gensN  do

        # loop over the generators of G
        for genG  in gensG  do

            # make sure that the conjugated element is in the closure
            cnj := genN ^ genG;
            if not cnj in N  then
                Info( InfoGroup, 2,
                      " |<gens>| = ", Length( GeneratorsOfGroup( N ) ),
                      "+1" );
                N := ClosureGroup( N, cnj );
                Add( gensN, cnj );
            fi;

        od;

    od;

    # return the normal closure
    Info( InfoGroup, 1, "NormalClosure: returns ", GroupString(N,"N") );
    return N;
    end );

#############################################################################
##
#M  NormalIntersection( <G>, <U> )  . . . . . intersection with normal subgrp
##
InstallMethod( NormalIntersection,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H ) return Intersection2( G, H ); end );


#############################################################################
##
#M  Normalizer( <G>, <g> )
#M  Normalizer( <G>, <U> )
##
InstallMethod( Normalizer,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, U )
    local   N;          # normalizer of <U> in <G>, result

    Info( InfoGroup, 1,
          "Normalizer: of ", GroupString(U,"U"), " in ",
          GroupString(G,"G") );

    # both groups are in common undefined supergroup
    N:= Stabilizer( G, U, function(g,e)
                return GroupByGenerators(List(GeneratorsOfGroup(g),i->i^e),
                                         One(g));
            end);
#T or the following?
#T  N:= Stabilizer( G, U, ConjugateSubgroup );
#T (why to insist in the parent group?)

    # return the normalizer
    Info( InfoGroup, 1, "Normalizer: returns ", GroupString(N,"N") );
    return N;
    end );


#############################################################################
##
#M  NrConjugacyClassesInSupergroup( <U>, <H> )
##  . . . . . . .  number of conjugacy classes of <H> under the action of <U>
##
InstallMethod( NrConjugacyClassesInSupergroup,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( U, G )
    return Number( ConjugacyClasses( U ), C -> Representative( C ) in G );
    end );


#############################################################################
##
#F  PCentralSeries( <G>, <p> )
##
PCentralSeries := function( G, p )
    local known;
    if not IsGroup( G )  then
      Error( "<G> must be a group" );
    fi;
    if not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedPCentralSeriess( G );

    # compute the <p>-central series
    if not IsBound( known[p] )  then
      known[p] := PCentralSeriesOp( G, p );
    fi;

    # return the <p>-central series
    return known[p];
end;


#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
InstallMethod( PCentralSeriesOp,
    "generic method for group and prime",
    true, [ IsGroup, IsPosRat and IsInt ], 0,
    function( G, p )
    local   i,  L,  C,  S,  N,  P;

    # Start with <G>.
    L := [];
    N := G;
    repeat
        Add( L, N );
        S := N;
        C := CommutatorSubgroup( G, S );
        P := SubgroupNC( G, List( GeneratorsOfGroup( S ), x -> x ^ p ) );
        N := ClosureSubgroup( C, P );
    until N = S;
    return L;
    end );


#############################################################################
##
#F  PRump( <G>, <p> )
##
PRump := function( G, p )
    local known;
    if not IsGroup( G )  then
      Error( "<G> must be a group" );
    fi;
    if not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedPRumps( G );

    # compute the <p>-central series
    if not IsBound( known[p] )  then
      known[p] := PRumpOp( G, p );
    fi;

    # return the <p>-central series
    return known[p];
end;


#############################################################################
##
#M  PRumpOp( <G>, <p> )  
##
InstallMethod( PRumpOp,
    "generic method for group and prime",
    true, [ IsGroup, IsPosRat and IsInt ], 0,
function( G, p )
    local  C, gens, V;

    # Start with the derived subgroup of <G> and add <p>-powers.
    C := DerivedSubgroup( G );
    gens := Filtered( GeneratorsOfGroup( G ), x -> not x in C );
    gens := List( gens, x -> x ^ p );
    V := Subgroup( G, Union( GeneratorsOfGroup( C ), gens ) );
    return V;
end);

#############################################################################
##
#F  PCore( <G>, <p> )
##
PCore := function( G, p )
    local known;
    if not IsGroup( G )  then
      Error( "<G> must be a group" );
    fi;
    if not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedPCores( G );

    # compute the <p>-core
    if not IsBound( known[p] )  then
      known[p] := PCoreOp( G, p );
    fi;

    # return the <p>-core
    return known[p];
end;


#############################################################################
##
#M  PCoreOp( <G>, <p> ) . . . . . . . . . . . . . . . . . . p-core of a group
##
##  'PCore' returns the <p>-core of the group <G>, i.e., the  largest  normal
##  <p> subgroup of <G>.  This is the core of the <p> Sylow subgroups.
##
InstallMethod( PCoreOp,
    "generic method for group and prime",
    true, [ IsGroup, IsPosRat and IsInt ], 0,
    function ( G, p )
    return Core( G, SylowSubgroup( G, p ) );
    end );


#############################################################################
##
#M  Stabilizer( <G>, <obj>, <opr> )
#M  Stabilizer( <G>, <obj> )
##


#############################################################################
##
#M  SubnormalSeries( <G>, <U> ) . subnormal series from a group to a subgroup
##
InstallMethod( SubnormalSeries,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, U )
    local   S,          # subnormal series of <U> in <G>, result
            C;          # normal closure of <U> in <G> resp. <C>

    Info( InfoGroup, 1,
          "SubnormalSeries: of ", GroupString(U,"U"), " in ",
          GroupString(G,"G") );

    # compute the subnormal series by repeated calling of 'NormalClosure'
    #N 9-Dec-91 fceller: we could use a subnormal series of the parent
    S := [ G ];
    Info( InfoGroup, 2, "SubnormalSeries: step ", Length(S) );
    C := NormalClosure( G, U );
    while C <> S[ Length( S ) ]  do
        Add( S, C );
        Info( InfoGroup, 2, "SubnormalSeries: step ", Length(S) );
        C := NormalClosure( C, U );
    od;

    # return the series
    Info( InfoGroup, 1, "SubnormalSeries: returns series of length ",
                Length( S ) );
    return S;
    end );


#############################################################################
##
#M  SylowSubgroup( <G>, <p> ) . . . . . . . . . . . .compute a Sylow subgroup
##
SylowSubgroup := function( G, p )
    local known;
    if not IsGroup( G ) or not IsFinite( G )  then
      Error( "<G> must be a finite group" );
    fi;
    Info( InfoGroup, 1,
          "SylowSubgroup: ", GroupString(G,"G"), ", <p> = ", p );
    if not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedSylowSubgroups( G );

    # compute the Sylow <p> subgroup
    if not IsBound( known[p] )  then
      known[p] := SylowSubgroupOp( G, p );
    fi;

    # return the Sylow <p> subgroup
    Info( InfoGroup, 1,
          "SylowSubgroup: ", GroupString( known[p], "S" ) );
    return known[p];
end;

#############################################################################
##
#M  SylowComplement( <G>, <p> ) . . . . . . . . . .compute a Sylow complement
##
SylowComplement := function( G, p )
    local known;
    if not IsGroup( G ) or not IsFinite( G )  then
      Error( "<G> must be a finite group" );
    fi;
    if not IsInt( p ) or not IsPrimeInt( p )  then
      Error( "<p> must be a prime" );
    fi;

    known:= ComputedSylowComplements( G );

    # compute the <p>-complement 
    if not IsBound( known[p] )  then
      known[p] := SylowComplementOp( G, p );
    fi;

    # return the <p>-complement
    return known[p];
end;

#############################################################################
##
#M  HallSubgroup( <G>, <pi> ) . . . . . . . . . . . . compute a Hall subgroup
##
HallSubgroup := function( G, pi )
    local known;
    if not IsGroup( G ) or not IsFinite( G )  then
      Error( "<G> must be a finite group" );
    fi;
    if not IsList( pi ) then
      Error( "<pi> must be a list of primes" );
    fi;

    known:= ComputedHallSubgroups( G );

    # compute the Hall <pi> subgroup
    if not IsBound( known[Product(pi)] )  then
      known[Product(pi)] := HallSubgroupOp( G, pi );
    fi;

    # return the Hall <pi> subgroup
    return known[Product(pi)];
end;


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . . . . . . for a group and a prime
##
InstallMethod( SylowSubgroupOp,
    "generic method for group and prime",
    true, [ IsGroup, IsPosRat and IsInt ], 0,
    function ( G, p )
    local   S,          # Sylow <p> subgroup of <G>, result
            r,          # random element of <G>
            ord;        # order of 'r'

    # repeat until <S> is the full Sylow <p> subgroup
    S := TrivialSubgroup( G );
    while Size( G ) / Size( S ) mod p = 0  do

        # find an element of order <p> that normalizes <S>
        repeat
            repeat
                r := Random( G );
                ord:= Order( r );
            until ord mod p = 0;
            r := r ^ ( ord / p );
        until not r in S and ForAll( GeneratorsOfGroup( S ), g -> g ^ r in S );

        # add it to <S>
        S := ClosureSubgroup( S, r );

    od;

    # return the Sylow <p> subgroup
    return S;
    end );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . for a nilpotent group and a prime
##
InstallMethod( SylowSubgroupOp,
    "method for a nilpotent group, and a prime",
    true,
    [ IsGroup and IsNilpotentGroup, IsPosRat and IsInt ], 0,
    function( G, p )
    local gens, g, ord;

    gens:= [];
    for g in GeneratorsOfGroup( G ) do
      ord:= Order( g );
      if ord mod p = 0 then
        while ord mod p = 0 do
          ord:= ord / p;
        od;
        Add( gens, g^ord );
      fi;
    od;

    return SubgroupNC( G, gens );
    end );


#############################################################################
##
#M  \=( <G>, <H> )  . . . . . . . . . . . . . .  test if two groups are equal
##
InstallMethod( \=,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, H )
    if IsFinite( G )  then
      if IsFinite( H )  then
        return GeneratorsOfGroup( G ) = GeneratorsOfGroup( H )
               or IsEqualSet( GeneratorsOfGroup( G ), GeneratorsOfGroup( H ) )
               or (    Size( G ) = Size( H )
                   and ForAll( GeneratorsOfGroup( G ), gen -> gen in H ));
      else
        return false;
      fi;
    elif IsFinite( H )  then
      return false;
    else
      return GeneratorsOfGroup( G ) = GeneratorsOfGroup( H )
             or IsEqualSet( GeneratorsOfGroup( G ), GeneratorsOfGroup( H ) )
             or (    ForAll( GeneratorsOfGroup( G ), gen -> gen in H )
                 and ForAll( GeneratorsOfGroup( H ), gen -> gen in G ));
    fi;
    end );

#############################################################################
##
#M  IsCentral( <G>, <U> )  . . . . . . . . is a group centralized by another?
##
InstallMethod( IsCentral,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function ( G, U )
    local   Ggens,      # group generators of 'G'
            one,        # identity of 'U'
            g,          # one generator of <G>
            u;          # one generator of <U>

    # test if all generators of <U> are fixed by the generators of <G>
    Ggens:= GeneratorsOfGroup( G );
    one:= One( U );
    for u  in GeneratorsOfGroup( U ) do
        for g  in Ggens  do
            if Comm( u, g ) <> one then
                return false;
            fi;
        od;
    od;

    # all generators of <U> are fixed, return 'true'
    return true;
    end );
#T compare method in 'mgmgen.g'!

#############################################################################
##
#M  IsSubset( <G>, <H> ) . . . . . . . . . . . . .  test for subset of groups
##
InstallMethod( IsSubset,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )
    if GeneratorsOfGroup( G ) = GeneratorsOfGroup( H )
#T be more careful:
#T ask whether the entries of H-generators are found as identical
#T objects in G-generators
       or IsSubsetSet( GeneratorsOfGroup( G ), GeneratorsOfGroup( H ) ) then
      return true;
    elif IsFinite( G ) then
      if IsFinite( H ) then
        return     Size( G ) >= Size( H )
               and ForAll( GeneratorsOfGroup( H ), gen -> gen in G );
      else
        return false;
      fi;
    else
      return ForAll( GeneratorsOfGroup( H ), gen -> gen in G );
    fi;
    end );
#T is this really meaningful?


#############################################################################
##
#M  Intersection2( <G>, <H> ) . . . . . . . . . . . .  intersection of groups
##
InstallMethod( Intersection2,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )

#T use more parent info?
#T (if one of the arguments is the parent of the other, return the other?)

    # construct this group as stabilizer of a right coset
    if not IsFinite( G )  then
        return Stabilizer( H, RightCoset( G, One(G) ), OnRight );
    elif not IsFinite( H )  then
        return Stabilizer( G, RightCoset( H, One(H) ), OnRight );
    elif Size( G ) < Size( H )  then
        return Stabilizer( G, RightCoset( H, One(H) ), OnRight );
    else
        return Stabilizer( H, RightCoset( G, One(G) ), OnRight );
    fi;
    end );


#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . .  set of the elements of a group
#M  EnumeratorSorted( <G> ) . . . . . . . . .  set of the elements of a group
##
EnumeratorOfGroup := function( G )

    local   H,          # subgroup of the first generators of <G>
            gen;        # generator of <G>

    # start with the trivial group and its element list
    H:= TrivialSubgroup( G );
    SetAsListSorted( H, Immutable( [ One( G ) ] ) );

    # Add the generators one after the other.
    # We use a function that maintains the elements list for the closure.
    for gen in GeneratorsOfGroup( G ) do
      H:= ClosureGroupDefault( H, gen );
    od;

    # return the list of elements
    Assert( 2, HasAsListSorted( H ) );
    return AsListSorted( H );
end;

InstallMethod( Enumerator,
    "generic method for a group",
    true, [ IsGroup and IsAttributeStoringRep ], 0,
    EnumeratorOfGroup );

InstallMethod( EnumeratorSorted,
    "generic method for a group",
    true, [ IsGroup and IsAttributeStoringRep ], 0,
    EnumeratorOfGroup );


#############################################################################
##
#M  Centralizer( <G>, <elm> ) . . . . . . . . . . . .  centralizer of element
#M  Centralizer( <G>, <H> )   . . . . . . . . . . . . centralizer of subgroup
##
InstallMethod( Centralizer,
    "generic method for group and object",
    IsCollsElms, [ IsGroup, IsObject ], 0,
    function( G, elm )
    return Stabilizer( G, elm, OnPoints );
    end );

InstallMethod( Centralizer,
    "generic method for two groups",
    IsIdentical, [ IsGroup, IsGroup ], 0,
    function( G, H )

    local C,    # iterated stabilizer
          gen;  # one generator of subgroup <obj>

    C:= G;
    for gen in GeneratorsOfGroup( H ) do
      C:= Stabilizer( C, gen, OnPoints );
    od;
    return C;
    end );

#############################################################################
##
#F  IsomorphismTypeFiniteSimpleGroup( <G> ) . . . . . . . . . ismorphism type
##
IsomorphismTypeFiniteSimpleGroup := function (G)
    local   size,       # size of <G>
            size2,      # size of simple group
            p,          # dominant prime of <size>
            q,          # power of <p>
            m,          # <q> = <p>^<m>
            n,          # index, e.g., the $n$ in $A_n$
            g,          # random element of <G>
            C;          # centralizer of <g>

    # check that <G> is simple
    if IsGroup( G )  and not IsSimpleGroup( G )  then
        Error("<G> must be simple");
    fi;

    # grab the size of <G>
    if IsGroup( G )  then
        size := Size(G);
    elif IsInt( G )  then
        size := G;
    else
        Error("<G> must be a group or the size of a group");
    fi;

    # test if <G> is a cyclic group of prime size
    if IsPrime( size )  then
        return Concatenation( "Z(", String(size), ")" );
    fi;

    # test if <G> is A(5) ~ A(1,4) ~ A(1,5)
    if size = 60  then
        return Concatenation( "A(5) ",
                            "~ A(1,4) = L(2,4) ",
                            "~ B(1,4) = O(3,4) ",
                            "~ C(1,4) = S(2,4) ",
                            "~ 2A(1,4) = U(2,4) ",
                            "~ A(1,5) = L(2,5) ",
                            "~ B(1,5) = O(3,5) ",
                            "~ C(1,5) = S(2,5) ",
                            "~ 2A(1,5) = U(2,5)" );
    fi;

    # test if <G> is A(6) ~ A(1,9)
    if size = 360  then
        return Concatenation( "A(6) ",
                            "~ A(1,9) = L(2,9) ",
                            "~ B(1,9) = O(3,9) ",
                            "~ C(1,9) = S(2,9) ",
                            "~ 2A(1,9) = U(2,9)" );
    fi;

    # test if <G> is either A(8) ~ A(3,2) ~ D(3,2) or A(2,4)
    if size = 20160  then

        # check that <G> is a group
        if not IsGroup( G )  then
            return Concatenation( "cannot decide from size alone between ",
                                  "A(8) ",
                                "~ A(3,2) = L(4,2) ",
                                "~ D(3,2) = O+(6,2) ",
                                "and ",
                                  "A(2,4) = L(3,4) " );
        fi;

        # compute the centralizer of an element of order 5
        repeat
            g := Random(G);
        until Order(g) mod 5 = 0;
        g := g ^ (Order(g) / 5);
        C := Centralizer( G, g );

        # the centralizer in A(8) has size 15, the one in A(2,4) has size ...
        if Size(C) = 15 then
            return Concatenation( "A(8) ",
                                "~ A(3,2) = L(4,2) ",
                                "~ D(3,2) = O+(6,2)" );
        else
            return "A(2,4) = L(3,4)";
        fi;

    fi;

    # test if <G> is A(n)
    n := 6;  size2 := 360;
    repeat
        n := n + 1;  size2 := size2 * n;
    until size <= size2;
    if size = size2  then
        return Concatenation( "A(", String(n), ")" );
    fi;

    # test if <G> is one of the sporadic simple groups
    if size = 2^4 * 3^2 * 5 * 11  then
        return "M(11)";
    elif size = 2^6 * 3^3 * 5 * 11  then
        return "M(12)";
    elif size = 2^3 * 3 * 5 * 7 * 11 * 19  then
        return "J(1)";
    elif size = 2^7 * 3^2 * 5 * 7 * 11  then
        return "M(22)";
    elif size = 2^7 * 3^3 * 5^2 * 7  then
        return "HJ = J(2) = F(5-)";
    elif size = 2^7 * 3^2 * 5 * 7 * 11 * 23  then
        return "M(23)";
    elif size = 2^9 * 3^2 * 5^3 * 7 * 11  then
        return "HS";
    elif size = 2^7 * 3^5 * 5 * 17 * 19  then
        return "J(3)";
    elif size = 2^10 * 3^3 * 5 * 7 * 11 * 23  then
        return "M(24)";
    elif size = 2^7 * 3^6 * 5^3 * 7 * 11  then
        return "Mc";
    elif size = 2^10 * 3^3 * 5^2 * 7^3 * 17  then
        return "He = F(7)";
    elif size = 2^14 * 3^3 * 5^3 * 7 * 13 * 29  then
        return "Ru";
    elif size = 2^13 * 3^7 * 5^2 * 7 * 11 * 13  then
        return "Suz";
    elif size = 2^9 * 3^4 * 5 * 7^3 * 11 * 19 * 31  then
        return "ON";
    elif size = 2^10 * 3^7 * 5^3 * 7 * 11 * 23  then
        return "Co(3)";
    elif size = 2^18 * 3^6 * 5^3 * 7 * 11 * 23  then
        return "Co(2)";
    elif size = 2^17 * 3^9 * 5^2 * 7 * 11 * 13  then
        return "Fi(22)";
    elif size = 2^14 * 3^6 * 5^6 * 7 * 11 * 19  then
        return "HN = F(5) = F = F(5+)";
    elif size = 2^8 * 3^7 * 5^6 * 7 * 11 * 31 * 37 * 67  then
        return "Ly";
    elif size = 2^15 * 3^10 * 5^3 * 7^2 * 13 * 19 * 31  then
        return "Th = F(3) = E = F(3/3)";
    elif size = 2^18 * 3^13 * 5^2 * 7 * 11 * 13 * 17 * 23  then
        return "Fi(23)";
    elif size = 2^21 * 3^9 * 5^4 * 7^2 * 11 * 13 * 23  then
        return "Co(1) = F(2-)";
    elif size = 2^21 * 3^3 * 5 * 7 * 11^3 * 23 * 29 * 31 * 37 * 43  then
        return "J(4)";
    elif size = 2^21 * 3^16 * 5^2 * 7^3 * 11 * 13 * 17 * 23 * 29  then
        return "Fi(24) = F(3+)";
    elif size = 2^41*3^13*5^6*7^2*11*13*17*19*23*31*47  then
        return "B = F(2+)";
    elif size = 2^46*3^20*5^9*7^6*11^2*13^3*17*19*23*29*31*41*47*59*71  then
        return "M = F(1)";
    fi;

    # from now on we deal with groups of Lie-type

    # calculate the dominant prime of size
    q := Maximum( List( Collected( FactorsInt( size ) ), s -> s[1]^s[2] ) );
    p := FactorsInt( q )[1];

    # test if <G> is the Chevalley group A(1,7) ~ A(2,2)
    if size = 168  then
        return Concatenation( "A(1,7) = L(2,7) ",
                            "~ B(1,7) = O(3,7) ",
                            "~ C(1,7) = S(2,7) ",
                            "~ 2A(1,7) = U(2,7) ",
                            "~ A(2,2) = L(3,2)" );
    fi;

    # test if <G> is the Chevalley group A(1,8), where p = 3 <> char.
    if size = 504  then
        return Concatenation( "A(1,8) = L(2,8) ",
                            "~ B(1,8) = O(3,8) ",
                            "~ C(1,8) = S(2,8) ",
                            "~ 2A(1,8) = U(2,8)" );
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>-1), where p = 2 <> char.
    if    p = 2  and IsPrime(q-1)
      and size = (q-1) * ((q-1)^2-1) / Gcd(2,(q-1)-1)
    then
        return Concatenation( "A(",  "1", ",", String(q-1), ") ",
                            "= L(",  "2", ",", String(q-1), ") ",
                            "~ B(",  "1", ",", String(q-1), ") ",
                            "= O(",  "3", ",", String(q-1), ") ",
                            "~ C(",  "1", ",", String(q-1), ") ",
                            "= S(",  "2", ",", String(q-1), ") ",
                            "~ 2A(", "1", ",", String(q-1), ") ",
                            "= U(",  "2", ",", String(q-1), ")" );
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>), where p = 2^<k>+1 <> char.
    if    p <> 2  and IsPrimePowerInt( p-1 )
      and size = (p-1) * ((p-1)^2-1) / Gcd(2,(p-1)-1)
    then
        return Concatenation( "A(",  "1", ",", String(p-1), ") ",
                            "= L(",  "2", ",", String(p-1), ") ",
                            "~ B(",  "1", ",", String(p-1), ") ",
                            "= O(",  "3", ",", String(p-1), ") ",
                            "~ C(",  "1", ",", String(p-1), ") ",
                            "= S(",  "2", ",", String(p-1), ") ",
                            "~ 2A(", "1", ",", String(p-1), ") ",
                            "= U(",  "2", ",", String(p-1), ")" );
    fi;

    # try to find <n> and <q> for size of A(n,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        n := 0;
        repeat
            n := n + 1;
            size2 := q^(n*(n+1)/2)
                   * Product( [2..n+1], i -> q^i-1 ) / Gcd(n+1,q-1);
        until size <= size2;
    until size = size2 or n = 1;

    # test if <G> is a Chevalley group A(1,q) ~ B(1,q) ~ C(1,q) ~ 2A(1,q)
    # non-simple: A(1,2) ~ S(3), A(1,3) ~ A(4),
    # exceptions: A(1,4) ~ A(1,5) ~ A(5), A(1,7) ~ A(2,2), A(1,9) ~ A(6)
    if n = 1  and size = size2  then
        return Concatenation( "A(", "1", ",", String(q), ") ",
                            "= L(", "2", ",", String(q), ") ",
                            "~ B(", "1", ",", String(q), ") ",
                            "= O(", "3", ",", String(q), ") ",
                            "~ C(", "1", ",", String(q), ") ",
                            "= S(", "2", ",", String(q), ") ",
                            "~ 2A(","1", ",", String(q), ") ",
                            "= U(", "2", ",", String(q), ")" );
    fi;

    # test if <G> is a Chevalley group A(3,q) ~ D(3,q)
    # exceptions: A(3,2) ~ A(8)
    if n = 3  and size = size2  then
        return Concatenation( "A(", "3", ",", String(q), ") ",
                            "= L(", "4", ",", String(q), ") ",
                            "~ D(", "3", ",", String(q), ") ",
                            "= O+(","6", ",", String(q), ") " );
    fi;

    # test if <G> is a Chevalley group A(n,q)
    if size = size2  then
        return Concatenation( "A(", String(n),   ",", String(q), ") ",
                            "= L(", String(n+1), ",", String(q), ") " );
    fi;

    # try to find <n> and <q> for size of B(n,q) = size of C(n,q)
    # exceptions: B(1,q) ~ A(1,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        n := 1;
        repeat
            n := n + 1;
            size2 := q^(n^2)
                   * Product( [1..n], i -> q^(2*i)-1 ) / Gcd(2,q-1);
        until size <= size2;
    until size = size2  or n = 2;

    # test if <G> is a Chevalley group B(2,3) ~ C(2,3) ~ 2A(3,2) ~ 2D(3,2)
    if n = 2  and q = 3  and size = size2  then
        return Concatenation( "B(2,3) = O(5,3) ",
                            "~ C(2,3) = S(4,3) ",
                            "~ 2A(3,2) = U(4,2) ",
                            "~ 2D(3,2) = O-(6,2)" );
    fi;

    # test if <G> is a Chevalley group B(2,q) ~ C(2,q)
    # non-simple: B(2,2) ~ S(6)
    if n = 2  and size = size2  then
        return Concatenation( "B(", "2", ",", String(q), ") ",
                            "= O(", "5", ",", String(q), ") ",
                            "~ C(", "2", ",", String(q), ") ",
                            "= S(", "4", ",", String(q), ")" );
    fi;

    # test if <G> is a Chevalley group B(n,2^m) ~ C(n,2^m)
    # non-simple: B(2,2) ~ S(6)
    if p = 2  and size = size2  then
        return Concatenation( "B(", String(n),     ",", String(q), ") ",
                            "= O(", String(2*n+1), ",", String(q), ") ",
                            "~ C(", String(n),     ",", String(q), ") ",
                            "= S(", String(2*n),   ",", String(q), ")" );
    fi;

    # test if <G> is a Chevalley group B(n,q) or C(n,q), 2 < n and q odd
    if p <> 2  and size = size2  then

        # check that <G> is a group
        if not IsGroup( G )  then
            return Concatenation( "cannot decide from size alone between ",
                                  "B(", String(n),     ",", String(q), ") ",
                                "= O(", String(2*n+1), ",", String(q), ") ",
                                "and ",
                                  "C(", String(n),   ",", String(q), ") ",
                                "= S(", String(2*n), ",", String(q), ")" );
        fi;

        # find a <p>-central element and its centralizer
        C := Centre(SylowSubgroup(G,p));
        repeat
            g := Random(C);
        until Order(g) = p;
        C := Centralizer(G,g);

        if Size(C) mod (q^(2*n-2)-1) <> 0 then
            return Concatenation( "B(", String(n),     ",", String(q), ") ",
                                "= O(", String(2*n+1), ",", String(q), ")" );
        else
            return Concatenation( "C(", String(n),   ",", String(q), ") ",
                                "= S(", String(2*n), ",", String(q), ")" );
        fi;

    fi;

    # test if <G> is a Chevalley group D(n,q)
    # non-simple: D(2,q) ~ A(1,q)xA(1,q)
    # exceptions: D(3,q) ~ A(3,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        n := 3;
        repeat
            n := n + 1;
            size2 := q^(n*(n-1)) * (q^n-1)
                   * Product([1..n-1],i->q^(2*i)-1) / Gcd(4,q^n-1);
        until size <= size2;
    until size = size2  or n = 4;
    if size = size2  then
        return Concatenation( "D(",  String(n),   ",", String(q), ") ",
                            "= O+(", String(2*n), ",", String(q), ")" );
    fi;

    # test whether <G> is an exceptional Chevalley group E(6,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^36 * (q^12-1)*(q^9-1)*(q^8-1)
                      *(q^6-1)*(q^5-1)*(q^2-1) / Gcd(3,q-1);
    until size <= size2;
    if size = size2 then
        return Concatenation( "E(", "6", ",", String(q), ")" );
    fi;

    # test whether <G> is an exceptional Chevalley group E(7,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^63 * (q^18-1)*(q^14-1)*(q^12-1)*(q^10-1)
                      *(q^8-1)*(q^6-1)*(q^2-1) / Gcd(2,q-1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "E(", "7", ",", String(q), ")" );
    fi;

    # test whether <G> is an exceptional Chevalley group E(8,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^120 * (q^30-1)*(q^24-1)*(q^20-1)*(q^18-1)
                       *(q^14-1)*(q^12-1)*(q^8-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "E(", "8", ",", String(q), ")" );
    fi;

    # test whether <G> is an exceptional Chevalley group F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^24 * (q^12-1)*(q^8-1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "F(4,", String(q), ")" );
    fi;

    # test whether <G> is an exceptional Chevalley group G(2,q)
    # exceptions: G(2,2) ~ U(3,3).2
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^6 * (q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "G(", "2", ",", String(q), ")" );
    fi;

    # test if <G> is 2A(2,3), where p = 2 <> char.
    if size = 3^3*(3^2-1)*(3^3+1)  then
        return "2A(2,3) = U(3,3)";
    fi;

    # try to find <n> and <q> for size of 2A(n,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        n := 1;
        repeat
            n := n + 1;
            size2 := q^(n*(n+1)/2)
                   * Product([2..n+1],i->q^i-(-1)^i) / Gcd(n+1,q+1);
        until size <= size2;
    until size = size2  or n = 2;

    # test if <G> is a Steinberg group 2A(3,q) ~ 2D(3,q)
    # excetions: 2A(3,2) ~ B(2,3) ~ C(2,3)
    if n = 3  and size = size2  then
        return Concatenation( "2A(", "3", ",", String(q), ") ",
                            "= U(",  "4", ",", String(q), ") ",
                            "~ 2D(", "3", ",", String(q), ") ",
                            "= O-(", "6", ",", String(q), ")" );
    fi;

    # test if <G> is a Steinberg group 2A(n,q)
    # non-simple: 2A(2,2) ~ 3^2 . Q(8)
    if size = size2  then
        return Concatenation( "2A(", String(n),   ",", String(q), ") ",
                            "= U(",  String(n+1), ",", String(q), ")" );
    fi;

    # test whether <G> is a Suzuki group 2B(2,q) = 2C(2,q) = Sz(q)
    # non-simple: 2B(2,2) = 5:4
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^2 * (q^2+1)*(q-1);
    until size <= size2;
    if p = 2  and m mod 2 = 1  and size = size2  then
        return Concatenation( "2B(", "2", ",", String(q), ") ",
                            "= 2C(", "2", ",", String(q), ") ",
                            "= Sz(",           String(q), ")" );
    fi;

    # test whether <G> is a Steinberg group 2D(n,q)
    # exceptions: 2D(3,q) ~ 2A(3,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        n := 3;
        repeat
            n := n + 1;
            size2 := q^(n*(n-1)) * (q^n+1)
                   * Product([1..n-1],i->q^(2*i)-1) / Gcd(4,q^n+1);
        until size <= size2;
    until size = size2  or n = 4;
    if size = size2  then
        return Concatenation( "2D(", String(n),   ",", String(q), ") ",
                            "= O-(", String(2*n), ",", String(q), ")" );
    fi;

    # test whether <G> is a Steinberg group 3D4(q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^8+q^4+1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "3D(", "4", ",", String(q), ")" );
    fi;


    # test whether <G> is a Steinberg group 2E6(q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^36 * (q^12-1)*(q^9+1)*(q^8-1)
                       *(q^6-1)*(q^5+1)*(q^2-1) / Gcd(3,q+1);
    until size <= size2;
    if size = size2  then
        return Concatenation( "2E(", "6", ",", String(q), ")" );
    fi;

    # test if <G> is the Ree group 2F(4,q)'
    if size = 2^12 * (2^6+1)*(2^4-1)*(2^3+1)*(2-1) / 2  then
        return "2F(4,2) = Ree(2)' = Tits";
    fi;

    # test whether <G> is a Ree group 2F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^6+1)*(q^4-1)*(q^3+1)*(q-1);
    until size <= size2;
    if p = 2  and 1 < m  and m mod 2 = 1  and size = size2  then
        return Concatenation( "2F(", "4", ",", String(q), ") ",
                           "= Ree(",           String(q), ")" );
    fi;

    # test whether <G> is a Ree group 2G(2,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^3 * (q^3+1)*(q-1);
    until size <= size2;
    if p = 3  and 1 < m  and m mod 2 = 1  and size = size2  then
        return Concatenation( "2G(", "2", ",", String(q), ") ",
                           "= Ree(",           String(q), ")" );
    fi;

    # or a new simple group is found
    return "A new simple group, whoaw";
end;

#############################################################################
##
#M  PrintObj( <G> )
##
InstallMethod( PrintObj, true, [ IsGroup and HasGeneratorsOfGroup ], 0,
    function( G )
    Print( "Group( ", GeneratorsOfGroup( G ), ", ... )" );
    end );

InstallMethod( PrintObj, true, [ IsGroup ], 0,
    function( G )
    Print( "Group( ... )" );
    end );


#############################################################################
##
#M  GroupByGenerators( <gens> ) . . . . . . . . . . . . . group by generators 
#M  GroupByGenerators( <gens>, <id> )
##
InstallMethod( GroupByGenerators,
    "generic method for collection",
    true, [ IsCollection ] , 0,
    function( gens )
    local G;
    G:= Objectify( NewType( FamilyObj( gens ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, AsList( gens ) );
    RunGroupMethods( gens, G );
    return G;
    end );

InstallOtherMethod( GroupByGenerators,
    "generic method for collection and element",
    IsCollsElms, [ IsCollection, IsMultiplicativeElementWithInverse ], 0,
    function( gens, id )
    local G;
    G:= Objectify( NewType( FamilyObj( gens ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, AsList( gens ) );
    SetOne( G, id );
    if IsEmpty(gens)  then
        RunGroupMethods( [id], G );
    else
        RunGroupMethods( gens, G );
    fi;
    return G;
    end );

InstallOtherMethod( GroupByGenerators,
    "method for empty list and element",
    true, [ IsList and IsEmpty, IsMultiplicativeElementWithInverse ], 0,
    function( empty, id )
    local G;
    G:= Objectify( NewType( CollectionsFamily( FamilyObj( id ) ),
                            IsGroup and IsAttributeStoringRep ),
                   rec() );
    SetGeneratorsOfMagmaWithInverses( G, [] );
    SetOne( G, id );
    RunGroupMethods( [id], G );
    return G;
    end );


#############################################################################
##
#M  IsCommutative( <G> ) . . . . . . . . . . . . . test if a group is abelian
##
InstallMethod( IsCommutative,
    "generic method for groups",
    true, [ IsGroup ], 0,
    IsCommutativeFromGenerators( GeneratorsOfGroup ) );


#############################################################################
##
#F  Group( <gen>, ... )
#F  Group( <gens>, <id> )
##
Group := function( arg )

    if Length( arg ) = 1 and IsDomain( arg[1] ) then
      Error( "no longer supported ..." );
#T this was possible in GAP-3 ...

    # special case for matrices, because they may look like lists
    elif Length( arg ) = 1 and IsMatrix( arg[1] ) then
      return GroupByGenerators( arg );

    # special case for matrices, because they may look like lists
    elif Length( arg ) = 2 and IsMatrix( arg[1] ) then
      return GroupByGenerators( arg );

    # list of generators
    elif Length( arg ) = 1 and IsList( arg[1] ) and 0 < Length( arg[1] ) then
      return GroupByGenerators( arg[1] );

    # list of generators plus identity
    elif Length( arg ) = 2 and IsList( arg[1] ) then
      return GroupByGenerators( arg[1], arg[2] );

    # generators
    elif 0 < Length( arg ) then
      return GroupByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: Group(<gen>,...), Group(<gens>), Group(<D>)");
end;


#############################################################################
##
#F  Subgroup( <G>, <gens> ) . . . . . . . subgroup of <G> generated by <gens>
#F  SubgroupNC( <G>, <gens> )
##
Subgroup := SubmagmaWithInverses;

SubgroupNC := SubmagmaWithInversesNC;


#############################################################################
##
#M  PrimePowerComponents( <g> )
##
InstallMethod( PrimePowerComponents,
    "generic method",
    true,
    [ IsMultiplicativeElement ],
    0,

function( g )
    local o, f, p, x, q, r, gcd, split; 

    # catch the trivial case
    o := Order( g );
    if o = 1 then return []; fi;

    # start to split
    f := FactorsInt( o );
    if Length( Set( f ) ) = 1  then
        return [ g ];
    else
        p := f[1];
        x := Length( Filtered( f, y -> y = p ) );
        q := p ^ x;
        r := o / p;
        gcd := Gcdex ( q, r );
        split := PrimePowerComponents( g ^ (gcd.coeff1 * q) );
        return Concatenation( split, [ g ^ (gcd.coeff2 * r) ] );
    fi;
end );


#############################################################################
##
#M  PrimePowerComponent( <g>, <p> )
##
InstallMethod( PrimePowerComponent,
    "generic method",
    true,
    [ IsMultiplicativeElement,
      IsInt and IsPosRat ],
    0,

function( g, p )
    local o, f, x, q, r, gcd;

    o := Order( g );
    if o = 1 then return g; fi;

    f := FactorsInt( o );
    x := Length( Filtered( f, x -> x = p ) );
    if x = 0 then return g^o; fi;
    
    q := p ^ x;
    r := o / q;
    gcd := Gcdex( q, r );
    return g ^ (gcd.coeff2 * r);
end );

#############################################################################
##
#M  \.   Access to generators
##
InstallMethod(\.,"group generators",true,[IsGroup,IsPosRat and IsInt],0,
function(g,n)
  g:=GeneratorsOfGroup(g);
  n:=NameRNam(n);
  n:=Int(n);
  if n=fail or Length(g)<n then
    TryNextMethod();
  fi;
  return g[n];
end);

#############################################################################
##
#M  ``in parent'' attributes
##
InstallInParentMethod( CoreInParent,             IsGroup, Core             );
InstallInParentMethod( IndexInParent,            IsGroup, Index            );
InstallInParentMethod( IsNormalInParent,         IsGroup, IsNormal         );
InstallInParentMethod( NormalClosureInParent,    IsGroup, NormalClosure    );
InstallInParentMethod( NormalizerInParent,       IsGroup, Normalizer       );
InstallInParentMethod( RightTransversalInParent, IsGroup, RightTransversal );
InstallInParentMethod( SubnormalSeriesInParent,  IsGroup, SubnormalSeries  );


#############################################################################
##
#F  NormalSubgroups( <G> )  . . . . . . . . . . . normal subgroups of a group
##
NormalSubgroupsAbove:=function (G,N,avoid)
local   R,         # normal subgroups above <N>,result
	C,         # one conjugacy class of <G>
	g,         # representative of a conjugacy class of <G>
	M;          # normal closure of <N> and <g>

    # initialize the list of normal subgroups
    Info(InfoGroup,1,"normal subgroup of order ",Size(N));
    R:=[N];

    # make a shallow copy of avoid,because we are going to change it
    avoid:=ShallowCopy(avoid);

    # for all representative that need not be avoided and do not ly in <N>
    for C  in ConjugacyClasses(G)  do
        g:=Representative(C);

        if not g in avoid  and not g in N  then

            # compute the normal closure of <N> and <g> in <G>
            M:=NormalClosure(G,ClosureGroup(N,g));
            if ForAll(avoid,rep -> not rep in M)  then
                Append(R,NormalSubgroupsAbove(G,M,avoid));
            fi;

            # from now on avoid this representative
            Add(avoid,g);
        fi;
    od;

    # return the list of normal subgroups
    return R;

end;

InstallMethod(NormalSubgroups,"generic class union",true,[IsGroup],0,
function (G)
local nrm;        # normal subgroups of <G>,result

    # compute the normal subgroup lattice above the trivial subgroup
    nrm:=NormalSubgroupsAbove(G,TrivialSubgroup(G),[]);

    # sort the normal subgroups according to their size
    Sort(nrm,function(a,b) return Size(a) < Size(b); end);

    # and return it
    return nrm;

end);


##############################################################################
##
#F  MaximalNormalSubgroups(<G>)
##
##  *Note* that the maximal normal subgroups of a group <G> can be computed
##  easily if the character table of <G> is known.  So if you need the table
##  anyhow,you should compute it before computing the maximal normal
##  subgroups.
##
InstallMethod( MaximalNormalSubgroups,
    "generic search",
    true, [ IsGroup ], 0,
function(G)
    local repres,  # representatives of conjugacy classes
          maximal, # list of maximal normal subgroups,result
          normal,  # list of normal subgroups
          n;        # one normal subgroup

    # Compute all normal subgroups.
    normal:= ShallowCopy(NormalSubgroups(G));

    # Remove non-maximal elements.
    Sort(normal,function(x,y) return Size(x) > Size(y); end);
    maximal:= [];
    for n in normal{ [ 2 .. Length(normal) ] } do
      if ForAll(maximal,x -> not IsSubset(x,n)) then

        # A new maximal element is found.
        Add(maximal,n);

      fi;
    od;

    # Return the result.
    return maximal;

end);


#############################################################################
##
#M  SmallGeneratingSet(<G>) 
##
InstallMethod(SmallGeneratingSet,"generators subset",true,[IsGroup],0,
function (G)
local  i, U, gens;
  gens := Set(GeneratorsOfGroup(G));
  i := 1;
  while i < Length(gens)  do
    U:=Subgroup(G,gens{Difference([1..Length(gens)],[i])});
    if Size(U)<Size(G) then
      i:=i+1;
    else
      gens:=GeneratorsOfGroup(U);
    fi;
  od;
  return gens;
end);

#############################################################################
##
#M  \<(G,H) comparison of two groups by the list of their smallest generators
##
InstallMethod(\<,"groups by smallest generating sets",IsIdentical,
  [IsGroup,IsGroup],0,
function(a,b)
 return GeneratorsSmallest(a)<GeneratorsSmallest(b);
end);


#############################################################################
##
#F  PowerMapOfGroupWithInvariants( <G>, <n>, <ccl>, <invariants> )
##
PowerMapOfGroupWithInvariants := function( G, n, ccl, invariants )

    local reps,      # list of representatives
          ord,       # list of representative orders
          invs,      # list of invariant tuples for representatives
          map,       # power map, result
          nccl,      # no. of classes
          i,         # loop over the classes
          candord,   # order of the power
          cand,      # candidates for the power class
          len,       # no. of candidates for the power class
          j,         # loop over 'cand'
          c,         # one candidate
          pow,       # power of a representative
          powinv;    # invariants of 'pow'

    reps := List( ccl, Representative );
    ord  := List( reps, Order );
    invs := [];
    map  := [];
    nccl := Length( ccl );

    # Loop over the classes
    for i in [ 1 .. nccl ] do

      candord:= ord[i] / Gcd( ord[i], n );
      cand:= Filtered( [ 1 .. nccl ], x -> ord[x] = candord );
      if Length( cand ) = 1 then

        # The image is unique, no membership test is necessary.
        map[i]:= cand[1];

      else

        # We check the invariants.
        pow:= Representative( ccl[i] )^n;
        powinv:= List( invariants, fun -> fun( pow ) );
        for c in cand do
          if not IsBound( invs[c] ) then
            invs[c]:= List( invariants, fun -> fun( reps[c] ) );
          fi;
        od;
        cand:= Filtered( cand, c -> invs[c] = powinv );
        len:= Length( cand );
        if len = 1 then

          # The image is unique, no membership test is necessary.
          map[i]:= cand[1];

        else

          # We have to check all candidates except one.
          for j in [ 1 .. len - 1 ] do
            c:= cand[j];
            if pow in ccl[c] then
              map[i]:= c;
              break;
            fi;
          od;
  
          # The last candidate may be the right one.
          if not IsBound( map[i] ) then
            map[i]:= cand[ len ];
          fi;

        fi;

      fi;

    od;

    # Return the power map.
    return map;
end;


#############################################################################
##
#M  PowerMapOfGroup( <G>, <n>, <ccl> )  . . . . . . . . . . . . . for a group
##
##  We use only element orders as invariant of conjugation.
##
InstallMethod( PowerMapOfGroup,
    "method for a group",
    true,
    [ IsGroup, IsInt, IsHomogeneousList ], 0,
    function( G, n, ccl )
    return PowerMapOfGroupWithInvariants( G, n, ccl, [] );
    end );


#############################################################################
##
#M  PowerMapOfGroup( <G>, <n>, <ccl> )  . . . . . . . for a permutation group
##
##  We use also the numbers of moved points as invariant of conjugation.
##
InstallMethod( PowerMapOfGroup,
    "method for a permutation group",
    true,
    [ IsGroup and IsPermCollection, IsInt, IsHomogeneousList ], 0,
    function( G, n, ccl )
    return PowerMapOfGroupWithInvariants( G, n, ccl, [CycleStructurePerm] );
    end );


#############################################################################
##
#M  PowerMapOfGroup( <G>, <n>, <ccl> )  . . . . . . . . .  for a matrix group
##
##  We use also the traces as invariant of conjugation.
##
InstallMethod( PowerMapOfGroup,
    "method for a matrix group",
    true,
    [ IsGroup and IsRingElementCollCollColl, IsInt, IsHomogeneousList ], 0,
    function( G, n, ccl )
    return PowerMapOfGroupWithInvariants( G, n, ccl, [ TraceMat ] );
    end );


#############################################################################
##
#M  KnowsHowToDecompose(<G>,<gens>)      test whether the group can decompose 
##                                       into the generators
##
InstallMethod(KnowsHowToDecompose,"generic: just small groups",IsIdentical,
  [IsGroup,IsList],0,
function(G,l)
  return Size(G)<1000;
end);

InstallOtherMethod(KnowsHowToDecompose,"group: use GeneratorsOfGroup",true,
  [IsGroup],0,
function(G)
  return KnowsHowToDecompose(G,GeneratorsOfGroup(G));
end);

#############################################################################
##
#M  HasAbelianFactorGroup(<G>,<N>)   test whether G/N is abelian
##
HasAbelianFactorGroup := function(G,N)
local gen;
  gen:=GeneratorsOfGroup(G);
  return ForAll([1..Length(gen)],
                i->ForAll([1..i-1],j->Comm(gen[i],gen[j]) in N));
end;

#############################################################################
##
#E  grp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



