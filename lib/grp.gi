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
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for groups.
##
Revision.grp_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  IsFinitelyGeneratedGroup( <G> ) . . test if a group is finitely generated
##
InstallImmediateMethod( IsFinitelyGeneratedGroup,
    IsGroup and HasGeneratorsOfGroup,
    G -> IsFinite( GeneratorsOfGroup( G ) ) );


#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
InstallImmediateMethod( IsCyclic, IsGroup and HasGeneratorsOfGroup,
    function( G )
    if Length( GeneratorsOfGroup( G ) ) = 1 then
      return true;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsCyclic,
    "generic method for groups",
    [ IsGroup ],
    function ( G )

    # if <G> has a generator list of length 1 then <G> is cyclic
    if HasGeneratorsOfGroup( G ) and Length( GeneratorsOfGroup(G) ) = 1 then
        return true;

    # if <G> is not commutative it is certainly not cyclic
    elif not IsCommutative( G )  then
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

InstallOtherMethod( GeneratorOfCyclicGroup,"generic method for groups",true,
    [ IsGroup ],0,
function ( G )
local g;
  if not IsAbelian(G) then
    Error("not abelian");
  fi;
  g:=Product(IndependentGeneratorsOfAbelianGroup(G));
  if Index(G,Subgroup(G,[g]))>1 then
    Error("not cyclic");
  fi;
  return g;
end);


#############################################################################
##
#M  IsElementaryAbelian(<G>)  . . . . . test if a group is elementary abelian
##
InstallMethod( IsElementaryAbelian,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   i,		# loop
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

    # otherwise compute the order of the first nontrivial generator
    else
        # p := Order( GeneratorsOfGroup( G )[1] );
	i:=1;
	repeat
	  p:=Order(GeneratorsOfGroup(G)[i]);
	  i:=i+1;
	until p>1; # will work, as G is not trivial

        # if the order is not a prime <G> is certainly not elementary abelian
        if not IsPrime( p )  then
            return false;

        # otherwise test that all other nontrivial generators have order <p>
        else
            return ForAll( GeneratorsOfGroup( G ), gen -> gen^p = One( G ) );
        fi;

    fi;
    end );


#############################################################################
##
#M  IsPGroup( <G> ) . . . . . . . . . . . . . . . . .  is a group a p-group ?
##
InstallMethod( IsPGroup,
    "generic method (check order of the group or of generators)",
    [ IsGroup ],
    function( G )
    local s, gen, ord;

    # We inspect orders of group generators if the group order is not yet
    # known *and* the group knows to be nilpotent or is abelian;
    # thus an `IsAbelian' test may be forced (which can be done via comparing
    # products of generators) but *not* an `IsNilpotent' test.
    if     ( not HasSize( G ) )
       and (    ( HasIsNilpotentGroup( G ) and IsNilpotentGroup( G ) )
             or IsAbelian( G ) ) then

      s:= [];
      for gen in GeneratorsOfGroup( G ) do
        ord:= Order( gen );
        if ord = infinity then
          return false;
        elif 1 < ord then
          UniteSet( s, Factors( ord ) );
          if 1 < Length( s ) then
            return false;
          fi;
        fi;
      od;
      if IsEmpty( s ) then
        return true;
      fi;

    else

      s:= Size( G );
      if s = 1 then
        return true;
      elif s = infinity then
        return false;
      fi;
      s:= Set( Factors( s ) );
      if 1 < Length( s ) then
        return false;
      fi;

    fi;

    SetPrimePGroup( G, s[1] );
    return true;
    end );

InstallMethod( IsPGroup,
    "for nilpotent groups",
    [ IsGroup and IsNilpotentGroup ],
    function( G )
    local s, gen, ord;

    if HasSize( G ) then
      s:= Size( G );
      if s = 1 then
        return true;
      elif s = infinity then
        return false;
      fi;
      s:= Set( Factors( s ) );
      if 1 < Length( s ) then
        return false;
      fi;
    else
      s:= [];
      for gen in GeneratorsOfGroup( G ) do
        ord:= Order( gen );
        if ord = infinity then
          return false;
        elif 1 < ord then
          UniteSet( s, Factors( ord ) );
          if 1 < Length( s ) then
            return false;
          fi;
        fi;
      od;
      if IsEmpty( s ) then
        return true;
      fi;
    fi;

    SetPrimePGroup( G, s[1] );
    return true;
    end );


#############################################################################
##
#M  PrimePGroup . . . . . . . . . . . . . . . . . . . . .  prime of a p-group
##
InstallMethod( PrimePGroup,
    "generic method, check the group order",
    [ IsPGroup ],
function( G )
local s;
  # alas, the size method might try to be really clever and ask for the size
  # again...
  if IsTrivial(G) then
    return fail;
  fi;
  s:= Size( G );
  if s = 1 then
    return fail;
  fi;
  return Set( Factors( s ) )[1];
end );


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
    [ IsGroup ],
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
    [ IsGroup and IsFinite ],
function(G)
  if not CanComputeIndex(G,DerivedSubgroup(G)) then
    TryNextMethod();
  fi;
  return Index( G, DerivedSubgroup( G ) ) = 1;
end);


InstallMethod( IsPerfectGroup, "generic method for groups",
    [ IsGroup ],
    G-> IsSubset(DerivedSubgroup(G),G));


#############################################################################
##
#M  IsSimpleGroup( <G> )  . . . . . . . . . . . . . test if a group is simple
##
InstallMethod( IsSimpleGroup,
    "generic method for groups",
    [ IsGroup ],
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
    [ IsGroup ],
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
    [ IsGroup ],
    G -> IsTrivial( SupersolvableResiduum( G ) ) );


#############################################################################
##
#M  IsTrivial( <G> )  . . . . . . . . . . . . . .  test if a group is trivial
##
InstallMethod( IsTrivial, [ IsGroup ],
        G -> ForAll( GeneratorsOfGroup( G ), gen -> gen = One( G ) ) );


#############################################################################
##
#M  AbelianInvariants( <G> )  . . . . . . . . . abelian invariants of a group
##
InstallMethod( AbelianInvariants,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   H,  p,  l,  r,  i,  j,  gns,  inv,  ranks, g,  cmm;

    if not IsFinite(G)  then
        TryNextMethod();
    elif IsTrivial( G )  then
        return [];
    fi;

    gns := GeneratorsOfGroup( G );
    inv := [];
    # the parent of this will be G
    cmm := DerivedSubgroup(G);
    for p  in Set( FactorsInt( Size( G ) ) )  do
        ranks := [];
        repeat
            H := cmm;
            for g  in gns  do
		#NC is safe
                H := ClosureSubgroupNC( H, g ^ p );
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
InstallMethod( AsGroup, [ IsGroup ], 100, IdFunc );

InstallMethod( AsGroup,
    "generic method for collections",
    [ IsCollection ],
    function ( D )
    local   G,  L;

    D := AsSSortedList( D );
    if IsEmpty( D ) then
      return fail;
    fi;
    L := ShallowCopy( D );
    G := TrivialSubgroup( GroupByGenerators( D ) );
    SubtractSet( L, AsSSortedList( G ) );
    while not IsEmpty(L)  do
        G := ClosureGroupDefault( G, L[1] );
        SubtractSet( L, AsSSortedList( G ) );
    od;
    if Length( AsList( G ) ) <> Length( D )  then
        return fail;
    fi;
    G := GroupByGenerators( GeneratorsOfGroup( G ), One( D[1] ) );
    SetAsSSortedList( G, D );
    SetIsFinite( G, true );
    SetSize( G, Length( D ) );

    # return the group
    return G;
    end );


#############################################################################
##
#M  ChiefSeries( <G> )  . . . . . . . .  delegate to `ChiefSeriesUnderAction'
##
InstallMethod( ChiefSeries,
    "method for a group (delegate to `ChiefSeriesUnderAction'",
    [ IsGroup ],
    G -> ChiefSeriesUnderAction( G, G ) );


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
InstallMethod( CommutatorFactorGroup,
    "generic method for groups",
    [ IsGroup ],
    G -> FactorGroupNC( G, DerivedSubgroup( G ) ) );

############################################################################
##
#M MaximalAbelianQuotient(<group>)
##
InstallMethod(MaximalAbelianQuotient,"not fp group", true, [IsGroup], 0,
function(G)
  if IsSubgroupFpGroup(G) then
    TryNextMethod();
  fi;
  return NaturalHomomorphismByNormalSubgroupNC(G,DerivedSubgroup(G));
end);


#############################################################################
##
#M  CompositionSeries( <G> )  . . . . . . . . . . . composition series of <G>
##
InstallMethod( CompositionSeries,
    "using DerivedSubgroup",
    [ IsGroup and IsFinite ],
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
                        low:= ClosureGroup( low, qelm );
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
    [ IsGroup ],
    G -> Length( DerivedSeriesOfGroup( G ) ) - 1 );


##############################################################################
##
#M  HirschLength( <G> ) . . . . .hirsch length of a polycyclic-by-finite group
##
InstallMethod( HirschLength,
    "generic method for finite groups",
    [ IsGroup and IsFinite ],
    G -> 0 );


#############################################################################
##
#M  DerivedSeriesOfGroup( <G> ) . . . . . . . . . . derived series of a group
##
InstallMethod( DerivedSeriesOfGroup,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   S,          # derived series of <G>, result
            D;          # derived subgroups

    # print out a warning for infinite groups
    if not IsFinite( G )  then
      Info( InfoWarning, 1,
            "DerivedSeriesOfGroup: may not stop for infinite group <G>" );
    fi;

    # compute the series by repeated calling of `DerivedSubgroup'
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
    [ IsGroup ],
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
	    #NC is safe (init with Triv)
	    D := ClosureSubgroupNC( D, comm );
        od;
    od;

    # return the normal closure of <D> in <G>
    D := NormalClosure( G, D );
    if D = G  then D := G;  fi;
    return D;
    end );


##########################################################################
##
#M  DimensionsLoewyFactors( <G> )  . . . . . . dimension of the Loewy factors
##
InstallMethod( DimensionsLoewyFactors,
    "for a group (that must be a finite p-group)",
    [ IsGroup ],
    function( G )

    local   p,  J,  x,  P,  i,  s,  j;

    # <G> must be a p-group
    if not IsPGroup( G )  then
      Error( "<G> must be a p-group" );
    fi;

    # get the prime and the Jennings series
    p := FactorsInt( Size( G ) )[1];
    J := JenningsSeries( G );

    # construct the Jennings polynomial over the rationals
    x := Indeterminate( Rationals );
    P := One( x );
    for i  in [ 1 .. Length(J)-1 ]  do
        s := Zero( x );
        for j  in [ 0 .. p-1 ]  do
            s := s + x^(j*i);
        od;
        P := P * s^LogInt( Index( J[i], J[i+1] ), p );
    od;

    # the coefficients are the dimension of the Loewy series
    return CoefficientsOfUnivariatePolynomial( P );
    end );


#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
InstallOtherMethod( ElementaryAbelianSeries,
    "method for lists",
    [ IsList and IsFinite],
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
    [ IsGroup and IsFinite],
    function( G )
    local f;

    # compute an elementary series if it is not known
    if not IsSolvableGroup( G )  then
      Error( "<G> must be solvable" );
    fi;

    # there is a method for pcgs computable groups we should use if
    # applicable, in this case redo
    if CanEasilyComputePcgs(G) then
      return ElementaryAbelianSeries(G);
    fi;

    f := IsomorphismPcGroup( G );

    # convert back into <G>
    return List( ElementaryAbelianSeries( Image( f ),
                   x -> PreImage( f, x ) ) );
    end );

#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
DoEASLS:=function( S )
local   N,I,i,L;

  N:=ElementaryAbelianSeries(S);
  # remove spurious factors
  L:=[N[1]];
  I:=N[1];
  i:=2;
  repeat
    while i<Length(N) and HasElementaryAbelianFactorGroup(I,N[i+1])
      and (IsIdenticalObj(I,N[i]) or not N[i] in S) do
      i:=i+1;
    od;
    I:=N[i];
    Add(L,I);
  until Size(I)=1;

  # return it.
  return L;
end;

InstallMethod( ElementaryAbelianSeriesLargeSteps,
    "remove spurious factors", [ IsGroup ],
  DoEASLS);

InstallOtherMethod( ElementaryAbelianSeriesLargeSteps,
  "remove spurious factors", [IsList],
  DoEASLS);

#############################################################################
##
#M  Exponent( <G> ) . . . . . . . . . . . . . . . . . . . . . exponent of <G>
##
InstallMethod( Exponent,
    "generic method for groups",
    [ IsGroup ],
    G -> Lcm( List( ConjugacyClasses(G), x -> Order(Representative(x)) ) ) );

InstallMethod( Exponent,
    "method for abelian groups with generators",
    [ IsGroup and IsAbelian and HasGeneratorsOfGroup],
    function( G )
    G:= GeneratorsOfGroup( G );
    if IsEmpty( G ) then
      return 1;
    else
      return Lcm( List( G, Order ) );
    fi;
    end );


#############################################################################
##
#M  FittingSubgroup( <G> )  . . . . . . . . . . . Fitting subgroup of a group
##
InstallMethod( FittingSubgroup, [ IsGroup and IsTrivial ], 0, IdFunc );

InstallMethod( FittingSubgroup,
    "generic method for groups",
    [ IsGroup ],
    G -> SubgroupNC( G, Filtered(Union( List( Set( FactorsInt( Size( G ) ) ),
                         p -> GeneratorsOfGroup( PCore( G, p ) ) ) ),
			 p->p<>One(G))) );

#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
InstallMethod( FrattiniSubgroup,
    "generic method for groups",
    [ IsGroup ],
    G -> Intersection( List( ConjugacyClassesMaximalSubgroups( G ),
                             C -> Core( G, Representative(C) ) ) ) );


#############################################################################
##
#M  JenningsSeries( <G> ) . . . . . . . . . . .  jennings series of a p-group
##
InstallMethod( JenningsSeries,
    "generic method for groups",
    [ IsGroup ],
    function( G )

    local   p,  n,  i,  C,  L;

    # <G> must be a p-group
    if not IsPGroup( G ) then
        Error( "<G> must be a p-group" );
    fi;

    # get the prime
    p := FactorsInt(Size(G))[1];

    # and compute the series
    # (this is a new variant thanks to Laurent Bartholdi)
    L := [ G ];
    n := 2;
    while not IsTrivial(L[n-1]) do
        L[n] := NormalClosure(G,ClosureGroup(CommutatorSubgroup(G,L[n-1]),
            List(GeneratorsOfGroup(L[QuoInt(n+p-1,p)]),x->x^p)));
        n := n+1;
    od;
    return L;

    end );


#############################################################################
##
#M  LowerCentralSeriesOfGroup( <G> )  . . . . lower central series of a group
##
InstallMethod( LowerCentralSeriesOfGroup,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   S,          # lower central series of <G>, result
            C;          # commutator subgroups

    # print out a warning for infinite groups
    if not ((CanComputeSize(G) or HasSize(G) or HasIsFinite(G)) 
       and IsFinite( G ))  then
      Info( InfoWarning, 1,
  "LowerCentralSeriesOfGroup: may not stop for potentially infinite group");
    fi;

    # compute the series by repeated calling of `CommutatorSubgroup'
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
InstallImmediateMethod( NrConjugacyClasses,
    IsGroup and HasConjugacyClasses and IsAttributeStoringRep,
    0,
    G -> Length( ConjugacyClasses( G ) ) );

InstallMethod( NrConjugacyClasses,
    "generic method for groups",
    [ IsGroup ],
    G -> Length( ConjugacyClasses( G ) ) );


#############################################################################
##
#M  Omega( <G>, <p> [, <n> ] )  . . . . . . . . . .  omega of a <p>-group <G>
##
InstallGlobalFunction( Omega, function( arg )
    local   G,  p,  n,  known;

    G := arg[1];
    p := arg[2];

    # <G> must be a <p>-group
    if Size( G ) <> p ^ LogInt( Size( G ), p )  then
        Error( "Omega: <G> must be a p-group" );
    fi;

    if Length( arg ) = 3  then  n := arg[3];
                          else  n := 1;       fi;

    known := ComputedOmegas( G );
    if not IsBound( known[ n ] )  then
        known[ n ] := OmegaOp( G, p, n );
    fi;
    return known[ n ];
end );


#############################################################################
##
#M  OmegaOp( <G>, <p>, <n> )  . . . . . . . . .  for an abelian <p>-group <G>
##
#T the code should be cleaned,
#T especially one should avoid the many unnecessary calls of `Difference'
InstallMethod( OmegaOp,
    "method for a p-group (abelian)",
    [ IsGroup, IsPosInt, IsPosInt ],
    function( G, p, n )

    local pcgs,   # PCGS of `G'
          i, j, rel, rl, rc, ng, ml, mc, m, q,
          one;    # identity of `G'

    if not IsAbelian( G ) or n <> 1  then
      TryNextMethod();
    fi;
#T should be changed as soon as a generic method for p-groups is available.

#T what about `IndependentGeneratorsOfAbelianGroup'?
#T (at the moment exists only for permutation groups)

    pcgs:= Pcgs( G );
    ng:= ShallowCopy( pcgs );

    # `rel' is the relation matrix of `G'.
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
      m:= Maximum( List( rel[rl[1]], AbsInt ) ) + 1;
      for i in rl do
        for j in rc do
          if rel[i][j] <> 0 and AbsInt( rel[i][j] ) < m then
            # `rel[ml][mc]' is minimal entry of `rel'
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

InstallMethod( ComputedOmegas, [ IsGroup ], 0, G -> [  ] );


#############################################################################
##
#M  RadicalGroup( <G> ) . . . . . . . . . . . . . . . . .  radical of a group
##
InstallMethod( RadicalGroup,
    "for a group",
    [ IsGroup ],
    function ( G )
    Error( "sorry, cannot compute the radical of <G>" );
    end );

InstallMethod( RadicalGroup,
    "solvable group is its own radical",
    [ IsGroup and IsSolvableGroup ], 100,
    IdFunc );


#############################################################################
##
#M  GeneratorsSmallest( <G> ) . . . . . smallest generating system of a group
##
InstallMethod( GeneratorsSmallest,
    "generic method for groups",
    [ IsGroup ],
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
	    #NC is safe (init with Triv)
            H := ClosureSubgroupNC( H, gen );

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
#M  LargestElementGroup( <G> )
##
##  returns the largest element of <G> with respect to the ordering `\<' of
##  the elements family.
InstallMethod(LargestElementGroup,"use `EnumeratorSorted'",true,[IsGroup],
function(G)
  return EnumeratorSorted(G)[Size(G)];
end);


#############################################################################
##
#F  SupersolvableResiduumDefault( <G> ) . . . . supersolvable residuum of <G>
##
##  The algorithm constructs a descending series of normal subgroups with
##  supersolvable factor group from <G> to its supersolvable residuum such
##  that any subgroup that refines this series is normal in <G>.
##
##  In each step of the algorithm, a normal subgroup <N> of <G> with
##  supersolvable factor group is taken.
##  Then its commutator factor group is constructed and decomposed into its
##  Sylow subgroups.
##  For each, the Frattini factor group is considered as a <G>-module.
##  We are interested only in the submodules of codimension 1.
##  For these cases, the eigenspaces of the dual submodule are calculated,
##  and the preimages of their orthogonal spaces are used to construct new
##  normal subgroups with supersolvable factor groups.
##  If no eigenspace is found within one step, the residdum is reached.
##
##  The component `ds' describes a series such that any composition series
##  through `ds' from <G> down to the residuum is a chief series.
##
InstallGlobalFunction( SupersolvableResiduumDefault, function( G )

    local ssr,         # supersolvable residuum
          ds,          # component `ds' of the result
          gens,        # generators of `G'
          gs,          # small generating system of `G'
          p,           # loop variable
          o,           # group order
          size,        # size of `G'
          s,           # subgroup of `G'
          oldssr,      # value of `ssr' in the last iteration
          dh,          # nat. hom. modulo derived subgroup
          df,          # range of `dh'
          fs,          # list of factors of the size of `df'
          gen,         # generators for the next candidate
          np,          # `p'-prime part of the size of `df'
          pp,          # `p'-part of the size of `df'
          pu,          # Sylow `p' subgroup of `df'
          tmp,         # agemo generators
          ph,          # nat. hom. onto Frattini quotient of `pu'
          ff,          # Frattini factor
          ffsize,      # size of `ff'
          pcgs,        # PCGS of `ff'
          dim,         # dimension of the vector space `ff'
          idm,         # identity matrix
          mg,          # matrices of `G' action on `ff'
          field,       # prime field in char. `p'
          vsl,         # list of simult. eigenspaces
          nextvsl,     # for next iteration
          matrix,      # loopvariable
          eigenvalue,  # loop variable
          nullspace,   # generators of the eigenspace
          space,       # loop variable
          inter,       # intersection
          tmp2,        #
          v,           #
          ve;          #

    ssr := DerivedSubgroup( G );
    ds  := [ G, ssr ];

    if not IsTrivial( ssr ) then

      # Find a small generating system `gs' of `G'.
      gens := GeneratorsOfGroup( G );
      gs   := [ gens[1] ];
      p    := 2;
      o    := Order( gens[1] );
      size := Size( G );
      repeat
        s:= SubgroupNC( G, Concatenation( gs, [ gens[p] ] ) );
        if o < Size( s ) then
          Add( gs, gens[p] );
          o:= Size( s );
        fi;
        p:= p+1;
      until o = size;

      # Loop until we reach the residuum.
      repeat

        # Remember the last candidate as `oldssr'.
        oldssr := ssr;
        ssr    := DerivedSubgroup( oldssr );
        dh     := NaturalHomomorphismByNormalSubgroup( oldssr, ssr );

        # `df' is the commutator factor group `oldssr / ssr'.
        df := Range( dh );
        fs := FactorsInt( Size( df ) );

        # `gen' collects the generators for the next candidate
        gen := ShallowCopy( GeneratorsOfGroup( df ) );

        for p in Set( fs ) do

          np:= Product( Filtered( fs, x -> x <> p ) );
          pp:= Product( Filtered( fs, x -> x  = p ) );

          # `pu' is the Sylow `p' subgroup of `df'.
          pu:= SubgroupNC( df, List( GeneratorsOfGroup(df), x -> x^np ) );

          # Remove the `p'-part from the generators list `gen'.
          gen:= List( gen, x -> x^pp );

          # Add the agemo_1 of the Sylow subgroup to the generators list.
          tmp:= List( GeneratorsOfGroup( pu ), x -> x^p );
          Append( gen, tmp );
          ph:= NaturalHomomorphismByNormalSubgroup( pu,
                                                SubgroupNC( df, tmp ) );

          # `ff' is the Frattini factor group.
          ff := Range( ph );
          ffsize:= Size( ff );
          if p < ffsize then

            pcgs := Pcgs( ff );
            dim  := Length( pcgs );
            idm  := IdentityMat( dim, GF(p) );

            # `mg' is the list of matrices of the action of `G' on the
            # dual space of the module, w.r.t. a pcgs of `ff'.
            mg:= List( gs, x -> TransposedMat( List( pcgs,
                     y -> Z(p)^0 * ExponentsOfPcElement( pcgs, Image( ph,
                          Image( dh, PreImagesRepresentative(
                            dh, PreImagesRepresentative(ph,y) )^x ) ) )))^-1);
            mg:= Filtered( mg, x -> not IsOne( x ) );

            # `vsl' is a list of generators of all the simultaneous
            # eigenspaces.
            field:= GF(p);
            vsl:= [ IdentityMat( dim, field ) ];
            for matrix in mg do

              nextvsl:= [];

              # All eigenvalues of `matrix' will be used.
              for eigenvalue in List( Filtered( Factors(
                    CharacteristicPolynomial( field, matrix ) ),
                       x -> DegreeOfLaurentPolynomial( x ) = 1 ),
                       y -> - CoefficientsOfUnivariatePolynomial( y )[1] ) do

                nullspace:= NullspaceMat( matrix - eigenvalue*idm );
                if not IsEmpty( nullspace ) then
                  for space in vsl do
                    inter:= SumIntersectionMat( space, nullspace )[2];
                    if not IsEmpty( inter ) then
                      Add( nextvsl, inter );
                    fi;
                  od;
                fi;

              od;

              vsl:= nextvsl;

            od;

            # Now calculate the dual spaces of the eigenspaces.
            if IsEmpty( vsl ) then
              Append( gen, GeneratorsOfGroup( pu ) );
            else

              # `tmp' collects the eigenspaces.
              tmp:= [];
              for matrix in vsl do

                # `tmp2' will be the base of the dual space.
                tmp2:= [];
                Append( tmp, matrix );

                for v in NullspaceMat( TransposedMat( tmp ) ) do

                  # Construct a group element corresponding to
                  # the basis element of the submodule.
                  ve:= PcElementByExponentsNC( pcgs, v );
                  Add( tmp2, PreImagesRepresentative( ph, ve ) );

                od;
                Add( ds, PreImagesSet( dh,
                          SubgroupNC( df, Concatenation( tmp2, gen ) ) ) );
              od;
              Append( gen, tmp2 );
            fi;
          else
            Add( ds, PreImagesSet( dh,
                         SubgroupNC( df, AsSSortedList( gen ) ) ) );
          fi;
        od;

        # Generate the new candidate.
        ssr:= PreImagesSet( dh, SubgroupNC( df, AsSSortedList( gen ) ) );

      until IsTrivial( ssr ) or oldssr = ssr;

      ssr:= SubgroupNC( G, GeneratorsOfGroup( ssr ) );

    fi;

    # Return the result.
    return rec(
      ssr:=SubgroupNC(G,Filtered(GeneratorsOfGroup(ssr),i->Order(i)>1)),
      ds:= ds );
end );


#############################################################################
##
#M  SupersolvableResiduum( <G> )
##
InstallMethod( SupersolvableResiduum,
    "method for finite groups (call `SupersolvableResiduumDefault')",
    [ IsGroup and IsFinite ],
    G -> SupersolvableResiduumDefault( G ).ssr );


#############################################################################
##
#M  ComplementSystem( <G> ) . . . . . Sylow complement system of finite group
##
InstallMethod( ComplementSystem,
    "generic method for finite groups",
    [ IsGroup and IsFinite ],
function( G )
    local spec, weights, primes, comp, i, gens, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    spec := SpecialPcgs( G );
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
    [ IsGroup and IsFinite ],
function( G )
    local spec, weights, primes, comp, i, gens, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    spec := SpecialPcgs( G );
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
    [ IsGroup and IsFinite ],
function( G )
    local spec, weights, primes, comp, i, gens, pis, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    spec := SpecialPcgs( G );
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
#M  UpperCentralSeriesOfGroup( <G> )  . . . . upper central series of a group
##
InstallMethod( UpperCentralSeriesOfGroup,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   S,          # upper central series of <G>, result
            C,          # centre
            hom;        # homomorphisms of <G> to `<G>/<C>'

    # print out a warning for infinite groups
    if not IsFinite( G )  then
      Info( InfoWarning, 1,
          "UpperCentralSeriesOfGroup: may not stop for infinite group <G>");
    fi;

    # compute the series by repeated calling of `Centre'
    S := [ TrivialSubgroup( G ) ];
    Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
    C := Centre( G );
    while C <> S[ Length(S) ]  do
        Add( S, C );
        Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
        hom := NaturalHomomorphismByNormalSubgroup( G, C );
        C := PreImages( hom, Centre( Image( hom ) ) );
    od;

    if S[ Length(S) ] = G then
        UseIsomorphismRelation( G, S[ Length(S) ] );
    fi;
    # return the series when it becomes stable
    return Reversed( S );
    end );

#############################################################################
##
#M  Agemo( <G>, <p> [, <n> ] )  . . . . . . . . . .  agemo of a <p>-group <G>
##
InstallGlobalFunction( Agemo, function( arg )
    local   G,  p,  n,  known;

    G := arg[1];
    p := arg[2];

    # <G> must be a <p>-group
    if Size( G ) <> p ^ LogInt( Size( G ), p )  then
        Error( "Agemo: <G> must be a p-group" );
    fi;

    if Length( arg ) = 3  then  n := arg[3];
                          else  n := 1;       fi;

    known := ComputedAgemos( G );
    if not IsBound( known[ n ] )  then
        known[ n ] := AgemoOp( G, p, n );
    fi;
    return known[ n ];
end );

InstallMethod( AgemoOp,
    "generic method for groups",
    [ IsGroup, IsPosInt, IsPosInt ],
    function( G, p, n )

    local   C,  q;

    q := p ^ n;
    # if <G> is abelian,  raise the generators to the q.th power
    if IsAbelian(G)  then
        return SubgroupNC( G,Filtered( List( GeneratorsOfGroup( G ), x ->
	x^q ),i->Order(i)>1) );

    # otherwise compute the conjugacy classes of elements
    else
        C := Set( List( ConjugacyClasses(G), x -> Representative(x)^q ) );
        return NormalClosure( G, SubgroupNC( G, C ) );
    fi;
end );

InstallMethod( ComputedAgemos, [ IsGroup ], 0, G -> [  ] );


#############################################################################
##
#M  AgemoAbove( <G>, <C>, <p> ) . . . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( AgemoAbove, function( G, C, p )

#T     # if we know the agemo,  return
#T     if HasAgemo( G )  then
#T         return Agemo( G );
#T     fi;
#T (is not an attribute...)

    # if the derived subgroup of <G> is contained in <C> it is easy
    if IsSubgroup( C, DerivedSubgroup(G) )  then
        return SubgroupNC( G, List( GeneratorsOfGroup( G ), x -> x^p ) );

    # otherwise use `Agemo'
    else
        Info( InfoGroup, 2, "computing conjugacy classes for agemo" );
        return Agemo( G, p );
    fi;
end );

#############################################################################
##
#M  AsSubgroup( <G>, <U> )
##
InstallMethod( AsSubgroup,
    "generic method for groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function( G, U )
    local S;
    # test if the parent is already alright
    if HasParent(U) and IsIdenticalObj(Parent(U),G) then
      return U;
    fi;

    if not IsSubset( G, U ) then
      return fail;
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
InstallGlobalFunction( ClosureGroupDefault, function( G, elm )

    local   C,          # closure `\< <G>, <obj> \>', result
            gens,       # generators of <G>
            gen,        # generator of <G> or <C>
            Celements,  # intermediate list of elements
	    rg,		# rep*gen
	    e,		# loop
            reps,       # representatives of cosets of <G> in <C>
            rep;        # representative of coset of <G> in <C>

    gens:= GeneratorsOfGroup( G );

    # try to avoid adding an element to a group that already contains it
    if   elm in gens
      or elm^-1 in gens
      or ( HasAsSSortedList( G ) and elm in AsSSortedList( G ) )
      or elm = One( G )
    then
        return G;
    fi;

    # make the closure group
    C:= GroupWithGenerators( Concatenation( gens, [ elm ] ) );
    UseSubsetRelation( C, G );

    # if the elements of <G> are known then extend this list
    if HasAsSSortedList( G ) then

        # if <G>^<elm> = <G> then <C> = <G> * <elm>
        if ForAll( gens, gen -> gen ^ elm in AsSSortedList( G ) )  then
            Info( InfoGroup, 2, "new generator normalizes" );
            Celements := ShallowCopy( AsSSortedList( G ) );
            rep := elm;
            while not rep in AsSSortedList( G ) do
                Append( Celements, AsSSortedList( G ) * rep );
                rep := rep * elm;
            od;
            SetAsSSortedList( C, AsSSortedList( Celements ) );
            SetIsFinite( C, true );
            SetSize( C, Length( Celements ) );

        # otherwise use a Dimino step
        else
            Info( InfoGroup, 2, "new generator normalizes not" );
            Celements := ShallowCopy( AsSSortedList( G ) );
            reps := [ One( G ) ];
            Info( InfoGroup, 2, "   |<cosets>| = ", Length(reps) );
            for rep  in reps  do
                for gen  in GeneratorsOfGroup( C ) do
		    rg:=rep*gen;
                    if not rg in Celements  then
                        #Append( Celements, AsSSortedList( G ) * rg );
			# rather do this as a set as well to compare
			# elements better
                        for e in AsSSortedList( G ) do
			  AddSet(Celements,e*rg);
			od;
                        Add( reps, rg );
                        Info( InfoGroup, 3,
                              "   |<cosets>| = ", Length(reps) );
                    fi;
                od;
            od;
            SetAsSSortedList( C, AsSSortedList( Celements ) );
            SetIsFinite( C, true );
            SetSize( C, Length( Celements ) );

        fi;
    fi;

    # return the closure
    return C;
end );


#############################################################################
##
#M  ClosureGroupAddElm( <G>, <elm> )
#M  ClosureGroupCompare( <G>, <elm> )
#M  ClosureGroupIntest( <G>, <elm> )
##
InstallGlobalFunction(ClosureGroupAddElm,function( G, elm )
local   C,  gens;

    gens := GeneratorsOfGroup( G );
    # make the closure group
    C := GroupWithGenerators( Concatenation( gens, [ elm ] ) );
    UseSubsetRelation( C, G );

    # return the closure
    return C;
end );

InstallGlobalFunction(ClosureGroupCompare,function( G, elm )
local  gens;

  gens := GeneratorsOfGroup( G );

  # try to avoid adding an element to a group that already contains it
  if   elm in gens
    or elm^-1 in gens
    or ( HasAsSSortedList( G ) and elm in AsSSortedList( G ) )
    or elm = One( G )  then
      return G;
  fi;

  return ClosureGroupAddElm(G,elm);
end );

InstallGlobalFunction(ClosureGroupIntest,function( G, elm )
local  gens;

  gens := GeneratorsOfGroup( G );

  # try to avoid adding an element to a group that already contains it
  if   elm in gens
    or elm^-1 in gens
    or ( HasAsSSortedList( G ) and elm in AsSSortedList( G ) )
    or elm = One( G )
    or elm in G then
      return G;
  fi;

  return ClosureGroupAddElm(G,elm);
end );


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . . . .  default method for group and element
##
InstallMethod( ClosureGroup, "generic method for group and element",
    IsCollsElms, [ IsGroup, IsMultiplicativeElementWithInverse ],
function(G,elm)
  if CanEasilyCompareElements(elm) then
    return ClosureGroupCompare(G,elm);
  else
    return ClosureGroupAddElm(G,elm);
  fi;
end);

InstallMethod( ClosureGroup, "groups with cheap membership test", IsCollsElms,
  [IsGroup and CanEasilyTestMembership,IsMultiplicativeElementWithInverse],
  ClosureGroupIntest);


#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . .  for group that contains the whole family
##
InstallMethod( ClosureGroup,
    "method for group that contains the whole family",
    IsCollsElms,
    [ IsGroup and IsWholeFamily, IsMultiplicativeElementWithInverse ],
    SUM_FLAGS, # this is better than everything else
    function( G, g )
    return G;
    end );


#############################################################################
##
#M  ClosureGroup( <G>, <U> )  . . . . . . . . . . closure of group with group
##
InstallMethod( ClosureGroup,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function( G, H )

    local   C,   # closure `\< <G>, <H> \>', result
            gen; # generator of <G> or <C>

    C:= G;
    for gen in GeneratorsOfGroup( H ) do
      C:= ClosureGroup( C, gen );
    od;
    return C;
    end );

InstallMethod( ClosureGroup,
    "for two groups, the bigger conatining the whole family",
    IsIdenticalObj,
    [ IsGroup and IsWholeFamily, IsGroup ],
    SUM_FLAGS, # this is better than everything else
    function( G, H )
    return G;
    end );

InstallMethod( ClosureGroup,
    "for group and element list",
    IsIdenticalObj,
    [ IsGroup, IsCollection ],
    function( G, gens )
    local   gen;

    for gen  in gens  do
        G := ClosureGroup( G, gen );
    od;
    return G;
end );

InstallMethod( ClosureGroup, "for group and empty element list",
    [ IsGroup, IsList and IsEmpty ],
function( G, nogens )
  return G;
end );


#############################################################################
##
#F  ClosureSubgroupNC( <G>, <obj> )
##
InstallGlobalFunction( ClosureSubgroupNC, function(arg)
local G,obj;
    G:=arg[1];
    obj:=arg[2];
    if not HasParent( G ) then
      # don't be obnoxious
      Info(InfoWarning,1,"`ClosureSubgroup' called for orphan group" );
    fi;
    if Length(arg)=2 then
      obj:= ClosureGroup( G, obj );
    else
      obj:= ClosureGroup( G, obj, arg[3] );
    fi;
    if not IsIdenticalObj( Parent( G ), obj ) then
      SetParent( obj, Parent( G ) );
    fi;
    return obj;
end );


#############################################################################
##
#M  ClosureSubgroup( <G>, <obj> )
##
InstallGlobalFunction( ClosureSubgroup, function( G, obj )

    local famG, famobj, P;

    if not HasParent( G ) then
      Error( "<G> must have a parent" );
    fi;

    # Check that we may set the parent of the closure.
    famG:= FamilyObj( G );
    famobj:= FamilyObj( obj );
    P:= Parent( G );
    # refer to `ClosureGroup' instead of issuing errors -- `ClosureSubgroup'
    # is only used to transfer information
    if   IsIdenticalObj( famG, famobj ) and not IsSubset( P, obj ) then
      return ClosureGroup(G,obj);
      #Error( "<obj> is not a subset of the parent of <G>" );
    elif IsCollsElms( famG, famobj ) and not obj in P then
      return ClosureGroup(G,obj);
      #Error( "<obj> is not an element of the parent of <G>" );
    fi;

    # Return the closure.
    return ClosureSubgroupNC( G, obj );
end );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )  . . . . commutator subgroup of two groups
##
InstallMethod( CommutatorSubgroup,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
#M  \^( <G>, <g> )
##
InstallOtherMethod( \^,
    "generic method for groups and element",
    IsCollsElms,
    [ IsGroup,
      IsMultiplicativeElementWithInverse ],
    ConjugateGroup );


#############################################################################
##
#M  ConjugateGroup( <G>, <g> )
##
InstallMethod( ConjugateGroup, "<G>, <g>", IsCollsElms,
    [ IsGroup, IsMultiplicativeElementWithInverse ],
    function( G, g )
    local   H;

    H := GroupByGenerators( OnTuples( GeneratorsOfGroup( G ), g ), One(G) );
    UseIsomorphismRelation( G, H );
    return H;
end );


#############################################################################
##
#M  ConjugateSubgroup( <G>, <g> )
##
InstallMethod( ConjugateSubgroup, "for group with parent, and group element",
  IsCollsElms,[IsGroup and HasParent,IsMultiplicativeElementWithInverse],
function( G, g )
  g:= ConjugateGroup( G, g );
  if not IsIdenticalObj(Parent(G),g) then
    SetParent( g, Parent( G ) );
  fi;
  return g;
end );

InstallOtherMethod( ConjugateSubgroup, "for group without parent",
  IsCollsElms,[IsGroup,IsMultiplicativeElementWithInverse],
ConjugateGroup);

#############################################################################
##
#M  Core( <G>, <U> )  . . . . . . . . . . . . . core of a subgroup in a group
##
InstallMethod( CoreOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function ( G, U )

    local   C,          # core of <U> in <G>, result
            i,          # loop variable
            gens;       # generators of `G'

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
#F  FactorGroup( <G>, <N> )
#M  FactorGroupNC( <G>, <N> )
#M  \/( <G>, <N> )
##
InstallGlobalFunction( FactorGroup,function(G,N)
  if not (IsGroup(G) and IsGroup(N) and IsNormal(G,N)) then
    Error("<N> must be a normal subgroup of <G>");
  fi;
  return FactorGroupNC(G,N);
end);

InstallMethod( FactorGroupNC,
    "generic method for two groups",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    function( G, N )
    return ImagesSource( NaturalHomomorphismByNormalSubgroupNC( G, N ) );
    end );

InstallOtherMethod( \/,
    "generic method for two groups",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    FactorGroup );


#############################################################################
##
#M  IndexOp( <G>, <H> )
##
InstallMethod( IndexOp,
    "generic method for two groups",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    function( G, H )
    if not IsSubset( G, H ) then
      Error( "<H> must be contained in <G>" );
    fi;
    return IndexNC( G, H );
    end );


#############################################################################
##
#M  IndexNC( <G>, <H> )
##
InstallMethod( IndexNC,
    "generic method for two groups",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    function( G, H )
    return Size( G ) / Size( H );
    end );


#############################################################################
##
#M  IsConjugate( <G>, <x>, <y> )
##
InstallMethod(IsConjugate,"group elements",IsCollsElmsElms,[IsGroup,
  IsMultiplicativeElementWithInverse,IsMultiplicativeElementWithInverse],
function(g,x,y)
  return RepresentativeAction(g,x,y,OnPoints)<>fail;
end);

InstallMethod(IsConjugate,"subgroups",IsFamFamFam,[IsGroup, IsGroup,IsGroup],
function(g,x,y)
  # shortcut for normal subgroups
  if (HasIsNormalInParent(x) and IsNormalInParent(x)
      and CanComputeIsSubset(Parent(x),y) and IsSubset(Parent(x),y))
  or (HasIsNormalInParent(y) and IsNormalInParent(y)
      and CanComputeIsSubset(Parent(y),x) and IsSubset(Parent(y),x)) then
    return x=y;
  fi;

  return RepresentativeAction(g,x,y,OnPoints)<>fail;
end);

#############################################################################
##
#M  IsNormal( <G>, <U> )
##
InstallMethod( IsNormalOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function( G, H )
    return ForAll(GeneratorsOfGroup(G),
             i->ForAll(GeneratorsOfGroup(H),j->j^i in H));
    end );

#############################################################################
##
#M  IsCharacteristicSubgroup( <G>, <U> )
##
InstallMethod( IsCharacteristicSubgroup, "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
function( G, H )
local n,a;
  if not IsNormal(G,H) then
     return false;
  fi;
  # computing the automorphism group is quite expensive. We therefore test
  # first whether there are image candidates
  if not IsAbelian(G) then #(otherwise there might be to many normal sgrps)
    n:=NormalSubgroups(G);
    n:=Filtered(n,i->Size(i)=Size(H)); # probably do further tests here
    if Length(n)=1 then
      return true; # there is no potential image - we are characteristic
    fi;
  fi;

  a:=AutomorphismGroup(G);
  if ForAny(GeneratorsOfGroup(a),i->Image(i,H)<>H) then
    return false;
  else
    return true;
  fi;
end );


#############################################################################
##
#M  IsPNilpotentOp( <G>, <p> )
##
##  A group is $p$-nilpotent if it possesses a normal $p$-complement.
##  So we compute a Hall subgroup for the set of prime divisors of $|<G>|$
##  except <p>, and check whether it is normal in <G>.
##
InstallMethod( IsPNilpotentOp,
    "generic method for a (finite) group and a prime integer",
    [ IsGroup, IsPosInt ],
    function( G, p )

    local primes, S;

    if not IsFinite( G ) then
      TryNextMethod();
    fi;

    primes:= Set( Factors( Size( G ) ) );
    RemoveSet( primes, p );
    S:= HallSubgroup( G, primes );

    return S <> fail and IsNormal( G, S );
    end );


#############################################################################
##
#M  IsPSolvable( <G>, <p> )
##

#############################################################################
##
#F  IsSubgroup( <G>, <U> )
##
InstallGlobalFunction( IsSubgroup,
    function( G, U )
    return IsGroup( U ) and IsSubset( G, U );
    end );


#############################################################################
##
#R  IsRightTransversalRep( <obj> )  . . . . . . . . . . . . right transversal
##
DeclareRepresentation( "IsRightTransversalRep",
    IsAttributeStoringRep and IsRightTransversal,
    [ "group", "subgroup" ] );

InstallMethod( PrintObj,
    "for right transversal",
    [ IsList and IsRightTransversalRep ],
function( cs )
    Print( "RightTransversal( ", cs!.group, ", ", cs!.subgroup, " )" );
end );

InstallMethod( ViewObj,
    "for right transversal",
    [ IsList and IsRightTransversalRep ],
function( cs )
    Print( "RightTransversal(");
    View(cs!.group);
    Print(",");
    View(cs!.subgroup);
    Print(")");
end );

InstallMethod( Length,
    "for right transversal",
    [ IsList and IsRightTransversalRep ],
    t -> Index( t!.group, t!.subgroup ) );


#############################################################################
##
#M  NormalClosure( <G>, <U> ) . . . . normal closure of a subgroup in a group
##
InstallMethod( NormalClosureOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function( G, H ) return Intersection2( G, H ); end );


#############################################################################
##
#M  Normalizer( <G>, <g> )
#M  Normalizer( <G>, <U> )
##
InstallMethod( NormalizerOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
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

InstallMethod( NormalizerOp,
    "generic method for group and Element",
    IsCollsElms, [ IsGroup, IsMultiplicativeElementWithInverse ],
function(G,g)
  return NormalizerOp(G,Group([g],One(G)));
end);

#############################################################################
##
#M  NrConjugacyClassesInSupergroup( <U>, <H> )
##  . . . . . . .  number of conjugacy classes of <H> under the action of <U>
##
InstallMethod( NrConjugacyClassesInSupergroup,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function( U, G )
    return Number( ConjugacyClasses( U ), C -> Representative( C ) in G );
    end );


#############################################################################
##
#M  PCentralSeriesOp( <G>, <p> )  . . . . . .  . . . . . . <p>-central series
##
InstallMethod( PCentralSeriesOp,
    "generic method for group and prime",
    [ IsGroup, IsPosInt ],
    function( G, p )
    local   L,  C,  S,  N,  P;

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
#M  PClassPGroup( <G> )   . . . . . . . . . .  . . . . . . <p>-central series
##
InstallMethod( PClassPGroup,
    "generic method for group",
    [ IsPGroup ],
    function( G )
    if IsTrivial( G ) then
      return 0;
    fi;
    return Length( PCentralSeries( G, PrimePGroup( G ) ) ) - 1;
    end );


#############################################################################
##
#M  RankPGroup( <G> ) . . . . . . . . . . . .  . . . . . . <p>-central series
##
InstallMethod( RankPGroup,
    "generic method for group",
    [ IsPGroup ],
    G -> Length( AbelianInvariants( G ) ) );


#############################################################################
##
#M  PRumpOp( <G>, <p> )
##
InstallMethod( PRumpOp,
    "generic method for group and prime",
    [ IsGroup, IsPosInt ],
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
#M  PCoreOp( <G>, <p> ) . . . . . . . . . . . . . . . . . . p-core of a group
##
##  `PCore' returns the <p>-core of the group <G>, i.e., the  largest  normal
##  <p> subgroup of <G>.  This is the core of the <p> Sylow subgroups.
##
InstallMethod( PCoreOp,
    "generic method for group and prime",
    [ IsGroup, IsPosInt ],
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
InstallMethod( SubnormalSeriesOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function ( G, U )
    local   S,          # subnormal series of <U> in <G>, result
            C;          # normal closure of <U> in <G> resp. <C>

    Info( InfoGroup, 1,
          "SubnormalSeries: of ", GroupString(U,"U"), " in ",
          GroupString(G,"G") );

    # compute the subnormal series by repeated calling of `NormalClosure'
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
#M  IsSubnormal( <G>, <U> )
##
InstallMethod( IsSubnormal,"generic method for two groups",IsIdenticalObj,
  [IsGroup,IsGroup],
function ( G, U )
local s;
  s:=SubnormalSeries(G,U);
  return U=s[Length(s)];
end);


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . . . . . . for a group and a prime
##
InstallMethod( SylowSubgroupOp,
    "generic method for group and prime",
    [ IsGroup, IsPosInt ],
    function( G, p )
    local   S,          # Sylow <p> subgroup of <G>, result
            r,          # random element of <G>
            ord;        # order of `r'

    # repeat until <S> is the full Sylow <p> subgroup
    S := TrivialSubgroup( G );
    while Size( G ) / Size( S ) mod p = 0  do

        # find an element of <p> power order that normalizes <S>
        repeat
            repeat
                r := Random( G );
                ord:= Order( r );
            until ord mod p = 0;
            while ord mod p = 0 do
              ord:= ord / p;
            od;
            r := r ^ ord;
        until not r in S and ForAll( GeneratorsOfGroup( S ), g -> g^r in S );

        # add it to <S>
	# NC is safe (init with Triv)
        S := ClosureSubgroupNC( S, r );

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
    [ IsGroup and IsNilpotentGroup, IsPosInt ],
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
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
    IsIdenticalObj, [ IsGroup, IsGroup ],
    function ( G, U )
    local   Ggens,      # group generators of `G'
            one,        # identity of `U'
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

    # all generators of <U> are fixed, return `true'
    return true;
    end );
#T compare method in `mgmgen.g'!

#############################################################################
##
#M  IsSubset( <G>, <H> ) . . . . . . . . . . . . .  test for subset of groups
##
InstallMethod( IsSubset,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
##
EnumeratorOfGroup := function( G )

    local   H,          # subgroup of the first generators of <G>
            gen;        # generator of <G>

    # start with the trivial group and its element list
    H:= TrivialSubgroup( G );
    SetAsSSortedList( H, Immutable( [ One( G ) ] ) );

    # Add the generators one after the other.
    # We use a function that maintains the elements list for the closure.
    for gen in GeneratorsOfGroup( G ) do
      H:= ClosureGroupDefault( H, gen );
    od;

    # return the list of elements
    Assert( 2, HasAsSSortedList( H ) );
    return AsSSortedList( H );
end;

InstallMethod( Enumerator,
    "generic method for a group",
    [ IsGroup and IsAttributeStoringRep ],
    EnumeratorOfGroup );

InstallMethod(AsSSortedListNonstored,"generic method for groups",true,
  [IsGroup],0,
  # the element list is only stored in the locally created new group H
  EnumeratorOfGroup);


#############################################################################
##
#M  Centralizer( <G>, <elm> ) . . . . . . . . . . . .  centralizer of element
#M  Centralizer( <G>, <H> )   . . . . . . . . . . . . centralizer of subgroup
##
InstallMethod( CentralizerOp,
    "generic method for group and object",
    IsCollsElms, [ IsGroup, IsObject ],
    function( G, elm )
    return Stabilizer( G, elm, OnPoints );
    end );

InstallMethod( CentralizerOp,
    "generic method for two groups",
    IsIdenticalObj, [ IsGroup, IsGroup ],
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
#F  IsomorphismTypeInfoFiniteSimpleGroup( <G> ) . . . . isomorphism type info
##
InstallGlobalFunction( IsomorphismTypeInfoFiniteSimpleGroup, function( G )
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
        return rec(series:="Z",parameter:=size,
	           name:=Concatenation( "Z(", String(size), ")" ));
    fi;

    # test if <G> is A(5) ~ A(1,4) ~ A(1,5)
    if size = 60  then
        return rec(series:="A",parameter:=5,
	           name:=Concatenation( "A(5) ",
                            "~ A(1,4) = L(2,4) ",
                            "~ B(1,4) = O(3,4) ",
                            "~ C(1,4) = S(2,4) ",
                            "~ 2A(1,4) = U(2,4) ",
                            "~ A(1,5) = L(2,5) ",
                            "~ B(1,5) = O(3,5) ",
                            "~ C(1,5) = S(2,5) ",
                            "~ 2A(1,5) = U(2,5)" ));
    fi;

    # test if <G> is A(6) ~ A(1,9)
    if size = 360  then
        return rec(series:="A",parameter:=6,
		   name:=Concatenation( "A(6) ",
                            "~ A(1,9) = L(2,9) ",
                            "~ B(1,9) = O(3,9) ",
                            "~ C(1,9) = S(2,9) ",
                            "~ 2A(1,9) = U(2,9)" ));
    fi;

    # test if <G> is either A(8) ~ A(3,2) ~ D(3,2) or A(2,4)
    if size = 20160  then

        # check that <G> is a group
        if not IsGroup( G )  then
            return rec(name:=Concatenation(
	                          "cannot decide from size alone between ",
                                  "A(8) ",
                                "~ A(3,2) = L(4,2) ",
                                "~ D(3,2) = O+(6,2) ",
                                "and ",
                                  "A(2,4) = L(3,4) " ));
        fi;

        # compute the centralizer of an element of order 5
        repeat
            g := Random(G);
        until Order(g) mod 5 = 0;
        g := g ^ (Order(g) / 5);
        C := Centralizer( G, g );

        # The centralizer in A(8) has size 15, the one in A(2,4) has size 5.
        if Size(C) = 15 then
            return rec(series:="A",parameter:=8,
                       name:=Concatenation( "A(8) ",
                                "~ A(3,2) = L(4,2) ",
                                "~ D(3,2) = O+(6,2)" ));
        else
            return rec(series:="L",parameter:=[3,4],
                       name:="A(2,4) = L(3,4)");
        fi;

    fi;

    # test if <G> is A(n)
    n := 6;
    size2 := 360;
    repeat
        n := n + 1;
        size2 := size2 * n;
    until size <= size2;
    if size = size2  then
        return rec(series:="A",parameter:=n,
                   name:=Concatenation( "A(", String(n), ")" ));
    fi;

    # test if <G> is one of the sporadic simple groups
    if size = 2^4 * 3^2 * 5 * 11  then
        return rec(series:="Spor",name:="M(11)");
    elif size = 2^6 * 3^3 * 5 * 11  then
        return rec(series:="Spor",name:="M(12)");
    elif size = 2^3 * 3 * 5 * 7 * 11 * 19  then
        return rec(series:="Spor",name:="J(1)");
    elif size = 2^7 * 3^2 * 5 * 7 * 11  then
        return rec(series:="Spor",name:="M(22)");
    elif size = 2^7 * 3^3 * 5^2 * 7  then
        return rec(series:="Spor",name:="HJ = J(2) = F(5-)");
    elif size = 2^7 * 3^2 * 5 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="M(23)");
    elif size = 2^9 * 3^2 * 5^3 * 7 * 11  then
        return rec(series:="Spor",name:="HS");
    elif size = 2^7 * 3^5 * 5 * 17 * 19  then
        return rec(series:="Spor",name:="J(3)");
    elif size = 2^10 * 3^3 * 5 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="M(24)");
    elif size = 2^7 * 3^6 * 5^3 * 7 * 11  then
        return rec(series:="Spor",name:="Mc");
    elif size = 2^10 * 3^3 * 5^2 * 7^3 * 17  then
        return rec(series:="Spor",name:="He = F(7)");
    elif size = 2^14 * 3^3 * 5^3 * 7 * 13 * 29  then
        return rec(series:="Spor",name:="Ru");
    elif size = 2^13 * 3^7 * 5^2 * 7 * 11 * 13  then
        return rec(series:="Spor",name:="Suz");
    elif size = 2^9 * 3^4 * 5 * 7^3 * 11 * 19 * 31  then
        return rec(series:="Spor",name:="ON");
    elif size = 2^10 * 3^7 * 5^3 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="Co(3)");
    elif size = 2^18 * 3^6 * 5^3 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="Co(2)");
    elif size = 2^17 * 3^9 * 5^2 * 7 * 11 * 13  then
        return rec(series:="Spor",name:="Fi(22)");
    elif size = 2^14 * 3^6 * 5^6 * 7 * 11 * 19  then
        return rec(series:="Spor",name:="HN = F(5) = F = F(5+)");
    elif size = 2^8 * 3^7 * 5^6 * 7 * 11 * 31 * 37 * 67  then
        return rec(series:="Spor",name:="Ly");
    elif size = 2^15 * 3^10 * 5^3 * 7^2 * 13 * 19 * 31  then
        return rec(series:="Spor",name:="Th = F(3) = E = F(3/3)");
    elif size = 2^18 * 3^13 * 5^2 * 7 * 11 * 13 * 17 * 23  then
        return rec(series:="Spor",name:="Fi(23)");
    elif size = 2^21 * 3^9 * 5^4 * 7^2 * 11 * 13 * 23  then
        return rec(series:="Spor",name:="Co(1) = F(2-)");
    elif size = 2^21 * 3^3 * 5 * 7 * 11^3 * 23 * 29 * 31 * 37 * 43  then
        return rec(series:="Spor",name:="J(4)");
    elif size = 2^21 * 3^16 * 5^2 * 7^3 * 11 * 13 * 17 * 23 * 29  then
        return rec(series:="Spor",name:="Fi(24) = F(3+)");
    elif size = 2^41*3^13*5^6*7^2*11*13*17*19*23*31*47  then
        return rec(series:="Spor",name:="B = F(2+)");
    elif size = 2^46*3^20*5^9*7^6*11^2*13^3*17*19*23*29*31*41*47*59*71  then
        return rec(series:="Spor",name:="M = F(1)");
    fi;

    # from now on we deal with groups of Lie-type

    # calculate the dominant prime of size
    q := Maximum( List( Collected( FactorsInt( size ) ), s -> s[1]^s[2] ) );
    p := FactorsInt( q )[1];

    # test if <G> is the Chevalley group A(1,7) ~ A(2,2)
    if size = 168  then
        return rec(series:="L",parameter:=[2,7],
                   name:=Concatenation( "A(1,7) = L(2,7) ",
                            "~ B(1,7) = O(3,7) ",
                            "~ C(1,7) = S(2,7) ",
                            "~ 2A(1,7) = U(2,7) ",
                            "~ A(2,2) = L(3,2)" ));
    fi;

    # test if <G> is the Chevalley group A(1,8), where p = 3 <> char.
    if size = 504  then
        return rec(series:="L",parameter:=[2,8],
	           name:=Concatenation( "A(1,8) = L(2,8) ",
                            "~ B(1,8) = O(3,8) ",
                            "~ C(1,8) = S(2,8) ",
                            "~ 2A(1,8) = U(2,8)" ));
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>-1), where p = 2 <> char.
    if    p = 2  and IsPrime(q-1)
      and size = (q-1) * ((q-1)^2-1) / Gcd(2,(q-1)-1)
    then
        return rec(series:="L",parameter:=[2,q-1],
	           name:=Concatenation( "A(",  "1", ",", String(q-1), ") ",
                            "= L(",  "2", ",", String(q-1), ") ",
                            "~ B(",  "1", ",", String(q-1), ") ",
                            "= O(",  "3", ",", String(q-1), ") ",
                            "~ C(",  "1", ",", String(q-1), ") ",
                            "= S(",  "2", ",", String(q-1), ") ",
                            "~ 2A(", "1", ",", String(q-1), ") ",
                            "= U(",  "2", ",", String(q-1), ")" ));
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>), where p = 2^<k>+1 <> char.
    if    p <> 2  and IsPrimePowerInt( p-1 )
      and size = (p-1) * ((p-1)^2-1) / Gcd(2,(p-1)-1)
    then
        return rec(series:="L",parameter:=[2,p-1],
	           name:=Concatenation( "A(",  "1", ",", String(p-1), ") ",
                            "= L(",  "2", ",", String(p-1), ") ",
                            "~ B(",  "1", ",", String(p-1), ") ",
                            "= O(",  "3", ",", String(p-1), ") ",
                            "~ C(",  "1", ",", String(p-1), ") ",
                            "= S(",  "2", ",", String(p-1), ") ",
                            "~ 2A(", "1", ",", String(p-1), ") ",
                            "= U(",  "2", ",", String(p-1), ")" ));
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
        return rec(series:="L",parameter:=[2,q],
	           name:=Concatenation( "A(", "1", ",", String(q), ") ",
                            "= L(", "2", ",", String(q), ") ",
                            "~ B(", "1", ",", String(q), ") ",
                            "= O(", "3", ",", String(q), ") ",
                            "~ C(", "1", ",", String(q), ") ",
                            "= S(", "2", ",", String(q), ") ",
                            "~ 2A(","1", ",", String(q), ") ",
                            "= U(", "2", ",", String(q), ")" ));
    fi;

    # test if <G> is a Chevalley group A(3,q) ~ D(3,q)
    # exceptions: A(3,2) ~ A(8)
    if n = 3  and size = size2  then
        return rec(series:="L",parameter:=[4,q],
	           name:=Concatenation( "A(", "3", ",", String(q), ") ",
                            "= L(", "4", ",", String(q), ") ",
                            "~ D(", "3", ",", String(q), ") ",
                            "= O+(","6", ",", String(q), ") " ));
    fi;

    # test if <G> is a Chevalley group A(n,q)
    if size = size2  then
        return rec(series:="L",parameter:=[n+1,q],
	           name:=Concatenation( "A(", String(n),   ",", String(q), ") ",
                            "= L(", String(n+1), ",", String(q), ") " ));
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
        return rec(series:="B",parameter:=[2,3],
	           name:=Concatenation( "B(2,3) = O(5,3) ",
                            "~ C(2,3) = S(4,3) ",
                            "~ 2A(3,2) = U(4,2) ",
                            "~ 2D(3,2) = O-(6,2)" ));
    fi;

    # Rule out the case B(2,2) ~ S(6) if only the group order is given.
    if size = 720 then
      if IsGroup( G ) then
        Error( "A new simple group, whoaw" );
      else
        return fail;
      fi;
    fi;

    # test if <G> is a Chevalley group B(2,q) ~ C(2,q)
    # non-simple: B(2,2) ~ S(6)
    if n = 2  and size = size2  then
        return rec(series:="B",parameter:=[2,q],
	           name:=Concatenation( "B(2,", String(q), ") ",
                            "= O(5,", String(q), ") ",
                            "~ C(2,", String(q), ") ",
                            "= S(4,", String(q), ")" ));
    fi;

    # test if <G> is a Chevalley group B(n,2^m) ~ C(n,2^m)
    # non-simple: B(2,2) ~ S(6)
    if p = 2  and size = size2  then
        return rec(series:="B",parameter:=[n,q],
	           name:=Concatenation("B(",String(n),  ",", String(q), ") ",
                            "= O(", String(2*n+1), ",", String(q), ") ",
                            "~ C(", String(n),     ",", String(q), ") ",
                            "= S(", String(2*n),   ",", String(q), ")" ));
    fi;

    # test if <G> is a Chevalley group B(n,q) or C(n,q), 2 < n and q odd
    if p <> 2  and size = size2  then

        # check that <G> is a group
        if not IsGroup( G )  then
            return rec(name:=Concatenation( "cannot decide from size alone between ",
                                  "B(", String(n),     ",", String(q), ") ",
                                "= O(", String(2*n+1), ",", String(q), ") ",
                                "and ",
                                  "C(", String(n),   ",", String(q), ") ",
                                "= S(", String(2*n), ",", String(q), ")" ));
        fi;

        # find a <p>-central element and its centralizer
        C := Centre(SylowSubgroup(G,p));
        repeat
            g := Random(C);
        until Order(g) = p;
        C := Centralizer(G,g);

        if Size(C) mod (q^(2*n-2)-1) <> 0 then
            return rec(series:="B",parameter:=[n,q],
	               name:=Concatenation("B(", String(n),",",String(q),") ",
                                "= O(", String(2*n+1), ",", String(q), ")"));
        else
            return rec(series:="C",parameter:=[n,q],
	               name:=Concatenation( "C(",String(n),",",String(q),") ",
                                "= S(", String(2*n), ",", String(q), ")" ));
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
        return rec(series:="D",parameter:=[n,q],
	           name:=Concatenation("D(",String(n),",",String(q), ") ",
                            "= O+(", String(2*n), ",", String(q), ")" ));
    fi;

    # test whether <G> is an exceptional Chevalley group E(6,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^36 * (q^12-1)*(q^9-1)*(q^8-1)
                      *(q^6-1)*(q^5-1)*(q^2-1) / Gcd(3,q-1);
    until size <= size2;
    if size = size2 then
        return rec(series:="E",parameter:=[6,q],
	           name:=Concatenation( "E(", "6", ",", String(q), ")" ));
    fi;

    # test whether <G> is an exceptional Chevalley group E(7,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^63 * (q^18-1)*(q^14-1)*(q^12-1)*(q^10-1)
                      *(q^8-1)*(q^6-1)*(q^2-1) / Gcd(2,q-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="E",parameter:=[7,q],
	           name:=Concatenation( "E(", "7", ",", String(q), ")" ));
    fi;

    # test whether <G> is an exceptional Chevalley group E(8,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^120 * (q^30-1)*(q^24-1)*(q^20-1)*(q^18-1)
                       *(q^14-1)*(q^12-1)*(q^8-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="E",parameter:=[8,q],
	           name:=Concatenation( "E(", "8", ",", String(q), ")" ));
    fi;

    # test whether <G> is an exceptional Chevalley group F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^24 * (q^12-1)*(q^8-1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="F",parameter:=q,
	           name:=Concatenation( "F(4,", String(q), ")" ));
    fi;

    # Rule out the case G(2,2) ~ U(3,3).2 if only the group order is given.
    if size = 12096 then
      if IsGroup( G ) then
        Error( "A new simple group, whoaw" );
      else
        return fail;
      fi;
    fi;

    # test whether <G> is an exceptional Chevalley group G(2,q)
    # exceptions: G(2,2) ~ U(3,3).2
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^6 * (q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="G",parameter:=q,
	           name:=Concatenation( "G(", "2", ",", String(q), ")" ));
    fi;

    # test if <G> is 2A(2,3), where p = 2 <> char.
    if size = 3^3*(3^2-1)*(3^3+1)  then
        return rec(series:="2A",parameter:=[2,3],
	           name:="2A(2,3) = U(3,3)");
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
    # exceptions: 2A(3,2) ~ B(2,3) ~ C(2,3)
    # (The exception need not be ruled out in the case that only the group
    # order is given, since the dominant prime for group order 72 is 3.)
    if n = 3  and size = size2  then
        return rec(series:="2A",parameter:=[3,q],
	           name:=Concatenation( "2A(", "3", ",", String(q), ") ",
                            "= U(",  "4", ",", String(q), ") ",
                            "~ 2D(", "3", ",", String(q), ") ",
                            "= O-(", "6", ",", String(q), ")" ));
    fi;

    # test if <G> is a Steinberg group 2A(n,q)
    # non-simple: 2A(2,2) ~ 3^2 . Q(8)
    if size = size2  then
        return rec(series:="2A",parameter:=[n,q],
	           name:=Concatenation("2A(",String(n),",", String(q), ") ",
                            "= U(",  String(n+1), ",", String(q), ")" ));
    fi;

    # test whether <G> is a Suzuki group 2B(2,q) = 2C(2,q) = Sz(q)
    # non-simple: 2B(2,2) = 5:4
    # (The exception need not be ruled out in the case that only the group
    # order is given, since the dominant prime for group order 20 is 5.)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^2 * (q^2+1)*(q-1);
    until size <= size2;
    if p = 2  and m mod 2 = 1  and size = size2  then
        return rec(series:="2B",parameter:=q,
	           name:=Concatenation( "2B(", "2", ",", String(q), ") ",
                            "= 2C(", "2", ",", String(q), ") ",
                            "= Sz(",           String(q), ")" ));
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
        return rec(series:="2D",parameter:=[n,q],
	           name:=Concatenation("2D(",String(n),",", String(q), ") ",
                            "= O-(", String(2*n), ",", String(q), ")" ));
    fi;

    # test whether <G> is a Steinberg group 3D4(q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^8+q^4+1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="3D",parameter:=q,
	           name:=Concatenation( "3D(", "4", ",", String(q), ")" ));
    fi;


    # test whether <G> is a Steinberg group 2E6(q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^36 * (q^12-1)*(q^9+1)*(q^8-1)
                       *(q^6-1)*(q^5+1)*(q^2-1) / Gcd(3,q+1);
    until size <= size2;
    if size = size2  then
        return rec(series:="2E",parameter:=q,
	           name:=Concatenation( "2E(", "6", ",", String(q), ")" ));
    fi;

    # test if <G> is the Ree group 2F(4,q)'
    if size = 2^12 * (2^6+1)*(2^4-1)*(2^3+1)*(2-1) / 2  then
        return rec(series:="2F",parameter:=2,
	           name:="2F(4,2)' = Ree(2)' = Tits");
    fi;

    # test whether <G> is a Ree group 2F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^6+1)*(q^4-1)*(q^3+1)*(q-1);
    until size <= size2;
    if p = 2  and 1 < m  and m mod 2 = 1  and size = size2  then
        return rec(series:="2F",parameter:=q,
	           name:=Concatenation( "2F(", "4", ",", String(q), ") ",
                           "= Ree(",           String(q), ")" ));
    fi;

    # test whether <G> is a Ree group 2G(2,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^3 * (q^3+1)*(q-1);
    until size <= size2;
    if p = 3  and 1 < m  and m mod 2 = 1  and size = size2  then
        return rec(series:="2G",parameter:=q,
	           name:=Concatenation( "2G(", "2", ",", String(q), ") ",
                           "= Ree(",           String(q), ")" ));
    fi;

    # or a new simple group is found
    if IsGroup( G ) then
      Error( "A new simple group, whoaw" );
    else
      return fail;
    fi;
end );


#############################################################################
##
#M  PrintObj( <G> )
##
InstallMethod( PrintObj,
    "for a group",
    [ IsGroup ],
    function( G )
    Print( "Group( ... )" );
    end );

InstallMethod( PrintObj,
    "for a group with generators",
    [ IsGroup and HasGeneratorsOfGroup ],
    function( G )
    if IsEmpty( GeneratorsOfGroup( G ) ) then
      Print( "Group( ", One( G ), " )" );
    else
      Print( "Group( ", GeneratorsOfGroup( G ), " )" );
    fi;
    end );


#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . . .  view a group
##
InstallMethod( ViewObj,
    "for a group",
    [ IsGroup ],
    function( G )
    Print( "<group>" );
    end );

InstallMethod( ViewObj,
    "for a group with generators",
    [ IsGroup and HasGeneratorsOfMagmaWithInverses ],
    function( G )
    if IsEmpty( GeneratorsOfMagmaWithInverses( G ) ) then
      Print( "<trivial group>" );
    else
      Print( "<group with ",
             Length( GeneratorsOfMagmaWithInverses( G ) ),
             " generators>" );
    fi;
    end );

InstallMethod( ViewObj,
    "for a group with generators and size",
    [ IsGroup and HasGeneratorsOfMagmaWithInverses and HasSize],
    function( G )
    if IsEmpty( GeneratorsOfMagmaWithInverses( G ) ) then
      Print( "<trivial group>" );
    else
      Print( "<group of size ",Size(G)," with ",
             Length( GeneratorsOfMagmaWithInverses( G ) ),
             " generators>" );
    fi;
    end );


#############################################################################
##
#M  GroupString( <M> )
##
InstallMethod(GroupString, "for a group", [ IsGroup,IsString ],
function( G,nam )
local s,b;
  if HasName(G) then
    s:=Name(G);
  else
    s:=nam;
  fi;
  s:=ShallowCopy(s);
  b:= false;
  if HasGeneratorsOfGroup(G) then
    b:=true;
    Append(s," (");
    Append(s,String(Length(GeneratorsOfGroup(G))));
    Append(s," gens");
  fi;
  if HasSize(G) then
    if not b then
      b:=true;
      Append(s," (");
    else
      Append(s,", ");
    fi;
    Append(s,"size ");
    Append(s,String(Size(G)));
  fi;
  if b then
    Append(s,")");
  fi;
  return s;
end );

#############################################################################
##
#M  GroupWithGenerators( <gens> ) . . . . . . . . group with given generators
#M  GroupWithGenerators( <gens>, <id> ) . . . . . group with given generators
##
InstallMethod( GroupWithGenerators,
    "generic method for collection",
    [ IsCollection ],
    function( gens )
    local G,fam,typ;

    fam:=FamilyObj(gens);
    if IsFinite(gens) then
      if not IsBound(fam!.defaultFinitelyGeneratedGroupType) then
	fam!.defaultFinitelyGeneratedGroupType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses
		      and IsFinitelyGeneratedGroup);
      fi;
      typ:=fam!.defaultFinitelyGeneratedGroupType;
    else
      if not IsBound(fam!.defaultGroupType) then
        fam!.defaultGroupType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses);
      fi;
      typ:=fam!.defaultGroupType;
    fi;

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens));

    return G;
    end );

InstallMethod( GroupWithGenerators,
    "generic method for collection and identity element",
    IsCollsElms, [ IsCollection, IsMultiplicativeElementWithInverse ],
    function( gens, id )
    local G,fam,typ;

    fam:=FamilyObj(gens);
    if IsFinite(gens) then
      if not IsBound(fam!.defaultFinitelyGeneratedGroupWithOneType) then
	fam!.defaultFinitelyGeneratedGroupWithOneType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses
		      and IsFinitelyGeneratedGroup and HasOne);
      fi;
      typ:=fam!.defaultFinitelyGeneratedGroupWithOneType;
    else
      if not IsBound(fam!.defaultGroupWithOneType) then
        fam!.defaultGroupWithOneType:=
	  NewType(fam,IsGroup and IsAttributeStoringRep
		      and HasGeneratorsOfMagmaWithInverses and HasOne);
      fi;
      typ:=fam!.defaultGroupWithOneType;
    fi;

    G:=rec();
    ObjectifyWithAttributes(G,typ,GeneratorsOfMagmaWithInverses,AsList(gens),
                            One,id);

    return G;
end );

InstallMethod( GroupWithGenerators,
    "method for empty list and element",
    [ IsList and IsEmpty, IsMultiplicativeElementWithInverse ],
    function( empty, id )
    local G,fam,typ;

    fam:= CollectionsFamily( FamilyObj( id ) );
    if not IsBound( fam!.defaultFinitelyGeneratedGroupWithOneType ) then
      fam!.defaultFinitelyGeneratedGroupWithOneType:=
        NewType( fam, IsGroup and IsAttributeStoringRep
                      and HasGeneratorsOfMagmaWithInverses
                      and IsFinitelyGeneratedGroup and HasOne );
    fi;
    typ:= fam!.defaultFinitelyGeneratedGroupWithOneType;

    G:= rec();
    ObjectifyWithAttributes( G, typ,
                             GeneratorsOfMagmaWithInverses, empty,
                             One, id );

    return G;
    end );


#############################################################################
##
#M  GroupByGenerators( <gens> ) . . . . . . . . . . . . . group by generators
#M  GroupByGenerators( <gens>, <id> )
##
InstallMethod( GroupByGenerators,
    "delegate to `GroupWithGenerators'",
    [ IsCollection ],
    GroupWithGenerators );

InstallMethod( GroupByGenerators,
    "delegate to `GroupWithGenerators'",
    IsCollsElms,
    [ IsCollection, IsMultiplicativeElementWithInverse ],
    GroupWithGenerators );

InstallMethod( GroupByGenerators,
    "delegate to `GroupWithGenerators'",
    [ IsList and IsEmpty, IsMultiplicativeElementWithInverse ],
    GroupWithGenerators );


#############################################################################
##
#M  IsCommutative( <G> ) . . . . . . . . . . . . . test if a group is abelian
##
InstallMethod( IsCommutative,
    "generic method for groups",
    [ IsGroup ],
    IsCommutativeFromGenerators( GeneratorsOfGroup ) );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithinverses( <emptylist> )
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for an empty list",
    [ IsList ],
    function( list )
    if IsEmpty( list ) then
      return true;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <gens> )
##
##  Eventually this default method should not be allowed to return `true'
##  since for each admissible generating set,
##  a specific method should be responsible.
##
InstallMethod( IsGeneratorsOfMagmaWithInverses,
    "for a list or collection",
    [ IsListOrCollection ],
    function( gens )
    if IsCollection( gens ) and
       ForAll( gens, x -> IsMultiplicativeElementWithInverse( x ) and
                          Inverse( x ) <> fail ) then
      Info( InfoWarning, 1,
            "default `IsGeneratorsOfMagmaWithInverses' method returns ",
            "`true' for ", gens );
      return true;
    fi;
    return false;
    end );


#############################################################################
##
#F  Group( <gen>, ... )
#F  Group( <gens> )
#F  Group( <gens>, <id> )
##
InstallGlobalFunction( Group, function( arg )

    if Length( arg ) = 1 and IsDomain( arg[1] ) then
      Error( "no longer supported ..." );
#T this was possible in GAP-3 ...

    # special case for matrices, because they may look like lists
    elif Length( arg ) = 1 and IsMatrix( arg[1] )
                           and IsGeneratorsOfMagmaWithInverses( arg ) then
      return GroupByGenerators( arg );

    # special case for matrices, because they may look like lists
    elif Length( arg ) = 2 and IsMatrix( arg[1] )
                           and IsGeneratorsOfMagmaWithInverses( arg ) then
      return GroupByGenerators( arg );

    # list of generators
    elif Length( arg ) = 1 and IsList( arg[1] ) and not IsEmpty( arg[1] )
                           and IsGeneratorsOfMagmaWithInverses( arg[1] ) then
      return GroupByGenerators( arg[1] );

    # list of generators plus identity
    elif Length( arg ) = 2 and IsList( arg[1] )
                           and IsGeneratorsOfMagmaWithInverses( arg[1] ) then
      return GroupByGenerators( arg[1], arg[2] );

    elif 0 < Length( arg ) and IsGeneratorsOfMagmaWithInverses( arg ) then
      return GroupByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)");
end );


#############################################################################
##
#M  PrimePowerComponents( <g> )
##
InstallMethod( PrimePowerComponents,
    "generic method",
    [ IsMultiplicativeElement ],
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
        r := o / q;
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
    [ IsMultiplicativeElement,
      IsPosInt ],
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
InstallMethod(\.,"group generators",true,[IsGroup,IsPosInt],
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
#F  NormalSubgroups( <G> )  . . . . . . . . . . . normal subgroups of a group
##
InstallGlobalFunction( NormalSubgroupsAbove, function (G,N,avoid)
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

end );

InstallMethod(NormalSubgroups,"generic class union",true,[IsGroup],
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
    [ IsGroup ],
function(G)
    local
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
InstallMethod(SmallGeneratingSet,"generators subset",true,[IsGroup],
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
InstallMethod(\<,"groups by smallest generating sets",IsIdenticalObj,
  [IsGroup,IsGroup],
function(a,b)
local l,m;
  l:=GeneratorsSmallest(a);
  m:=GeneratorsSmallest(b);
  # we now MUST pad the shorter list!
  if Length(l)<Length(m) then
    a:=LargestElementGroup(a);
    l:=ShallowCopy(l);
    while Length(l)<Length(m) do Add(l,a);od;
  else
    b:=LargestElementGroup(b);
    m:=ShallowCopy(m);
    while Length(m)<Length(l) do Add(m,b);od;
  fi;
  return l<m;
end);


#############################################################################
##
#F  PowerMapOfGroupWithInvariants( <G>, <n>, <ccl>, <invariants> )
##
InstallGlobalFunction( PowerMapOfGroupWithInvariants,
    function( G, n, ccl, invariants )

    local reps,      # list of representatives
          ord,       # list of representative orders
          invs,      # list of invariant tuples for representatives
          map,       # power map, result
          nccl,      # no. of classes
          i,         # loop over the classes
          candord,   # order of the power
          cand,      # candidates for the power class
          len,       # no. of candidates for the power class
          j,         # loop over `cand'
          c,         # one candidate
          pow,       # power of a representative
          powinv;    # invariants of `pow'

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
end );


#############################################################################
##
#M  PowerMapOfGroup( <G>, <n>, <ccl> )  . . . . . . . . . . . . . for a group
##
##  We use only element orders as invariant of conjugation.
##
InstallMethod( PowerMapOfGroup,
    "method for a group",
    [ IsGroup, IsInt, IsHomogeneousList ],
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
    [ IsGroup and IsPermCollection, IsInt, IsHomogeneousList ],
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
    [ IsGroup and IsRingElementCollCollColl, IsInt, IsHomogeneousList ],
    function( G, n, ccl )
    return PowerMapOfGroupWithInvariants( G, n, ccl, [ TraceMat ] );
    end );


#############################################################################
##
#M  KnowsHowToDecompose(<G>,<gens>)      test whether the group can decompose
##                                       into the generators
##
InstallMethod( KnowsHowToDecompose,"generic: just groups of order < 1000",
    IsIdenticalObj, [ IsGroup, IsList ],
function(G,l)
  if CanComputeSize(G) then
    return Size(G)<1000;
  else
    return false;
  fi;
end);

InstallOtherMethod( KnowsHowToDecompose,"trivial group",true,
  [IsGroup,IsEmpty],
function(G,l)
  return true;
end);

InstallMethod( KnowsHowToDecompose,
    "group: use GeneratorsOfGroup",
    [ IsGroup ],
    G -> KnowsHowToDecompose( G, GeneratorsOfGroup( G ) ) );


#############################################################################
##
#M  HasAbelianFactorGroup(<G>,<N>)   test whether G/N is abelian
##
InstallGlobalFunction(HasAbelianFactorGroup,function(G,N)
local gen;
  gen:=Filtered(GeneratorsOfGroup(G),i->not i in N);
  return ForAll([1..Length(gen)],
                i->ForAll([1..i-1],j->Comm(gen[i],gen[j]) in N));
end);

#############################################################################
##
#M  HasElementaryAbelianFactorGroup(<G>,<N>)   test whether G/N is el. abelian
##
InstallGlobalFunction(HasElementaryAbelianFactorGroup,function(G,N)
local gen,p;
  if not HasAbelianFactorGroup(G,N) then
    return false;
  fi;
  gen:=Filtered(GeneratorsOfGroup(G),i->not i in N);
  p:=First([2..Order(gen[1])],i->gen[1]^i in N);
  return IsPrime(p) and ForAll(gen{[2..Length(gen)]},i->i^p in N);
end);


#############################################################################
##
#M  PseudoRandom( <group> ) . . . . . . . . pseudo random elements of a group
##
BindGlobal("Group_InitPseudoRandom",function( grp, len, scramble )
    local   gens,  seed,  i;

    # we need at least as many seeds as generators
    gens := GeneratorsOfGroup(grp);
    if 0 = Length(gens)  then
        SetPseudoRandomSeed( grp, [[]] );
        return;
    fi;
    len := Maximum( len, Length(gens), 2 );

    # add random generators
    seed := ShallowCopy(gens);
    for i  in [ Length(gens)+1 .. len ]  do
        seed[i] := Random(gens);
    od;
    SetPseudoRandomSeed( grp, [seed] );

    # scramble seed
    for i  in [ 1 .. scramble ]  do
        PseudoRandom(grp);
    od;

end);


InstallGlobalFunction(Group_PseudoRandom,
function( grp )
    local   seed,  i,  j;

    # set up the seed
    if not HasPseudoRandomSeed(grp)  then
        i := Length(GeneratorsOfGroup(grp));
        Group_InitPseudoRandom( grp, i+10, Maximum( i*10, 100 ) );
    fi;
    seed := PseudoRandomSeed(grp);
    if 0 = Length(seed[1])  then
        return One(grp);
    fi;

    # construct the next element
    i := Random([ 1 .. Length(seed[1]) ]);

    repeat
        j := Random([ 1 .. Length(seed[1]) ]);
    until i <> j;

    if Random([true,false])  then
        seed[1][j] := seed[1][i] * seed[1][j];
    else
        seed[1][j] := seed[1][j] * seed[1][i];
    fi;

    return seed[1][j];

end );

InstallMethod( PseudoRandom, "product replacement",
    [ IsGroup and HasGeneratorsOfGroup ], Group_PseudoRandom); 

#############################################################################
##
#M  ConjugateSubgroups( <G>, <U> )
##
InstallMethod(ConjugateSubgroups,"generic",IsIdenticalObj,[IsGroup,IsGroup],
function(G,U)
  # catch a few normal cases
  if HasIsNormalInParent(U) and IsNormalInParent(U) then
    if CanComputeIsSubset(Parent(U),G) and IsSubset(Parent(U),G) then
      return [U];
    fi;
  fi;
  return AsList(ConjugacyClassSubgroups(G,U));
end);

InstallTrueMethod( CanComputeSize, HasSize );

InstallMethod( CanComputeIndex,"by default impossible unless identical",
  IsIdenticalObj, [IsGroup,IsGroup],
function(G,U)
  if IsIdenticalObj(G,U) then
    return true;
  else
    return false;
  fi;
end);

InstallMethod( CanComputeIndex,"if sizes can be computed",IsIdenticalObj,
  [IsGroup and CanComputeSize,IsGroup and CanComputeSize],
function(G,U)
  # if the size can be computed only because it is known to be infinite bad
  # luck
  if HasSize(G) and Size(G)=infinity or
     HasSize(U) and Size(U)=infinity then
    TryNextMethod();
  fi;
  return true;
end);

InstallMethod( CanComputeIsSubset,"if membership test works",IsIdenticalObj,
  [IsDomain and CanEasilyTestMembership,IsGroup and HasGeneratorsOfGroup],
  ReturnTrue);

#############################################################################
##
#M  CanComputeSizeAnySubgroup( <grp> ) . . .. . . . . . subset relation
##
##  Since factor groups might be in a different representation,
##  they should *not* inherit this filter automagically.
##
InstallSubsetMaintenance( CanComputeSizeAnySubgroup,
     IsGroup and CanComputeSizeAnySubgroup, IsGroup );

#############################################################################
##
#F  Factorization( <G>, <elm> )
##
InstallGlobalFunction(Factorization,function(G,elm)
local F;
  if not IsBound(G!.factFreeMap) then
    F:=FreeGroup(List([1..Length(GeneratorsOfGroup(G))],
                 i->Concatenation("x",String(i))));
    G!.factFreeMap:=GroupGeneralMappingByImages(G,F,GeneratorsOfGroup(G),
						    GeneratorsOfGroup(F));
  fi;
  return ImagesRepresentativeGMBIByElementsList(G!.factFreeMap,elm);
end);


#############################################################################
##
#M  Order( <G> )
##
##  Since groups are domains, the recommended command to compute the order
##  of a group if `Size' (see~"Size").
##  For convenience, group orders can also be computed with `Order'.
##
##  *Note* that the existence of this method makes it necessary that no
##  group will ever be regarded as a multiplicative element!
##
InstallOtherMethod( Order,
    "for a group",
    [ IsGroup ],
    Size );


#############################################################################
##
#E

