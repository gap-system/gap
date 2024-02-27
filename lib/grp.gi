#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler, Bettina Eick, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for groups.
##


#############################################################################
##
#M  IsFinitelyGeneratedGroup( <G> ) . . test if a group is finitely generated
##
InstallImmediateMethod( IsFinitelyGeneratedGroup,
    IsGroup and HasGeneratorsOfGroup,
    function( G )
    if IsFinite( GeneratorsOfGroup( G ) ) then
      return true;
    fi;
    TryNextMethod();
    end );

#############################################################################
##
#M  IsCyclic( <G> ) . . . . . . . . . . . . . . . . test if a group is cyclic
##
#  This used to be an immediate method. It was replaced by an ordinary
#  method since the flag is typically set when creating the group.
InstallMethod( IsCyclic, true, [IsGroup and HasGeneratorsOfGroup], 0,
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
    local a;

    # if <G> has a generator list of length 1 then <G> is cyclic
    if HasGeneratorsOfGroup( G ) and Length( GeneratorsOfGroup(G) ) = 1 then
      a:=GeneratorsOfGroup(G)[1];
      if CanEasilyCompareElements(a) and not IsOne(a) then
        SetMinimalGeneratingSet(G,GeneratorsOfGroup(G));
      fi;
      return true;

    # if <G> is not commutative it is certainly not cyclic
    elif not IsCommutative( G )  then
        return false;

    # if <G> is finite, test if the <p>-th powers of the generators
    # generate a subgroup of index <p> for all prime divisors <p>
    elif IsFinite( G )  then
        return ForAll( PrimeDivisors( Size( G ) ),
                p -> Index( G, SubgroupNC( G,
                                 List( GeneratorsOfGroup( G ),g->g^p)) ) = p );

    # otherwise test if the abelian invariants are that of $Z$
    else
      return AbelianInvariants( G ) = [ 0 ];
    fi;
    end );

InstallMethod( Size,
    "for a cyclic group",
    [ IsGroup and IsCyclic and HasGeneratorsOfGroup and CanEasilyCompareElements ],
    {} -> -RankFilter(HasGeneratorsOfGroup),
function(G)
  local gens;
  if HasMinimalGeneratingSet(G) then
    gens:=MinimalGeneratingSet(G);
  else
    gens:=GeneratorsOfGroup(G);
  fi;
  if Length(gens) = 1 and gens[1] <> One(G) then
    SetMinimalGeneratingSet(G,gens);
    return Order(gens[1]);
  elif Length(gens) <= 1 then
    SetMinimalGeneratingSet(G,[]);
    return 1;
  fi;
  TryNextMethod();
end);

InstallMethod( MinimalGeneratingSet,"finite cyclic groups",true,
    [ IsGroup and IsCyclic and IsFinite ],
    {} -> RankFilter(IsFinite and IsPcGroup),
function ( G )
local g;
  if IsTrivial(G) then return []; fi;
  g:=Product(IndependentGeneratorsOfAbelianGroup(G),One(G));
  Assert( 1, Index(G,Subgroup(G,[g])) = 1 );
  return [g];
end);

#############################################################################
##
#M  MinimalGeneratingSet(<G>) . . . . . . . . . . . . . for groups
##
InstallMethod(MinimalGeneratingSet,"test solvable and 2-generator noncyclic",
  true, [IsGroup and IsFinite],0,
function(G)
  if not HasIsSolvableGroup(G) and IsSolvableGroup(G) and
     CanEasilyComputePcgs(G) then
    # discovered solvable -- redo
    return MinimalGeneratingSet(G);
  elif not IsSolvableGroup(G) then
    if IsGroup(G) and (not IsCyclic(G)) and HasGeneratorsOfGroup(G)
        and Length(GeneratorsOfGroup(G)) = 2 then
      return GeneratorsOfGroup(G);
    fi;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  MinimalGeneratingSet(<G>)
##
InstallOtherMethod(MinimalGeneratingSet,"fallback method to inform user",true,
  [IsObject],0,
function(G)
  if IsGroup(G) and IsSolvableGroup(G) then
    TryNextMethod();
  else
    Error(
  "`MinimalGeneratingSet' currently assumes that the group is solvable, or\n",
  "already possesses a generating set of size 2.\n",
  "In general, try `SmallGeneratingSet' instead, which returns a generating\n",
  "set that is small but not of guaranteed smallest cardinality");
  fi;
end);

InstallOtherMethod(MinimalGeneratingSet,"finite groups",true,
  [IsGroup and IsFinite],0,
function(g)
local r,i,j,u,f,q,n,lim,sel,nat,ok,mi;
  if not HasIsSolvableGroup(g) and IsSolvableGroup(g) and
     CanEasilyComputePcgs(g) then
    return MinimalGeneratingSet(g);
  fi;
  # start at rank 2/abelian rank
  n:=AbelianInvariants(g);
  if Length(n)>0 then
    r:=Maximum(List(Set(List(n,SmallestPrimeDivisor)),
      x->Number(n,y->y mod x=0)));
  else r:=0; fi;
  r:=Maximum(r,2);
  n:=false;
  repeat
    if Length(GeneratorsOfGroup(g))=r then
      return GeneratorsOfGroup(g);
    fi;
    for i in [1..10^r] do
      u:=SubgroupNC(g,List([1..r],x->Random(g)));
      if Size(u)=Size(g) then return GeneratorsOfGroup(u);fi; # found
    od;
    f:=FreeGroup(r);
    ok:=false;
    if not IsSolvableGroup(g) then
      if n=false then
        n:=ShallowCopy(NormalSubgroups(g));
        if IsPerfectGroup(g) then
          # all perfect groups of order <15360 *are* 2-generated
          lim:=15360;
        else
          # all groups of order <8 *are* 2-generated
          lim:=8;
        fi;
        n:=Filtered(n,x->IndexNC(g,x)>=lim and Size(x)>1);
        SortBy(n,x->-Size(x));
        mi:=MinimalInclusionsGroups(n);
      fi;
      i:=1;
      while i<=Length(n) do
        ok:=false;
        # is factor randomly r-generated?
        q:=2^r;
        while ok=false and q>0 do
          u:=n[i];
          for j in [1..r] do
            u:=ClosureGroup(u,Random(g));
          od;
          ok:=Size(u)=Size(g);
          q:=q-1;
        od;

        if not ok then
          # is factor a nonsplit extension with minimal normal -- if so rank
          # stays the same, no new test

          # minimal overnormals
          sel:=List(Filtered(mi,x->x[1]=i),x->x[2]);
          if Length(sel)>0 then
            nat:=NaturalHomomorphismByNormalSubgroupNC(g,n[i]);
            for j in sel do
              if not ok then
                # nonsplit extension (so pre-images will still generate)?
                ok:=0=Length(
                  ComplementClassesRepresentatives(Image(nat),Image(nat,n[j])));
              fi;
            od;
          fi;
        fi;

        if not ok then
          q:=GQuotients(f,g/n[i]:findall:=false);
          if Length(q)=0 then
            # fail in quotient
            i:=Length(n)+10;
            Info(InfoGroup,2,"Rank ",r," fails in quotient\n");
          fi;
        fi;

        i:=i+1;
      od;

    fi;
    if n=false or i<=Length(n)+1 then
      # still try group
      q:=GQuotients(f,g:findall:=false);
      if Length(q)>0 then return r;fi; # found
    fi;
    r:=r+1;
  until false;
end);


#############################################################################
##
#M  IsElementaryAbelian(<G>)  . . . . . test if a group is elementary abelian
##
InstallMethod( IsElementaryAbelian,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   i,          # loop
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

# The following helper function makes use of the fact that for any given prime
# p, any (possibly infinite) nilpotent group G is a p-group if and only if any
# generating set of G consists of p-elements (i.e. elements whose order is a
# power of p). For finite G this is well-known. The general case follows from
# e.g. 5.2.6 in "A Course in the Theory of Groups" by Derek J.S. Robinson,
# since it holds in the case were G is abelian, and since being a p-group is
# a property inherited by quotients and extensions.
BindGlobal( "IS_PGROUP_FOR_NILPOTENT",
    function( G )
    local p, gen, ord;

    p := fail;
    for gen in GeneratorsOfGroup( G ) do
      ord := Order( gen );
      if ord = infinity then
        return false;
      elif ord > 1 then
        if p = fail then
          p := SmallestRootInt( ord );
          if not IsPrimeInt( p ) then
            return false;
          fi;
        else
          if ord <> p^PValuation( ord, p ) then
            return false;
          fi;
        fi;
      fi;
    od;
    if p = fail then
      return true;
    fi;

    SetPrimePGroup( G, p );
    return true;
    end);

# The following helper function uses the well-known fact that a finite group
# is a p-group if and only if its order is a prime power.
BindGlobal( "IS_PGROUP_FROM_SIZE",
    function( G )
    local s, p;

    s:= Size( G );
    if s = 1 then
      return true;
    elif s = infinity then
      return fail; # cannot say anything about infinite groups
    fi;
    p := SmallestRootInt( s );
    if not IsPrimeInt( p ) then
      return false;
    fi;

    SetPrimePGroup( G, p );
    return true;
    end);

InstallMethod( IsPGroup,
    "generic method (check order of the group or of generators if nilpotent)",
    [ IsGroup ],
    function( G )

    # We inspect orders of group generators if the group order is not yet
    # known *and* the group knows to be nilpotent or is abelian;
    # thus an `IsAbelian' test may be forced (which can be done via comparing
    # products of generators) but *not* an `IsNilpotent' test.
    if HasSize( G ) and IsFinite( G ) then
      return IS_PGROUP_FROM_SIZE( G );
    elif ( HasIsNilpotentGroup( G ) and IsNilpotentGroup( G ) )
             or IsAbelian( G ) then
      return IS_PGROUP_FOR_NILPOTENT( G );
    elif IsFinite( G ) then
      return IS_PGROUP_FROM_SIZE( G );
    fi;
    TryNextMethod();
    end );

InstallMethod( IsPGroup,
    "for nilpotent groups",
    [ IsGroup and IsNilpotentGroup ],
    function( G )

    if HasSize( G ) and IsFinite( G ) then
      return IS_PGROUP_FROM_SIZE( G );
    else
      return IS_PGROUP_FOR_NILPOTENT( G );
    fi;
    end );


#############################################################################
##
#M  IsPowerfulPGroup( <G> ) . . . . . . . . . . is a group a powerful p-group ?
##
InstallMethod( IsPowerfulPGroup,
    "use characterisation of powerful p-groups based on rank ",
    [ IsGroup and HasRankPGroup and HasComputedOmegas ],
     function( G )
    local p;
    if (IsTrivial(G)) then
      return true;
    else
      p:=PrimePGroup(G);
      # We use the less known characterisation of powerful p groups
      # for p>3 by Jon Gonzalez-Sanchez, Amaia Zugadi-Reizabal
      # can be found in 'A characterization of powerful p-groups'
      if (p>3) then
        return RankPGroup(G)=Log(Order(Omega(G,p)),p);
      else
        TryNextMethod();
      fi;
    fi;
    end);


InstallMethod( IsPowerfulPGroup,
    "generic method checks inclusion of commutator subgroup in agemo subgroup",
    [ IsGroup ],
     function( G )
    local p;
    if IsPGroup( G ) = false then
      return false;
    elif IsTrivial(G) then
      return true;

    else

      p:=PrimePGroup(G);
      if p = 2 then
        return IsSubgroup(Agemo(G,2,2),DerivedSubgroup( G ));
      else
        return IsSubgroup(Agemo(G,p), DerivedSubgroup( G ));
      fi;
    fi;
    end);


#############################################################################
##
#M  IsRegularPGroup( <G> ) . . . . . . . . . . is a group a regular p-group ?
##
InstallMethod( IsRegularPGroup,
    [ IsGroup ],
function( G )
local p, hom, reps, a, b, ap_bp, ab_p, H;

  if not IsPGroup(G) then
    return false;
  fi;

  p:=PrimePGroup(G);
  if p = 2 then
    # see [Hup67, Satz 10.3 a)]
    return IsAbelian(G);
  elif p = 3 and DerivedLength(G) > 2 then
    # see [Hup67, Satz 10.3 b)]
    return false;
  elif Size(G) <= p^p then
    # see [Hal34, Corollary 14.14], [Hall, p. 183], [Hup67, Satz 10.2 b)]
    return true;
  elif NilpotencyClassOfGroup(G) < p then
    # see [Hal34, Corollary 14.13], [Hall, p. 183], [Hup67, Satz 10.2 a)]
    return true;
  elif IsCyclic(DerivedSubgroup(G)) then
    # see [Hup67, Satz 10.2 c)]
    return true;
  elif Exponent(G) = p then
    # see [Hup67, Satz 10.2 d)]
    return true;
  elif p = 3 and RankPGroup(G) = 2 then
    # see [Hup67, Satz 10.3 b)]: at this point we know that the derived
    # subgroup is not cyclic, hence G is not regular
    return false;
  elif Size(G) < p^p * Size(Agemo(G,p)) then
    # see [Hal36, Theorem 2.3], [Hup67, Satz 10.13]
    return true;
  elif Index(DerivedSubgroup(G),Agemo(DerivedSubgroup(G),p)) < p^(p-1) then
    # see [Hal36, Theorem 2.3], [Hup67, Satz 10.13]
    return true;
  fi;

  # Fallback to actually check the defining criterion, i.e.:
  # for all a,b in G, we must have that a^p*b^p/(a*b)^p in (<a,b>')^p

  # It suffices to pick 'a' among conjugacy class representatives.
  # Moreover, if 'a' is central then the criterion automatically holds.
  # For z,z'\in Z(G), the criterion holds for (a,b) iff it holds for (az,bz').
  # We thus choose 'a' among lifts of conjugacy class representatives in G/Z(G).
  hom := NaturalHomomorphismByNormalSubgroup(G, Center(G));
  reps := ConjugacyClasses(Image(hom));
  reps := List(reps, Representative);
  reps := Filtered(reps, g -> not IsOne(g));
  reps := List(reps, g -> PreImagesRepresentative(hom, g));

  for b in Image(hom) do
    b := PreImagesRepresentative(hom, b);
    for a in reps do
      # if a and b commute the regularity condition automatically holds
      if a*b = b*a then continue; fi;

      # regularity is also automatic if a^p * b^p = (a*b)^p
      ap_bp := a^p * b^p;
      ab_p := (a*b)^p;
      if ap_bp = ab_p then continue; fi;

      # if the subgroup generated H by a and b is itself regular, we are also
      # done. However we don't use recursion, here, as H may be equal to G;
      # and also we have to be careful to not use too expensive code here.
      # But a quick size check is certainly fine.
      H := Subgroup(G, [a,b]);
      if Size(H) <= p^p then continue; fi;

      # finally the full check
      H := DerivedSubgroup(H);
      if not (ap_bp / ab_p) in Agemo(H, p) then
        return false;
      fi;
    od;
  od;
  return true;

end);


#############################################################################
##
#M  PrimePGroup . . . . . . . . . . . . . . . . . . . . .  prime of a p-group
##
InstallMethod( PrimePGroup,
    "generic method, check the order of a nontrivial generator",
    [ IsPGroup and HasGeneratorsOfGroup ],
function( G )
local gen, s;
  if IsTrivial( G ) then
    return fail;
  fi;
  for gen in GeneratorsOfGroup( G ) do
    s := Order( gen );
    if s <> 1 then
      break;
    fi;
  od;
  return SmallestRootInt( s );
end );

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
  return SmallestRootInt( s );
end );

RedispatchOnCondition (PrimePGroup, true,
    [IsGroup],
    [IsPGroup], 0);


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
    "if group size can be computed and is a prime power",
    [ IsGroup and CanComputeSize ], 25,
    function ( G )
    local s;

    s := Size ( G );
    if IsInt( s ) and IsPrimePowerInt( s ) then
        SetIsPGroup( G, true );
        SetPrimePGroup( G, SmallestRootInt( s ) );
        return true;
    elif s = 1 then
        SetIsPGroup( G, true );
        return true;
    elif s <> infinity then
        SetIsPGroup( G, false );
    fi;
    TryNextMethod();
    end );


InstallMethod( IsNilpotentGroup,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   S;          # lower central series of <G>

    # compute the lower central series
    S := LowerCentralSeriesOfGroup( G );

    # <G> is nilpotent if the lower central series reaches the trivial group
    return IsTrivial( Last(S) );
    end );


#############################################################################
##
#M  IsPerfectGroup( <G> ) . . . . . . . . . . . .  test if a group is perfect
##
InstallImmediateMethod( IsPerfectGroup,
    IsGroup and HasIsAbelian and IsSimpleGroup,
    0,
    grp -> not IsAbelian( grp ) );

InstallMethod( IsPerfectGroup, "for groups having abelian invariants",
    [ IsGroup and HasAbelianInvariants ],
    grp -> Length( AbelianInvariants( grp ) ) = 0 );

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
#M  IsSporadicSimpleGroup( <G> )
##
InstallMethod( IsSporadicSimpleGroup,
    "for a group",
    [ IsGroup ],
    G ->     IsFinite( G )
         and IsSimpleGroup( G )
         and IsomorphismTypeInfoFiniteSimpleGroup( G ).series = "Spor" );


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

    if IsTrivial( G ) then
      return false;
    fi;

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
#P  IsAlmostSimpleGroup( <G> )
##
##  Since the outer automorphism groups of finite simple groups are solvable,
##  a finite group <A>G</A> is almost simple if and only if the last member
##  in the derived series of <A>G</A> is a simple group <M>S</M> (which is
##  then necessarily nonabelian) such that the centralizer of <M>S</M> in
##  <A>G</A> is trivial.
##
##  (We could detect whether the given group is an extension of a group of
##  prime order by some automorphisms, as follows.
##  If the derived series ends with the trivial group then take the previous
##  member of the series, and check whether it has prime order and is
##  self-centralizing.)
##
InstallMethod( IsAlmostSimpleGroup,
    "for a group",
    [ IsGroup ],
    function( G )
    local der;

    if IsAbelian( G ) then
      # Exclude simple groups of prime order.
      return false;
    elif IsSimpleGroup( G ) then
      # Nonabelian simple groups are almost simple.
      return true;
    elif not IsFinite( G ) then
      TryNextMethod();
    fi;

    der:= DerivedSeriesOfGroup( G );
    der:= Last(der);
    if IsTrivial( der ) then
      return false;
    fi;
    return IsSimpleGroup( der ) and IsTrivial( Centralizer( G, der ) );
    end );


#############################################################################
##
#P  IsQuasisimpleGroup( <G> )
##
InstallMethod( IsQuasisimpleGroup,
    "for a group",
    [ IsGroup ],
    G -> IsPerfectGroup( G ) and IsSimpleGroup( G / Centre( G ) ) );


#############################################################################
##
#M  IsSolvableGroup( <G> )  . . . . . . . . . . . test if a group is solvable
##
##  By the Feit–Thompson odd order theorem, every group of odd order is
##  solvable.
##
##  Now suppose G is a group of order 2m, with m odd. Let G act on itself from
##  the right, yielding a monomorphism \phi:G \to Sym(G). G contains an
##  involution h; then \phi(h) decomposes into a product of m disjoint
##  transpositions, hence sign(\phi(h)) = -1. Hence the kernel N of the
##  composition x \mapsto sign(\phi(x)) is a normal subgroup of G of index 2,
##  hence |N| = m.
##
##  By the odd order theorem, N is solvable, and so is G. Thus the order of
##  any non-solvable finite group is a multiple of 4.
##
##  By Burnside's theorem, every group of order p^a q^b is solvable. If a
##  group of such order is not already caught by the reasoning above, then
##  it must have order 2^a q^b with a>1.
##
InstallImmediateMethod( IsSolvableGroup, IsGroup and HasSize, 10,
    function( G )
    local size;
    size := Size( G );
    if IsInt( size ) and size mod 4 <> 0 then
      return true;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsSolvableGroup,
    "if group size is known and is not divisible by 4 or p^a q^b",
    [ IsGroup and HasSize ], 25,
    function( G )
    local size;
    size := Size( G );
    if IsInt( size ) then
      if size mod 4 <> 0 then
        return true;
      else
        size := size/4;
        while size mod 2 = 0 do
          size := size/2;
        od;
        if size = 1 then
          SetIsPGroup( G, true );
          SetPrimePGroup( G, 2 );
          return true;
        elif IsPrimePowerInt( size ) then
          return true;
        fi;
      fi;
    fi;
    TryNextMethod();
    end );

InstallMethod( IsSolvableGroup,
    "generic method for groups",
    [ IsGroup ],
    function ( G )
    local   S,          # derived series of <G>
            isAbelian,  # true if <G> is abelian
            isSolvable; # true if <G> is solvable

    # compute the derived series of <G>
    S := DerivedSeriesOfGroup( G );

    # the group is solvable if the derived series reaches the trivial group
    isSolvable := IsTrivial( Last(S) );

    # set IsAbelian filter
    isAbelian := isSolvable and Length( S ) <= 2;
    Assert(3, IsAbelian(G) = isAbelian);
    SetIsAbelian(G, isAbelian);

    return isSolvable;
    end );


#############################################################################
##
#M  IsSupersolvableGroup( <G> ) . . . . . .  test if a group is supersolvable
##
##  Note that this method automatically sets `SupersolvableResiduum'.
##  Analogously, methods for `SupersolvableResiduum' should set
##  `IsSupersolvableGroup'.
##
InstallMethod( IsSupersolvableGroup,
    "generic method for groups",
    [ IsGroup ],
    function( G )
    if IsNilpotentGroup( G ) then
#T currently the nilpotency test is much cheaper than the test below,
#T so we force it!
      return true;
    fi;
    return IsTrivial( SupersolvableResiduum( G ) );
    end );


#############################################################################
##
#M  IsPolycyclicGroup( <G> )  . . . . . . . . . test if a group is polycyclic
##
InstallMethod( IsPolycyclicGroup,
               "generic method for groups", true, [ IsGroup ], 0,

  function ( G )

    local  d;

    if IsFinite(G) then return IsSolvableGroup(G); fi;
    if not IsSolvableGroup(G) then return false; fi;
    d := DerivedSeriesOfGroup(G);
    return ForAll([1..Length(d)-1],i->Index(d[i],d[i+1]) < infinity
                                   or IsFinitelyGeneratedGroup(d[i]/d[i+1]));
  end );


#############################################################################
##
#M  IsTrivial( <G> )  . . . . . . . . . . . . . .  test if a group is trivial
##
InstallMethod( IsTrivial,
    [ IsGroup ],
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
        if HasIsCyclic(G) and IsCyclic(G) then
          return [ 0 ];
        fi;
        TryNextMethod();
    elif IsTrivial( G )  then
        return [];
    fi;

    gns := GeneratorsOfGroup( G );
    inv := [];
    # the parent of this will be G
    cmm := DerivedSubgroup(G);
    for p  in PrimeDivisors( Size( G ) )  do
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
                Add( ranks, Length(Factors(Integers,r)) );
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

InstallMethod( AbelianRank ,"generic method for groups", [ IsGroup ],0,
function(G)
local a,r;
  a:=AbelianInvariants(G);
  r:=Number(a,IsZero);
  a:=Filtered(a,x->not IsZero(x));
  if Length(a)=0 then return r; fi;
  a:=List(Set(a,SmallestRootInt),p->Number(a,x->x mod p=0));
  return r+Maximum(a);
end);


#############################################################################
##
#M  IsInfiniteAbelianizationGroup( <G> )
##
InstallMethod( IsInfiniteAbelianizationGroup,"generic method for groups",
[ IsGroup ], G->0 in AbelianInvariants(G));


#############################################################################
##
#M  AsGroup( <D> ) . . . . . . . . . . . . . . .  domain <D>, viewed as group
##
InstallMethod( AsGroup, [ IsGroup ], 100, IdFunc );

InstallMethod( AsGroup,
    "generic method for collections",
    [ IsCollection ],
    function( D )
    local M, gens, m, minv, G, L;

    if IsGroup( D ) then
      return D;
    fi;

    # Check that the elements in the collection form a nonempty semigroup.
    M:= AsMagma( D );
    if M = fail or not IsAssociative( M ) then
      return fail;
    fi;
    gens:= GeneratorsOfMagma( M );
    if IsEmpty( gens ) or not IsGeneratorsOfMagmaWithInverses( gens ) then
      return fail;
    fi;

    # Check that this semigroup contains the inverses of its generators.
    for m in gens do
      minv:= Inverse( m );
      if minv = fail or not minv in M then
        return fail;
      fi;
    od;

    D:= AsSSortedList( D );
    G:= TrivialSubgroup( GroupByGenerators( gens ) );
    L:= ShallowCopy( D );
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
    "method for a group (delegate to `ChiefSeriesUnderAction')",
    [ IsGroup ],
    G -> ChiefSeriesUnderAction( G, G ) );


#############################################################################
##
#M  RefinedSubnormalSeries( <ser>,<n> )
##
InstallGlobalFunction("RefinedSubnormalSeries",function(ser,sub)
local new,i,c;
  new:=[];
  i:=1;
  if not IsSubset(ser[1],sub) then
    sub:=Intersection(ser[1],sub);
  fi;
  while i<=Length(ser) and IsSubset(ser[i],sub) do
    Add(new,ser[i]);
    i:=i+1;
  od;
  while i<=Length(ser) and not IsSubset(sub,ser[i]) do
    c:=ClosureGroup(sub,ser[i]);
    if Size(Last(new))>Size(c) then
      Add(new,c);
    fi;
    if Size(Last(new))>Size(ser[i]) then
      Add(new,ser[i]);
    fi;
    sub:=Intersection(sub,ser[i]);
    i:=i+1;
  od;
  if Size(sub)<Size(Last(new)) and i<=Length(ser) and Size(sub)>Size(ser[i]) then
    Add(new,sub);
  fi;
  while i<=Length(ser) do
    Add(new,ser[i]);
    i:=i+1;
  od;
  Assert(1,ForAll([1..Length(new)-1],x->Size(new[x])<>Size(new[x+1])));
  return new;
end);



#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . . . .  commutator factor group of a group
##
InstallMethod( CommutatorFactorGroup,
    "generic method for groups",
    [ IsGroup ],
    function( G )
    G:= FactorGroupNC( G, DerivedSubgroup( G ) );
    SetIsAbelian( G, true );
    return G;
    end );


############################################################################
##
#M MaximalAbelianQuotient(<group>)
##
InstallMethod(MaximalAbelianQuotient,
    "not fp group",
    [ IsGroup ],
    function( G )
    if IsSubgroupFpGroup( G ) then
      TryNextMethod();
    fi;
    return NaturalHomomorphismByNormalSubgroupNC(G,DerivedSubgroup(G));
#T Here we know that the image is abelian, and this information may be
#T useful later on.
#T However, the image group of the homomorphism may be not stored yet,
#T so we do not attempt to set the `IsAbelian' flag for it.
end );

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
    if not IsTrivial(Last(der))  then
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

InstallMethod( CompositionSeries,
    "for simple group", true, [IsGroup and IsSimpleGroup], 100,
    S->[S,TrivialSubgroup(S)]);

InstallMethod(CompositionSeriesThrough,"intersection/union",IsElmsColls,
  [IsGroup and IsFinite,IsList],0,
function(G,normals)
local cs,i,j,pre,post,c,new,rev;
  cs:=CompositionSeries(G);
  # find normal subgroups not yet in
  normals:=Filtered(normals,x->not x in cs);
  # do we satisfy by sheer dumb luck?
  if Length(normals)=0 then return cs;fi;

  SortBy(normals,x->-Size(x));
  # check that this is a valid series
  Assert(0,ForAll([2..Length(normals)],i->IsSubset(normals[i-1],normals[i])));

  # Now move series through normals by closure/intersection
  for j in normals do
    # first in cs that does not contain j
    pre:=PositionProperty(cs,x->not IsSubset(x,j));
    # first contained in j.
    post:=PositionProperty(cs,x->Size(j)>=Size(x) and IsSubset(j,x));

    # if j is in the series, then pre>post. pre=post impossible
    if pre<post then
      # so from pre to post-1 needs to be changed
      new:=cs{[1..pre-1]};

      rev:=[j];
      i:=post-1;
      repeat
        if not IsSubset(Last(rev),cs[i]) then
          c:=ClosureGroup(cs[i],j);
          if Size(c)>Size(Last(rev)) then
            # proper down step
            Add(rev,c);
          fi;
        fi;
        i:=i-1;
        # at some point this must reach j, then no further step needed
      until Size(c)=Size(cs[pre-1]) or i<pre;
      Append(new,Filtered(Reversed(rev),x->Size(x)<Size(cs[pre-1])));

      i:=pre;
      repeat
        if not IsSubset(cs[i],Last(new)) then
          c:=Intersection(cs[i],j);
          if Size(c)<Size(Last(new)) then
            # proper down step
            Add(new,c);
          fi;
        fi;
        i:=i+1;
      until Size(c)=Size(cs[post]);
    fi;
    cs:=Concatenation(new,cs{[post+1..Length(cs)]});
  od;
  return cs;
end);


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
            lastS,      # last element of S
            D;          # derived subgroups

    # print out a warning for infinite groups
    if (HasIsFinite(G) and not IsFinite( G ))
      and not (HasIsPolycyclicGroup(G) and IsPolycyclicGroup( G )) then
      Info( InfoWarning, 1,
            "DerivedSeriesOfGroup: may not stop for infinite group <G>" );
    fi;

    # compute the series by repeated calling of `DerivedSubgroup'
    S := [ G ];
    lastS := G;
    Info( InfoGroup, 2, "DerivedSeriesOfGroup: step ", Length(S) );
    D := DerivedSubgroup( G );

    while
      (not HasIsTrivial(lastS) or
            not IsTrivial(lastS)) and
      (
        (not HasIsPerfectGroup(lastS) and
         not HasAbelianInvariants(lastS) and D <> lastS) or
        (HasIsPerfectGroup(lastS) and not IsPerfectGroup(lastS))
        or (HasAbelianInvariants(lastS)
                            and Length(AbelianInvariants(lastS)) > 0)
      ) do
        Add( S, D );
        lastS := D;
        Info( InfoGroup, 2, "DerivedSeriesOfGroup: step ", Length(S) );
        D := DerivedSubgroup( D );
    od;

    # set filters if the last term is known to be trivial
    if HasIsTrivial(lastS) and IsTrivial(lastS) then
      SetIsSolvableGroup(G, true);
      if Length(S) <=2 then
        Assert(3, IsAbelian(G));
        SetIsAbelian(G, true);
      fi;
    fi;

    # set IsAbelian filter if length of derived series is more than 2
    if Length(S) > 2 then
      Assert(3, not IsAbelian(G));
      SetIsAbelian(G, false);
    fi;

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

InstallMethod( DerivedSubgroup,
    "for a group that knows it is perfect",
    [ IsGroup and IsPerfectGroup ],
    SUM_FLAGS, # this is better than everything else
    IdFunc );

InstallMethod( DerivedSubgroup,
    "for a group that knows it is abelian",
    [ IsGroup and IsAbelian ],
    SUM_FLAGS, # this is better than everything else
    TrivialSubgroup );


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
    p := PrimePGroup( G );
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

    # if <G> is a list compute an elementary series through a given normal one
    if not IsSolvableGroup( G[1] )  then
      return fail;
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
    "generic method for finite groups",
    [ IsGroup and IsFinite],
    function( G )
    local f;

    # compute an elementary series if it is not known
    if not IsSolvableGroup( G )  then
      return fail;
    fi;

    # there is a method for pcgs computable groups we should use if
    # applicable, in this case redo
    if CanEasilyComputePcgs(G) then
      return ElementaryAbelianSeries(G);
    fi;

    f := IsomorphismPcGroup( G );

    # convert back into <G>
    return List( ElementaryAbelianSeries( Image( f )), x -> PreImage( f, x ) );
    end );

#############################################################################
##
#M  ElementaryAbelianSeries( <G> )  . .  elementary abelian series of a group
##
BindGlobal( "DoEASLS", function( S )
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
end );

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
    "generic method for finite groups",
    [ IsGroup and IsFinite ],
function(G)
  local exp, primes, p;
  exp := 1;
  primes := PrimeDivisors(Size(G));
  for p in primes do
    exp := exp * Exponent(SylowSubgroup(G, p));
  od;
  return exp;
end);

# ranked below the method for abelian groups
InstallMethod( Exponent,
    [ "IsGroup and IsFinite and HasConjugacyClasses" ],
    G-> Lcm(List(ConjugacyClasses(G), c-> Order(Representative(c)))) );

InstallMethod( Exponent,
    "method for finite abelian groups with generators",
    [ IsGroup and IsAbelian and HasGeneratorsOfGroup and IsFinite ],
    function( G )
    G:= GeneratorsOfGroup( G );
    if IsEmpty( G ) then
      return 1;
    fi;
    return Lcm( List( G, Order ) );
    end );

RedispatchOnCondition( Exponent, true, [IsGroup], [IsFinite], 0);

#############################################################################
##
#M  FittingSubgroup( <G> )  . . . . . . . . . . . Fitting subgroup of a group
##
InstallMethod( FittingSubgroup, "for nilpotent group",
    [ IsGroup and IsNilpotentGroup ], SUM_FLAGS, IdFunc );

InstallMethod( FittingSubgroup,
    "generic method for finite groups",
    [ IsGroup and IsFinite ],
    function (G)
        if not IsTrivial( G ) then
            G := SubgroupNC( G, Filtered(Union( List( PrimeDivisors( Size( G ) ),
                         p -> GeneratorsOfGroup( PCore( G, p ) ) ) ),
                         p->p<>One(G)));
            Assert( 2, IsNilpotentGroup( G ) );
            SetIsNilpotentGroup( G, true );
        fi;
        return G;
    end);

RedispatchOnCondition( FittingSubgroup, true, [IsGroup], [IsFinite], 0);


#############################################################################
##
#M  FrattiniSubgroup( <G> ) . . . . . . . . . .  Frattini subgroup of a group
##
InstallMethod( FrattiniSubgroup, "method for trivial groups",
            [ IsGroup and IsTrivial ], IdFunc );

InstallMethod( FrattiniSubgroup, "for abelian groups",
            [ IsGroup and IsAbelian ],
function(G)
    local i, abinv, indgen, p, q, gen;

    gen := [ ];
    abinv := AbelianInvariants(G);
    indgen := IndependentGeneratorsOfAbelianGroup(G);
    for i in [1..Length(abinv)] do
        q := abinv[i];
        if q<>0 and not IsPrime(q) then
            p := SmallestRootInt(q);
            Add(gen, indgen[i]^p);
        fi;
    od;
    return SubgroupNC(G, gen);
end);

InstallMethod( FrattiniSubgroup, "for powerful p-groups",
            [ IsPGroup and IsPowerfulPGroup and HasComputedAgemos ],100,
function(G)
    local p;
#If the group is powerful and has computed agemos, then no work needs
#to be done, since FrattiniSubgroup(G)=Agemo(G,p) in this case
#by properties of powerful p-groups.
        p:=PrimePGroup(G);
        return Agemo(G,p);
end);

InstallMethod( FrattiniSubgroup, "for nilpotent groups",
            [ IsGroup and IsNilpotentGroup ],
function(G)
    local hom, Gf;

    hom := MaximalAbelianQuotient(G);
    Gf := Image(hom);
    SetIsAbelian(Gf, true);
    return PreImage(hom, FrattiniSubgroup(Gf));
end);

InstallMethod( FrattiniSubgroup, "generic method for groups",
            [ IsGroup ],
            0,
function(G)
local m;
    if IsTrivial(G) then
      return G;
    fi;
    if not HasIsSolvableGroup(G) and IsSolvableGroup(G) then
       return FrattiniSubgroup(G);
    fi;
    m := List(ConjugacyClassesMaximalSubgroups(G),C->Core(G,Representative(C)));
    m := Intersection(m);
    if HasIsFinite(G) and IsFinite(G) then
      Assert(2,IsNilpotentGroup(m));
      SetIsNilpotentGroup(m,true);
    fi;
    return m;
end);


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
    p := PrimePGroup( G );

    # and compute the series
    # (this is a new variant thanks to Laurent Bartholdi)
    L := [ G ];
    n := 2;
    while not IsTrivial(L[n-1]) do
        L[n] := ClosureGroup(CommutatorSubgroup(G,L[n-1]),
            List(GeneratorsOfGroup(L[QuoInt(n+p-1,p)]),x->x^p));
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
    if (HasIsFinite(G) and not IsFinite( G ))
      and not (HasIsNilpotentGroup(G) and IsNilpotentGroup( G )) then
      Info( InfoWarning, 1,
            "LowerCentralSeriesOfGroup: may not stop for infinite group <G>");
    fi;

    # compute the series by repeated calling of `CommutatorSubgroup'
    S := [ G ];
    Info( InfoGroup, 2, "LowerCentralSeriesOfGroup: step ", Length(S) );
    C := DerivedSubgroup( G );
    while C <> Last(S) do
        Add( S, C );
        Info( InfoGroup, 2, "LowerCentralSeriesOfGroup: step ", Length(S) );
        C := CommutatorSubgroup( G, C );
    od;

    # return the series when it becomes stable
    return S;
    end );

#############################################################################
##
#M  NilpotencyClassOfGroup( <G> )  . . . . lower central series of a group
##
InstallMethod(NilpotencyClassOfGroup,"generic",[IsGroup],0,
function(G)
  if not IsNilpotentGroup(G) then
    Error("<G> must be nilpotent");
  fi;
  return Length(LowerCentralSeriesOfGroup(G))-1;
end);

#############################################################################
##
#M  MaximalSubgroups( <G> )
##
InstallMethod(MaximalSubgroupClassReps,"default, catch dangerous options",
  true,[IsGroup],0,
function(G)
local a,m,i,l;
  # use ``try'' and set flags so that a known partial result is not used
  m:=TryMaximalSubgroupClassReps(G:
          cheap:=false,intersize:=false,inmax:=false,nolattice:=false);
  l:=[];
  for i in m do
    a:=SubgroupNC(G,GeneratorsOfGroup(i));
    if HasSize(i) then SetSize(a,Size(i));fi;
    Add(l,a);
  od;

  # now we know list is untained, store
  return l;

end);

# handle various options and flags
InstallGlobalFunction(TryMaximalSubgroupClassReps,
function(G)
local cheap,nolattice,intersize,attr,kill,i,flags,sup,sub,l;
  if HasMaximalSubgroupClassReps(G) then
    return MaximalSubgroupClassReps(G);
  fi;
  # the four possible options
  cheap:=ValueOption("cheap");
  if cheap=fail then cheap:=false;fi;
  nolattice:=ValueOption("nolattice");
  if nolattice=fail then nolattice:=false;fi;
  intersize:=ValueOption("intersize");
  if intersize=fail then intersize:=false;fi;
  #inmax:=ValueOption("inmax"); # should have no impact on validity of stored
  attr:=StoredPartialMaxSubs(G);
  # now find whether any stored information matches and which ones would be
  # superseded
  kill:=[];
  for i in [1..Length(attr)] do
    flags:=attr[i][1];
    # could use this stored result
    sup:=flags[3]=false or (IsInt(intersize) and intersize<=flags[3]);
    # would supersede the stored result
    sub:=intersize=false or (IsInt(flags[3]) and intersize>=flags[3]);
    sup:=sup and (cheap or not flags[1]);
    sub:=sub and (not cheap or flags[1]);
    sup:=sup and (nolattice or not flags[2]);
    sub:=sub and (not nolattice or flags[2]);
    if sup then return attr[i][2];fi; # use stored
    if sub then AddSet(kill,i);fi; # use stored
  od;
  l:=CalcMaximalSubgroupClassReps(G);
  Add(attr,Immutable([[cheap,nolattice,intersize],l]));
  # finally kill superseded ones (by replacing with last, which possibly was
  # just added)
  for i in Reversed(Set(kill)) do
    attr[i]:=attr[Length(attr)];
    Unbind(attr[Length(attr)]);
  od;
  return l;
end);

InstallMethod(StoredPartialMaxSubs,"set",true,[IsGroup],0,x->[]);

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
#A  IndependentGeneratorsOfAbelianGroup( <A> )
##
# to catch some trivial cases.
InstallMethod(IndependentGeneratorsOfAbelianGroup,"finite abelian group",
  true,[IsGroup and IsAbelian],0,
function(G)
local hom,gens;
  if not IsFinite(G) then
    TryNextMethod();
  fi;
  hom:=IsomorphismPermGroup(G);
  gens:=IndependentGeneratorsOfAbelianGroup(Image(hom,G));
  return List(gens,i->PreImagesRepresentative(hom,i));
end);


#############################################################################
##
#O  IndependentGeneratorExponents( <G>, <g> )
##
InstallMethod(IndependentGeneratorExponents,IsCollsElms,
  [IsGroup and IsAbelian, IsMultiplicativeElementWithInverse],0,
function(G,elm)
local ind, pcgs, primes, pos, p, i, e, f, a, j;
  if not IsBound(G!.indgenpcgs) then
    ind:=IndependentGeneratorsOfAbelianGroup(G);
    pcgs:=[];
    primes:=[];
    pos:=[];
    for i in ind do
      Assert(1, IsPrimePowerInt(Order(i)));
      p:=SmallestRootInt(Order(i));
      Add(primes,p);
      Add(pos,Length(pcgs)+1);
      while not IsOne(i) do
        Add(pcgs,i);
        i:=i^p;
      od;
    od;
    Add(pos,Length(pcgs)+1);
    pcgs:=PcgsByPcSequence(FamilyObj(One(G)),pcgs);
    G!.indgenpcgs:=rec(pcgs:=pcgs,primes:=primes,pos:=pos,gens:=ind);
  else
    pcgs:=G!.indgenpcgs.pcgs;
    primes:=G!.indgenpcgs.primes;
    pos:=G!.indgenpcgs.pos;
    ind:=G!.indgenpcgs.gens;
  fi;
  e:=ExponentsOfPcElement(pcgs,elm);
  f:=[];
  for i in [1..Length(ind)] do
    a:=0;
    for j in [pos[i+1]-1,pos[i+1]-2..pos[i]] do
      a:=a*primes[i]+e[j];
    od;
    Add(f,a);
  od;
  return f;
end);

#############################################################################
##
#M  Omega( <G>, <p>[, <n>] )  . . . . . . . . . . .  omega of a <p>-group <G>
##
InstallMethod( Omega,
    [ IsGroup, IsPosInt ],
    function( G, p )
    return Omega( G, p, 1 );
    end );

InstallMethod( Omega,
    [ IsGroup, IsPosInt, IsPosInt ],
    function( G, p, n )
    local known;

    # <G> must be a <p>-group
    if not IsPGroup(G) or PrimePGroup(G)<>p then
      Error( "Omega: <G> must be a p-group" );
    fi;

    known := ComputedOmegas( G );
    if not IsBound( known[ n ] )  then
        known[ n ] := OmegaOp( G, p, n );
    fi;
    return known[ n ];
    end );

InstallMethod( ComputedOmegas, [ IsGroup ], 0, G -> [  ] );


#############################################################################
##
#M  SolvableRadical( <G> )  . . . . . . . . . . . solvable radical of a group
##
InstallMethod( SolvableRadical,
  "factor out Fitting subgroup",
  [IsGroup and IsFinite],
function(G)
  local F,f;
  F := FittingSubgroup(G);
  if IsTrivial(F) then return F; fi;
  f := NaturalHomomorphismByNormalSubgroupNC(G,F);
  return PreImage(f,SolvableRadical(Image(f)));
end);

RedispatchOnCondition( SolvableRadical, true, [IsGroup], [IsFinite], 0);

InstallMethod( SolvableRadical,
    "solvable group is its own solvable radical",
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
##  If no eigenspace is found within one step, the residuum is reached.
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
          pp,          # `p'-part of the size of `df'
          pu,          # Sylow `p' subgroup of `df'
          tmp,         # agemo generators
          ph,          # nat. hom. onto Frattini quotient of `pu'
          ff,          # Frattini factor
          ffsize,      # size of `ff'
          pcgs,        # PCGS of `ff'
          dim,         # dimension of the vector space `ff'
          field,       # prime field in char. `p'
          one,         # identity in `field'
          idm,         # identity matrix
          mg,          # matrices of `G' action on `ff'
          vsl,         # list of simult. eigenspaces
          nextvsl,     # for next iteration
          matrix,      # loop variable
          mat,         #
          eigenvalue,  # loop variable
          nullspace,   # generators of the eigenspace
          space,       # loop variable
          inter,       # intersection
          tmp2,        #
          v;           #

    ds  := [ G ];
    ssr := DerivedSubgroup( G );
    if Size( ssr ) < Size( G ) then
      ds[2]:= ssr;
    fi;

    if not IsTrivial( ssr ) then

      # Find a small generating system `gs' of `G'.
      # (We do *NOT* want to call `SmallGeneratingSet' here since
      # `MinimalGeneratingSet' is installed as a method for pc groups,
      # and for groups such as the Sylow 3 normalizer in F3+,
      # this needs more time than `SupersolvableResiduumDefault'.
      # Also the other method for `SmallGeneratingSet', which takes those
      # generators that cannot be omitted, is too slow.
      # The ``greedy'' type code below need not process all generators,
      # and it will be not too bad for pc groups.)
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

        if Size( ssr ) < Size( oldssr ) then

          dh:= NaturalHomomorphismByNormalSubgroupNC( oldssr, ssr );

          # `df' is the commutator factor group `oldssr / ssr'.
          df:= Range( dh );
          SetIsAbelian( df, true );
          fs:= Factors(Integers, Size( df ) );

          # `gen' collects the generators for the next candidate
          gen := ShallowCopy( GeneratorsOfGroup( df ) );

          for p in Set( fs ) do

            pp:= Product( Filtered( fs, x -> x  = p ) );

            # `pu' is the Sylow `p' subgroup of `df'.
            pu:= SylowSubgroup( df, p );

            # Remove the `p'-part from the generators list `gen'.
            gen:= List( gen, x -> x^pp );

            # Add the agemo_1 of the Sylow subgroup to the generators list.
            tmp:= List( GeneratorsOfGroup( pu ), x -> x^p );
            Append( gen, tmp );
            ph:= NaturalHomomorphismByNormalSubgroupNC( pu,
                                                  SubgroupNC( df, tmp ) );

            # `ff' is the `p'-part of the Frattini factor group of `pu'.
            ff := Range( ph );
            ffsize:= Size( ff );
            if p < ffsize then

              # noncyclic case
              pcgs := Pcgs( ff );
              dim  := Length( pcgs );
              field:= GF(p);
              one  := One( field );
              idm  := IdentityMat( dim, field );

              # `mg' is the list of matrices of the action of `G' on the
              # dual space of the module, w.r.t. `pcgs'.
              mg:= List( gs, x -> TransposedMat( List( pcgs,
                     y -> one * ExponentsOfPcElement( pcgs, Image( ph,
                          Image( dh, PreImagesRepresentative(
                           dh, PreImagesRepresentative(ph,y) )^x ) ) )))^-1);
#T inverting is not necessary, or?
              mg:= Filtered( mg, x -> x <> idm );

              # `vsl' is a list of generators of all the simultaneous
              # eigenspaces.
              vsl:= [ idm ];
              for matrix in mg do

                nextvsl:= [];

                # All eigenvalues of `matrix' will be used.
                # (We expect `p' to be small, so looping over the nonzero
                # elements of the field is much faster than constructing and
                # factoring the characteristic polynomial of `matrix').
                mat:= matrix;
                for eigenvalue in [ 2 .. p ] do
                  mat:= mat - idm;
                  nullspace:= NullspaceMat( mat );
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
                    Add( tmp2, PreImagesRepresentative( ph,
                                   PcElementByExponentsNC( pcgs, v ) ) );

                  od;
                  Add( ds, PreImagesSet( dh,
                            SubgroupNC( df, Concatenation( tmp2, gen ) ) ) );
                od;
                Append( gen, tmp2 );
              fi;

            else

              # cyclic case
              Add( ds, PreImagesSet( dh,
                           SubgroupNC( df, AsSSortedList( gen ) ) ) );

            fi;
          od;

          # Generate the new candidate.
          ssr:= PreImagesSet( dh, SubgroupNC( df, AsSSortedList( gen ) ) );

        fi;

      until IsTrivial( ssr ) or oldssr = ssr;

    fi;

    # Return the result.
    return rec( ssr := SubgroupNC( G, Filtered( GeneratorsOfGroup( ssr ),
                                                i -> Order( i ) > 1 ) ),
                ds  := ds );
    end );


#############################################################################
##
#M  SupersolvableResiduum( <G> )
##
##  Note that this method sets `IsSupersolvableGroup'.
##  Analogously, methods for `IsSupersolvableGroup' should set
##  `SupersolvableResiduum'.
##
InstallMethod( SupersolvableResiduum,
    "method for finite groups (call `SupersolvableResiduumDefault')",
    [ IsGroup and IsFinite ],
    function( G )
    local ssr;
    ssr:= SupersolvableResiduumDefault( G ).ssr;
    SetIsSupersolvableGroup( G, IsTrivial( ssr ) );
    return ssr;
    end );


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
    primes := Set( weights, x -> x[3] );
    comp := List( primes, ReturnFalse );
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
    primes := Set( weights, x -> x[3] );
    comp := List( primes, ReturnFalse );
    for i in [1..Length( primes )] do
        gens := spec{Filtered( [1..Length(spec)],
                           x -> weights[x][3] = primes[i] )};
        sub  := InducedPcgsByPcSequenceNC( spec, gens );
        comp[i] := SubgroupByPcgs( G, sub );
        SetIsPGroup( comp[i], true );
        SetPrimePGroup( comp[i], primes[i] );
        SetSylowSubgroup(G, primes[i], comp[i]);
        SetHallSubgroup(G, [primes[i]], comp[i]);
    od;
    return comp;
end );

#############################################################################
##
#M  HallSystem( <G> ) . . . . . . . . . . . . . . Hall system of finite group
##
InstallMethod( HallSystem,
    "test whether finite group is solvable",
    [ IsGroup and IsFinite ],
function( G )
    local spec, weights, primes, comp, i, gens, pis, sub;

    if not IsSolvableGroup(G) then
        return fail;
    fi;
    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    primes := Set( weights, x -> x[3] );
    pis    := Combinations( primes );
    comp   := List( pis, ReturnFalse );
    for i in [1..Length( pis )] do
        gens := spec{Filtered( [1..Length(spec)],
                           x -> weights[x][3] in pis[i] )};
        sub  := InducedPcgsByPcSequenceNC( spec, gens );
        comp[i] := SubgroupByPcgs( G, sub );
        SetHallSubgroup(G, pis[i], comp[i]);
        if Length(pis[i])=1 then
            SetSylowSubgroup(G, pis[i][1], comp[i]);
        fi;
    od;
    return comp;
end );

#############################################################################
##
#M  Socle( <G> )  . . . . . . . . . . . . . . . . . . . . . for simple groups
##
InstallMethod( Socle, "for simple groups",
              [ IsGroup and IsSimpleGroup ], SUM_FLAGS, IdFunc );

#############################################################################
##
#M  Socle( <G> )  . . . . . . . . . . . . . . . for elementary abelian groups
##
InstallMethod( Socle, "for elementary abelian groups",
              [ IsGroup and IsElementaryAbelian ], SUM_FLAGS, IdFunc );

#############################################################################
##
#M  Socle( <G> ) . . . . . . . . . . . . . . . . . . . . for nilpotent groups
##
InstallMethod( Socle, "for nilpotent groups",
              [ IsGroup and IsNilpotentGroup ],
              {} -> RankFilter( IsGroup and IsFinite and IsNilpotentGroup )
              - RankFilter( IsGroup and IsNilpotentGroup ),
  function(G)
    local P, C, size, gen, abinv, indgen, i, p, q, soc;

    # for finite groups the usual methods are faster
    # for SylowSystem and Omega
    if ( CanComputeSize(G) or HasIsFinite(G) ) and IsFinite(G) then
      soc := TrivialSubgroup(G);
      # now socle is the product of Omega of Sylow subgroups of the center
      for P in SylowSystem(Center(G)) do
        soc := ClosureSubgroupNC(soc, AsSubgroup(G,Omega(P, PrimePGroup(P))));
      od;
    else
      # compute generators for the torsion Omega p-subgroups of the center
      C := Center(G);
      gen := [ ];
      abinv := [ ];
      indgen := [ ];
      size := 1;
      for i in [1..Length(AbelianInvariants(C))] do
        q := AbelianInvariants(C)[i];
        if q<>0 then
          p := SmallestRootInt(q);
          if not IsBound(gen[p]) then
            gen[p] := [ IndependentGeneratorsOfAbelianGroup(C)[i]^(q/p) ];
          else
            Add(gen[p], IndependentGeneratorsOfAbelianGroup(C)[i]^(q/p));
          fi;
          size := size * p;
          Add(abinv, p);
          Add(indgen, IndependentGeneratorsOfAbelianGroup(C)[i]^(q/p));
        fi;
      od;
      # Socle is the product of the torsion Omega p-groups of the center
      soc := Subgroup(G, Concatenation(Compacted(gen)));
      SetSize(soc, size);
      SetAbelianInvariants(soc, abinv);
      SetIndependentGeneratorsOfAbelianGroup(soc, indgen);
    fi;

    # Socle is central in G, set some properties and attributes accordingly
    SetIsAbelian(soc, true);
    if not HasParent(soc) then
      SetParent(soc, G);
      SetCentralizerInParent(soc, G);
      SetIsNormalInParent(soc, true);
    elif CanComputeIsSubset(G, Parent(soc))
         and IsSubgroup(G, Parent(soc)) then
      SetCentralizerInParent(soc, Parent(soc));
      SetIsNormalInParent(soc, true);
    elif CanComputeIsSubset(G, Parent(soc))
         and IsSubgroup(Parent(soc), G) and IsNormal(Parent(soc), G) then
      # characteristic subgroup of a normal subgroup is normal
      SetIsNormalInParent(soc, true);
    fi;

    return soc;
  end);

RedispatchOnCondition(Socle, true, [IsGroup], [IsNilpotentGroup], 0);

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
    if (HasIsFinite(G) and not IsFinite( G ))
      and not (HasIsNilpotentGroup(G) and IsNilpotentGroup( G )) then
      Info( InfoWarning, 1,
            "UpperCentralSeriesOfGroup: may not stop for infinite group <G>");
    fi;

    # compute the series by repeated calling of `Centre'
    S := [ TrivialSubgroup( G ) ];
    Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
    C := Centre( G );
    while C <> Last(S) do
        Add( S, C );
        Info( InfoGroup, 2, "UpperCentralSeriesOfGroup: step ", Length(S) );
        hom := NaturalHomomorphismByNormalSubgroupNC( G, C );
        C := PreImages( hom, Centre( Image( hom ) ) );
    od;

    if Last(S) = G then
        UseIsomorphismRelation( G, Last(S) );
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

    if IsTrivial(G) then
        return G;
    fi;

    # <G> must be a <p>-group
    if not IsPGroup(G) or PrimePGroup(G)<>p then
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

InstallMethod( ComputedAgemos, [ IsGroup ], 0, G -> [  ] );

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
            rg,         # rep*gen
            e,          # loop
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
    if HasOne( G ) and One( G ) * elm = elm and elm * One( G ) = elm  then
        C := GroupWithGenerators( Concatenation( gens, [ elm ] ), One( G ) );
    else
        C := GroupWithGenerators( Concatenation( gens, [ elm ] ) );
    fi;
    UseSubsetRelation( C, G );

    # if the elements of <G> are known then extend this list
    if HasAsSSortedList( G ) then

        # if <G>^<elm> = <G> then <C> = <G> * <elm>
        if ForAll( gens, gen -> gen ^ elm in AsSSortedList( G ) )  then
            Info( InfoGroup, 2, "new generator normalizes" );
            Celements := ShallowCopy( AsSSortedList( G ) );
            rep := elm;
            while not rep in AsSSortedList( G ) do
                #Append( Celements, AsSSortedList( G ) * rep );
                for e in AsSSortedList(G) do
                    # we cannot have duplicates here
                    Add(Celements,e*rep);
                od;
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
            # Celements is sorted already
            #SetAsSSortedList( C, AsSSortedList( Celements ) );
            SetAsSSortedList( C, Celements );
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

InstallMethod( ClosureGroup, "trivial subgroup", IsIdenticalObj,
  [IsGroup and IsTrivial,IsGroup],
function(T,U)
  return U;
end);

#############################################################################
##
#M  ClosureGroup( <G>, <elm> )  . .  for group that contains the whole family
##
InstallMethod( ClosureGroup,
    "method for group that contains the whole family",
    IsCollsElms,
    [ IsGroup and IsWholeFamily, IsMultiplicativeElementWithInverse ],
    SUM_FLAGS, # this is better than everything else
    ReturnFirst);

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
    "for two groups, the bigger containing the whole family",
    IsIdenticalObj,
    [ IsGroup and IsWholeFamily, IsGroup ],
    SUM_FLAGS, # this is better than everything else
    ReturnFirst);

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
    [ IsGroup, IsList and IsEmpty ], ReturnFirst);

#############################################################################
##
#F  ClosureSubgroupNC( <G>, <obj> )
##
InstallGlobalFunction( ClosureSubgroupNC, function(arg)
local G,obj,close;
    G:=arg[1];
    obj:=arg[2];
    if HasIsTrivial(G) and IsTrivial(G) and IsGroup(obj) then
      obj:=AsSubgroup(Parent(G),obj);
    fi;
    if not HasParent( G ) then
      # don't be obnoxious
      Info(InfoWarning,3,"`ClosureSubgroup' called for orphan group" );
      close:=false;
    else
      close:=true;
    fi;
    if Length(arg)=2 then
      obj:= ClosureGroup( G, obj );
    else
      obj:= ClosureGroup( G, obj, arg[3] );
    fi;

    if close and not IsIdenticalObj( Parent( G ), obj ) then
      if ValueOption("noassert")<>true then
        Assert(2,IsSubset(Parent(G),obj));
      fi;
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
      #Error( "<G> must have a parent" );
      P:= G;
    else
      P:= Parent( G );
    fi;

    # Check that we may set the parent of the closure.
    famG:= FamilyObj( G );
    famobj:= FamilyObj( obj );
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
  if not (IsGroup(G) and IsGroup(N) and IsSubgroup(G,N) and IsNormal(G,N)) then
    Error("<N> must be a normal subgroup of <G>");
  fi;
  return FactorGroupNC(G,N);
end);

InstallMethod( FactorGroupNC, "generic method for two groups", IsIdenticalObj,
    [ IsGroup, IsGroup ],
function( G, N )
local hom,F,new;
  hom:=NaturalHomomorphismByNormalSubgroupNC( G, N );
  F:=ImagesSource(hom);
  #TODO: Remove the !.nathom component
  if not IsBound(F!.nathom) then
    F!.nathom:=hom;
  else
    # avoid cached homomorphisms
    new:=Group(GeneratorsOfGroup(F),One(F));
    hom:=hom*GroupHomomorphismByImagesNC(F,new,
      GeneratorsOfGroup(F),GeneratorsOfGroup(F));
    F:=new;
    F!.nathom:=hom;
  fi;
  return F;
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
##  We install the method that returns the quotient of the group orders
##  twice, once as the generic method and once for the situation that the
##  group orders are known;
##  in the latter case, we choose a high enough rank, in order to avoid the
##  unnecessary computation of nice monomorphisms, images of the groups, and
##  orders of these images.
##
InstallMethod( IndexNC,
    "generic method for two groups (the second one being finite)",
    IsIdenticalObj,
    [ IsGroup, IsGroup ],
    function( G, H )
    if IsFinite( H ) then
      return Size( G ) / Size( H );
    fi;
    TryNextMethod();
    end );

InstallMethod( IndexNC,
    "for two groups with known Size value",
    IsIdenticalObj,
    [ IsGroup and HasSize, IsGroup and HasSize and IsFinite ],
    {} -> 2 * RankFilter( IsHandledByNiceMonomorphism ),
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
      and CanComputeIsSubset(Parent(x),g) and IsSubset(Parent(x),g))
  or (HasIsNormalInParent(y) and IsNormalInParent(y)
      and CanComputeIsSubset(Parent(y),g) and IsSubset(Parent(y),g)) then
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
  if not IsAbelian(G) and not HasAutomorphismGroup(G) then #(otherwise there might be to many normal sgrps)
    n:=NormalSubgroups(G);
    n:=Filtered(n,i->Size(i)=Size(H)); # probably do further tests here
    if Length(n)=1 then
      return true; # there is no potential image - we are characteristic
    fi;
  fi;

  a:=AutomorphismGroup(G);
  return ForAll(GeneratorsOfGroup(a),i->Image(i,H)=H);
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
    "for a group with special pcgs: test for normal Hall subgroup",
    [ IsGroup and HasSpecialPcgs, IsPosInt ],
    function( G, p )

    local primes, S;

    primes:= PrimeDivisors( Size( G ) );
    primes:= Filtered(primes, q -> q <> p );
    S:= HallSubgroup( G, primes );

    return S <> fail and IsNormal( G, S );
    end );

InstallMethod( IsPNilpotentOp,
    "check if p divides order of hypocentre",
    [ IsGroup and IsFinite, IsPosInt ],
    function( G, p )

    local ser;

    ser := LowerCentralSeriesOfGroup( G );
    return Size( Last(ser) ) mod p <> 0;
    end );

RedispatchOnCondition (IsPNilpotentOp, ReturnTrue, [IsGroup, IsPosInt], [IsFinite], 0);


#############################################################################
##
#M  IsPSolvable( <G>, <p> )
##
InstallMethod( IsPSolvableOp,
    "generic method: build descending series with abelian or p'-factors",
    [ IsGroup and IsFinite, IsPosInt ],
    function( G, p )

    local N;

    while Size( G ) mod p = 0 do
        N := PerfectResiduum( G );
        N := NormalClosure (N, SylowSubgroup (N, p));
        if IndexNC( G, N ) = 1 then
            return false;
        fi;
        G := N;
    od;
    return true;
    end);

InstallMethod( IsPSolvableOp,
    "for solvable groups: return true",
    [ IsGroup and IsSolvableGroup and IsFinite, IsPosInt ],
    SUM_FLAGS,
    ReturnTrue);

RedispatchOnCondition (IsPSolvableOp, ReturnTrue, [IsGroup, IsPosInt], [IsFinite], 0);


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

InstallMethod( PrintString,
    "for right transversal",
    [ IsList and IsRightTransversalRep ],
function( cs )
    return PRINT_STRINGIFY( "RightTransversal( ", cs!.group, ", ", cs!.subgroup, " )" );
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

InstallMethod( Position, "right transversal: Use PositionCanonical",
  IsCollsElmsX,
    [ IsList and
    IsRightTransversalRep,IsMultiplicativeElementWithInverse,IsInt ],
function(t,e,p)
local a;
  a:=PositionCanonical(t,e);
  if a<p or t[a]<>e then
    return fail;
  else
    return a;
  fi;
end);

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

InstallMethod( NormalClosureOp, "trivial subgroup",
  IsIdenticalObj, [ IsGroup, IsGroup and IsTrivial ], SUM_FLAGS,
function(G,U)
  return U;
end);

InstallOtherMethod( NormalClosure, "generic method for a list of generators",
  IsIdenticalObj, [ IsGroup, IsList ],
function(G, list)
  return NormalClosure(G, Group(list, One(G)));
end);

InstallOtherMethod( NormalClosure, "generic method for an empty list of generators",
  [ IsGroup, IsList and IsEmpty ],
function(G, list)
  return TrivialSubgroup(G);
end);

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
        N := ClosureGroup( C, P );
    until N = S;
    return L;
    end );

InstallOtherMethod( PCentralSeries, "pGroup", [ IsGroup ], function( G )
  if not IsPGroup(G) then
    Error("<G> must be a p-group if no prime is given");
  fi;
  return PCentralSeries(G,PrimePGroup(G));
end);

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
##  <p>-subgroup of <G>.  This is the core of any Sylow <p> subgroup.
##
InstallMethod( PCoreOp,
    "generic method for nilpotent group and prime",
    [ IsGroup and IsNilpotentGroup and IsFinite, IsPosInt ],
    function ( G, p )
    return SylowSubgroup( G, p );
    end );

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
#M  StructuralSeriesOfGroup( <G> )
##
InstallMethod( StructuralSeriesOfGroup, "generic",true,[IsGroup and IsFinite],0,
function(G)
local ser,r,nat,f,Pker,d,i,j,u,loc,p;
  ser:=[];
  r:=SolvableRadical(G);
  ser:=[G];
  if Size(r)<Size(G) then
    nat:=NaturalHomomorphismByNormalSubgroupNC(G,r);
    f:=Image(nat,G);
    Pker:=f;
    d:=DirectFactorsFittingFreeSocle(f);
    for i in d do
      Pker:=Intersection(Pker,Normalizer(f,i));
    od;
    if Size(Pker)<Size(f) then Add(ser,PreImage(nat,Pker)); fi;
    if Size(Socle(f))<Size(Pker) then Add(ser,PreImage(nat,Socle(f)));fi;
    Add(ser,r);
  fi;
  d:=DerivedSeriesOfGroup(r);
  for i in [2..Length(d)] do
    u:=d[i];
    loc:=[u];
    p:=Set(Factors(IndexNC(d[i-1],u)));
    for j in p do
      u:=ClosureGroup(u,SylowSubgroup(d[i-1],j));
      #force elementary
      while not ForAll(GeneratorsOfGroup(u),x->x^j in Last(loc)) do
        r:=NaturalHomomorphismByNormalSubgroupNC(u,Last(loc));
        Pker:=Omega(Range(r),j,1);
        r:=PreImage(r,Pker);
        Add(loc,r);
      od;
      if Size(u)<Size(Last(ser)) then
        Add(loc,u);
      fi;
    od;
    Append(ser,Reversed(loc));
  od;
  return ser;
end);

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
    while C <> Last(S)  do
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
  return U=Last(s);
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
    if Size(S) > 1 then
        SetIsPGroup( S, true );
        SetPrimePGroup( S, p );
    fi;
    return S;
    end );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> ) . . . . . . for a nilpotent group and a prime
##
InstallMethod( SylowSubgroupOp,
    "method for a nilpotent group, and a prime",
    [ IsGroup and IsNilpotentGroup and IsFinite, IsPosInt ],
    function( G, p )
    local gens, g, ord, S;

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

    S := SubgroupNC( G, gens );
    if Size(S) > 1 then
        SetIsPGroup( S, true );
        SetPrimePGroup( S, p );
        SetHallSubgroup(G, [p], S);
        SetPCore(G, p, S);
    fi;
    return S;
    end );


############################################################################
##
#M  HallSubgroupOp (<grp>, <pi>)
##
InstallMethod (HallSubgroupOp, "test trivial cases", true,
    [IsGroup and IsFinite and HasSize, IsList], SUM_FLAGS,
    function (grp, pi)

        local size, p;

        size := Size (grp);
        pi := Filtered (pi, p -> size mod p = 0);
        if IsEmpty (pi) then
            return TrivialSubgroup (grp);
        elif Length (pi) = 1 then
            return SylowSubgroup (grp, pi[1]);
        else
        # try if grp is a pi-group, but avoid factoring size
            for p in pi do
                repeat
                    size := size / p;
                until size mod p <> 0;
            od;
            if size = 1 then
                return grp;
            else
                TryNextMethod();
            fi;
        fi;
    end);


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> ) . . . . . . . . . . . . for a nilpotent group
##
InstallMethod( HallSubgroupOp,
    "method for a nilpotent group",
    [ IsGroup and IsNilpotentGroup and IsFinite, IsList ],
    function( G, pi )
    local p, smallpi, S;

    S := TrivialSubgroup(G);
    smallpi := [];
    for p in pi do
      AddSet(smallpi, p);
      S := ClosureSubgroupNC(S, SylowSubgroup(G, p));
      SetHallSubgroup(G, ShallowCopy(smallpi), S);
    od;
    return S;
    end );


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> ) . . . . . . . . . . . . .  for a finite group
##
InstallMethod( HallSubgroupOp,
    "fallback method for a finite group",
    [ IsGroup and IsFinite, IsList ],
    function( G, pi )
    local iso, H;

    iso := IsomorphismPermGroup( G );
    H := HallSubgroup( ImagesSource( iso ), pi );
    return PreImagesSet(iso, H);
    end );


#############################################################################
##
#M  NormalHallSubgroupsFromSylows( <G> )
##
InstallGlobalFunction( NormalHallSubgroupsFromSylows, function( arg )

  local G, method, primes, edges, i, j, S, N, UpSets, part, U, NHs;

  if Length(arg) = 1 and IsGroup(arg[1]) then
    G := arg[1];
    method := "all";
  elif Length(arg) = 2 and IsGroup(arg[1]) and arg[2] in ["all", "any"] then
    G := arg[1];
    method := arg[2];
  else
    Error("usage: NormalHallSubgroupsFromSylows( <G> [, <mthd> ] )");
  fi;
  if HasNormalHallSubgroups(G) then
    if method = "any" then
      for N in NormalHallSubgroups(G) do
        if not IsTrivial(N) and G<>N then
          return N;
        fi;
      od;
      return fail;
    else
      return NormalHallSubgroups(G);
    fi;
  elif method ="any" and Length(ComputedHallSubgroups(G))>0 then
    i := 0;
    while i < Length(ComputedHallSubgroups(G)) do
      i := i+2;
      N := ComputedHallSubgroups(G)[i];
      if N <> fail and IsNormal(G, N) then
        return N;
      fi;
    od;
  # no need to factor Size(G) if G is a p-group
  elif IsTrivial(G) or IsPGroup(G) then
    SetNormalHallSubgroups(G, Set([ TrivialSubgroup(G), G ]));
    if method = "any" then
      return fail;
    else
      return Set([ TrivialSubgroup(G), G ]);
    fi;
  ## ? might take a long time to check if G is simple ?
  # simple groups have no nontrivial normal subgroups
  elif IsSimpleGroup(G) then
    SetNormalHallSubgroups(G, Set([ TrivialSubgroup(G), G ]));
    if method = "any" then
      return fail;
    else
      return Set([ TrivialSubgroup(G), G ]);
    fi;
  fi;
  primes := PrimeDivisors(Size(G));
  edges := [];
  S := [];
  # create edges of directed graph
  for i in [1..Length(primes)] do
    # S[i] is the normal closure of the Sylow subgroup for primes[i]
    if IsNilpotentGroup(G) then
      S[i] := SylowSubgroup(G, primes[i]);
    else
      S[i] := NormalClosure(G, SylowSubgroup(G, primes[i]));
    fi;
    if IsNilpotentGroup(G) then
      edges[i] := [i];
    else
      edges[i] := [];
      # factoring Size(S[i]) probably takes more time
      for j in [1..Length(primes)] do
        # i -> j is an edge if Size(S[i]) has prime divisor primes[j]
        if Size(S[i]) mod primes[j] = 0 then
          AddSet(edges[i], j);
        fi;
      od;
    fi;
    if method = "any" and edges[i] = [i] then
      return S[i];
    fi;
  od;
  # compute the reachable points from every point of the digraph
  # and then collapse same sets
  # the relation defined by edges is already reflexive
  UpSets := Set(Successors(TransitiveClosureBinaryRelation(
                                            BinaryRelationOnPoints(edges))));
  NHs := [ TrivialSubgroup(G), G ];
  for part in IteratorOfCombinations(UpSets) do
    U := Union(part);
    # trivial subgroup and G should not be added again
    if U <> [] and U <> [1..Length(primes)] then
      N := TrivialSubgroup(G);
      for i in Union(part) do
        N := ClosureGroup(N, S[i]);
      od;
      if method = "any" then
        return N;
      else
        AddSet(NHs, N);
      fi;
    fi;
  od;
  if method = "any" then
    SetNormalHallSubgroups(G, Set([ TrivialSubgroup(G), G ]));
    return fail;
  else
    SetNormalHallSubgroups(G, NHs);
    return NHs;
  fi;
end);

############################################################################
##
#M  NormalHallSubgroups( <G> )
##
InstallMethod( NormalHallSubgroups,
               "by normal closure of Sylow subgroups", true,
               [ IsGroup and CanComputeSizeAnySubgroup and IsFinite ], 0,

function( G )
  return NormalHallSubgroupsFromSylows(G, "all");
end);


############################################################################
##
#M  SylowComplementOp (<grp>, <p>)
##
InstallMethod (SylowComplementOp, "test trivial case", true,
    [IsGroup and IsFinite and HasSize, IsPosInt], SUM_FLAGS,
    function (grp, p)
        local size, q;
        size := Size (grp);
        if size mod p <> 0 then
            return grp;
        else
            repeat
                size := size / p;
            until size mod p <> 0;
            if size = 1 then
                return TrivialSubgroup (grp);
            else
                q := SmallestRootInt (size);
                if IsPrimeInt (q) then
                    return SylowSubgroup (grp, q);
                fi;
            fi;
         fi;
         TryNextMethod();
    end);


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
               or (Size( G ) = Size( H )
                and ((Size(G)>1 and ForAll(GeneratorsOfGroup(G),gen->gen in H))
                  or (Size(G)=1 and One(G) in H)) );
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
    IsCentralFromGenerators( GeneratorsOfGroup,
                             GeneratorsOfGroup ) );

#############################################################################
##
#M  IsCentral( <G>, <g> ) . . . . . . . is an element centralized by a group?
##
InstallMethod( IsCentral,
    "for a group and an element",
    IsCollsElms, [ IsGroup, IsMultiplicativeElementWithInverse ],
    IsCentralElementFromGenerators( GeneratorsOfGroup ) );

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
        return     (not HasSize(G) or not HasSize(H) or Size(G) mod Size(H) = 0)
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
InstallGlobalFunction("GroupEnumeratorByClosure",function( G )

    local   H,          # subgroup of the first generators of <G>
            gen;        # generator of <G>

    # The following code only does not work infinite groups.
    if HasIsFinite( G ) and not IsFinite( G ) then
      TryNextMethod();
    fi;

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
end);

InstallMethod( Enumerator, "generic method for a group",
        [ IsGroup and IsAttributeStoringRep ],
        GroupEnumeratorByClosure );

# the element list is only stored in the locally created new group H
InstallMethod(AsSSortedListNonstored, "generic method for groups",
        [ IsGroup ],
        GroupEnumeratorByClosure );


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
IsomorphismTypeInfoFiniteSimpleGroup_fun:= function( G )
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
    elif IsPosInt( G )  then
        size := G;
        if size = 1 then
          return fail;
        fi;
    else
        Error("<G> must be a group or the size of a group");
    fi;

    # test if <G> is a cyclic group of prime size
    if IsPrimeInt( size )  then
        return rec(series:="Z",parameter:=size,
                   name:=Concatenation( "Z(", String(size), ")" ),
                   shortname:= Concatenation( "C", String( size ) ));
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
                            "~ 2A(1,5) = U(2,5)" ),
                   shortname:= "A5");
    fi;

    # test if <G> is A(6) ~ A(1,9)
    if size = 360  then
        return rec(series:="A",parameter:=6,
                   name:=Concatenation( "A(6) ",
                            "~ A(1,9) = L(2,9) ",
                            "~ B(1,9) = O(3,9) ",
                            "~ C(1,9) = S(2,9) ",
                            "~ 2A(1,9) = U(2,9)" ),
                   shortname:= "A6");
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
                                "~ D(3,2) = O+(6,2)" ),
                       shortname:= "A8");
        else
            return rec(series:="L",parameter:=[3,4],
                       name:="A(2,4) = L(3,4)",
                       shortname:= "L3(4)");
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
                   name:=Concatenation( "A(", String(n), ")" ),
                   shortname:= Concatenation( "A", String( n ) ));
    fi;

    # test if <G> is one of the sporadic simple groups
    if size = 2^4 * 3^2 * 5 * 11  then
        return rec(series:="Spor",name:="M(11)",
                   shortname:= "M11");
    elif size = 2^6 * 3^3 * 5 * 11  then
        return rec(series:="Spor",name:="M(12)",
                   shortname:= "M12");
    elif size = 2^3 * 3 * 5 * 7 * 11 * 19  then
        return rec(series:="Spor",name:="J(1)",
                   shortname:= "J1");
    elif size = 2^7 * 3^2 * 5 * 7 * 11  then
        return rec(series:="Spor",name:="M(22)",
                   shortname:= "M22");
    elif size = 2^7 * 3^3 * 5^2 * 7  then
        return rec(series:="Spor",name:="HJ = J(2) = F(5-)",
                   shortname:= "J2");
    elif size = 2^7 * 3^2 * 5 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="M(23)",
                   shortname:= "M23");
    elif size = 2^9 * 3^2 * 5^3 * 7 * 11  then
        return rec(series:="Spor",name:="HS",
                   shortname:= "HS");
    elif size = 2^7 * 3^5 * 5 * 17 * 19  then
        return rec(series:="Spor",name:="J(3)",
                   shortname:= "J3");
    elif size = 2^10 * 3^3 * 5 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="M(24)",
                   shortname:= "M24");
    elif size = 2^7 * 3^6 * 5^3 * 7 * 11  then
        return rec(series:="Spor",name:="Mc",
                   shortname:= "McL");
    elif size = 2^10 * 3^3 * 5^2 * 7^3 * 17  then
        return rec(series:="Spor",name:="He = F(7)",
                   shortname:= "He");
    elif size = 2^14 * 3^3 * 5^3 * 7 * 13 * 29  then
        return rec(series:="Spor",name:="Ru",
                   shortname:= "Ru");
    elif size = 2^13 * 3^7 * 5^2 * 7 * 11 * 13  then
        return rec(series:="Spor",name:="Suz",
                   shortname:= "Suz");
    elif size = 2^9 * 3^4 * 5 * 7^3 * 11 * 19 * 31  then
        return rec(series:="Spor",name:="ON",
                   shortname:= "ON");
    elif size = 2^10 * 3^7 * 5^3 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="Co(3)",
                   shortname:= "Co3");
    elif size = 2^18 * 3^6 * 5^3 * 7 * 11 * 23  then
        return rec(series:="Spor",name:="Co(2)",
                   shortname:= "Co2");
    elif size = 2^17 * 3^9 * 5^2 * 7 * 11 * 13  then
        return rec(series:="Spor",name:="Fi(22)",
                   shortname:= "Fi22");
    elif size = 2^14 * 3^6 * 5^6 * 7 * 11 * 19  then
        return rec(series:="Spor",name:="HN = F(5) = F = F(5+)",
                   shortname:= "HN");
    elif size = 2^8 * 3^7 * 5^6 * 7 * 11 * 31 * 37 * 67  then
        return rec(series:="Spor",name:="Ly",
                   shortname:= "Ly");
    elif size = 2^15 * 3^10 * 5^3 * 7^2 * 13 * 19 * 31  then
        return rec(series:="Spor",name:="Th = F(3) = E = F(3/3)",
                   shortname:= "Th");
    elif size = 2^18 * 3^13 * 5^2 * 7 * 11 * 13 * 17 * 23  then
        return rec(series:="Spor",name:="Fi(23)",
                   shortname:= "Fi23");
    elif size = 2^21 * 3^9 * 5^4 * 7^2 * 11 * 13 * 23  then
        return rec(series:="Spor",name:="Co(1) = F(2-)",
                   shortname:= "Co1");
    elif size = 2^21 * 3^3 * 5 * 7 * 11^3 * 23 * 29 * 31 * 37 * 43  then
        return rec(series:="Spor",name:="J(4)",
                   shortname:= "J4");
    elif size = 2^21 * 3^16 * 5^2 * 7^3 * 11 * 13 * 17 * 23 * 29  then
        return rec(series:="Spor",name:="Fi(24) = F(3+)",
                   shortname:= "F3+");
    elif size = 2^41*3^13*5^6*7^2*11*13*17*19*23*31*47  then
        return rec(series:="Spor",name:="B = F(2+)",
                   shortname:= "B");
    elif size = 2^46*3^20*5^9*7^6*11^2*13^3*17*19*23*29*31*41*47*59*71  then
        return rec(series:="Spor",name:="M = F(1)",
                   shortname:= "M");
    fi;

    # from now on we deal with groups of Lie-type

    # calculate the dominant prime of size
    q := Maximum( List( Collected( Factors(Integers, size ) ), s -> s[1]^s[2] ) );
    p := Factors(Integers, q )[1];

    # test if <G> is the Chevalley group A(1,7) ~ A(2,2)
    if size = 168  then
        return rec(series:="L",parameter:=[2,7],
                   name:=Concatenation( "A(1,7) = L(2,7) ",
                            "~ B(1,7) = O(3,7) ",
                            "~ C(1,7) = S(2,7) ",
                            "~ 2A(1,7) = U(2,7) ",
                            "~ A(2,2) = L(3,2)" ),
                   shortname:= "L3(2)");
    fi;

    # test if <G> is the Chevalley group A(1,8), where p = 3 <> char.
    if size = 504  then
        return rec(series:="L",parameter:=[2,8],
                   name:=Concatenation( "A(1,8) = L(2,8) ",
                            "~ B(1,8) = O(3,8) ",
                            "~ C(1,8) = S(2,8) ",
                            "~ 2A(1,8) = U(2,8)" ),
                   shortname:= "L2(8)");
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>-1), where p = 2 <> char.
    if    size>59 and p = 2  and IsPrime(q-1)
      and size = (q-1) * ((q-1)^2-1) / Gcd(2,(q-1)-1)
    then
        return rec(series:="L",parameter:=[2,q-1],
                   name:=Concatenation( "A(1,", String(q-1), ") ",
                            "= L(2,",  String(q-1), ") ",
                            "~ B(1,",  String(q-1), ") ",
                            "= O(3,",  String(q-1), ") ",
                            "~ C(1,",  String(q-1), ") ",
                            "= S(2,",  String(q-1), ") ",
                            "~ 2A(1,", String(q-1), ") ",
                            "= U(2,",  String(q-1), ")" ),
                   shortname:= Concatenation( "L2(", String( q-1 ), ")" ));
    fi;

    # test if <G> is a Chevalley group A(1,2^<k>), where p = 2^<k>+1 <> char.
    if    size>59 and p <> 2  and IsPrimePowerInt( p-1 )
      and size = (p-1) * ((p-1)^2-1) / Gcd(2,(p-1)-1)
    then
        return rec(series:="L",parameter:=[2,p-1],
                   name:=Concatenation( "A(1,", String(p-1), ") ",
                            "= L(2,",  String(p-1), ") ",
                            "~ B(1,",  String(p-1), ") ",
                            "= O(3,",  String(p-1), ") ",
                            "~ C(1,",  String(p-1), ") ",
                            "= S(2,",  String(p-1), ") ",
                            "~ 2A(1,", String(p-1), ") ",
                            "= U(2,",  String(p-1), ")" ),
                   shortname:= Concatenation( "L2(", String( p-1 ), ")" ));
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
                   name:=Concatenation( "A(1,", String(q), ") ",
                            "= L(2,",  String(q), ") ",
                            "~ B(1,",  String(q), ") ",
                            "= O(3,",  String(q), ") ",
                            "~ C(1,",  String(q), ") ",
                            "= S(2,",  String(q), ") ",
                            "~ 2A(1,", String(q), ") ",
                            "= U(2,",  String(q), ")" ),
                   shortname:= Concatenation( "L2(", String( q ), ")" ));
    fi;

    # test if <G> is a Chevalley group A(3,q) ~ D(3,q)
    # exceptions: A(3,2) ~ A(8)
    if n = 3  and size = size2  then
        return rec(series:="L",parameter:=[4,q],
                   name:=Concatenation( "A(3,", String(q), ") ",
                            "= L(4,",  String(q), ") ",
                            "~ D(3,",  String(q), ") ",
                            "= O+(6,", String(q), ") " ),
                   shortname:= Concatenation( "L4(", String( q ), ")" ));
    fi;

    # test if <G> is a Chevalley group A(n,q)
    if size = size2  then
        return rec(series:="L",parameter:=[n+1,q],
                   name:=Concatenation( "A(", String(n),   ",", String(q), ") ",
                            "= L(", String(n+1), ",", String(q), ") " ),
                   shortname:= Concatenation( "L", String( n+1 ), "(", String( q ), ")" ));
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
                            "~ 2D(3,2) = O-(6,2)" ),
                   shortname:= "U4(2)");
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
                            "= S(4,", String(q), ")" ),
                   shortname:= Concatenation( "S4(", String( q ), ")" ));
    fi;

    # test if <G> is a Chevalley group B(n,2^m) ~ C(n,2^m)
    # non-simple: B(2,2) ~ S(6)
    if p = 2  and size = size2  then
        return rec(series:="B",parameter:=[n,q],
                   name:=Concatenation("B(",String(n),  ",", String(q), ") ",
                            "= O(", String(2*n+1), ",", String(q), ") ",
                            "~ C(", String(n),     ",", String(q), ") ",
                            "= S(", String(2*n),   ",", String(q), ")" ),
                   shortname:= Concatenation( "S", String( 2*n ), "(", String( q ), ")" ));
    fi;

    # test if <G> is a Chevalley group B(n,q) or C(n,q), 2 < n and q odd
    if p <> 2  and size = size2  then

        # check that <G> is a group
        if not IsGroup( G )  then
            return rec(parameter:= [ n, q ],
                       name:=Concatenation( "cannot decide from size alone between ",
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
                                "= O(", String(2*n+1), ",", String(q), ")"),
                       shortname:= Concatenation( "O", String( 2*n+1 ), "(", String( q ), ")" ));
        else
            return rec(series:="C",parameter:=[n,q],
                       name:=Concatenation( "C(",String(n),",",String(q),") ",
                                "= S(", String(2*n), ",", String(q), ")" ),
                       shortname:= Concatenation( "S", String( 2*n ), "(", String( q ), ")" ));
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
                            "= O+(", String(2*n), ",", String(q), ")" ),
                   shortname:= Concatenation( "O", String( 2*n ), "+(", String( q ), ")" ));
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
                   name:=Concatenation( "E(6,", String(q), ")" ),
                   shortname:= Concatenation( "E6(", String( q ), ")" ));
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
                   name:=Concatenation( "E(7,", String(q), ")" ),
                   shortname:= Concatenation( "E7(", String( q ), ")" ));
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
                   name:=Concatenation( "E(8,", String(q), ")" ),
                   shortname:= Concatenation( "E8(", String( q ), ")" ));
    fi;

    # test whether <G> is an exceptional Chevalley group F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^24 * (q^12-1)*(q^8-1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="F",parameter:=q,
                   name:=Concatenation( "F(4,", String(q), ")" ),
                   shortname:= Concatenation( "F4(", String( q ), ")" ));
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
                   name:=Concatenation( "G(2,", String(q), ")" ),
                   shortname:= Concatenation( "G2(", String( q ), ")" ));
    fi;

    # test if <G> is 2A(2,3), where p = 2 <> char.
    if size = 3^3*(3^2-1)*(3^3+1)  then
        return rec(series:="2A",parameter:=[2,3],
                   name:="2A(2,3) = U(3,3)",
                   shortname:= "U3(3)");
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
                   name:=Concatenation( "2A(3,", String(q), ") ",
                            "= U(4,",  String(q), ") ",
                            "~ 2D(3,", String(q), ") ",
                            "= O-(6,", String(q), ")" ),
                   shortname:= Concatenation( "U4(", String( q ), ")" ));
    fi;

    # test if <G> is a Steinberg group 2A(n,q)
    # non-simple: 2A(2,2) ~ 3^2 . Q(8)
    if size = size2  then
        return rec(series:="2A",parameter:=[n,q],
                   name:=Concatenation("2A(",String(n),",", String(q), ") ",
                            "= U(",  String(n+1), ",", String(q), ")" ),
                   shortname:= Concatenation( "U", String( n+1 ), "(", String( q ), ")" ));
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
                   name:=Concatenation( "2B(2,", String(q), ") ",
                            "= 2C(2,", String(q), ") ",
                            "= Sz(",   String(q), ")" ),
                   shortname:= Concatenation( "Sz(", String( q ), ")" ));
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
                            "= O-(", String(2*n), ",", String(q), ")" ),
                   shortname:= Concatenation( "O", String( 2*n ), "-(", String( q ), ")" ));
    fi;

    # test whether <G> is a Steinberg group 3D4(q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^8+q^4+1)*(q^6-1)*(q^2-1);
    until size <= size2;
    if size = size2  then
        return rec(series:="3D",parameter:=q,
                   name:=Concatenation( "3D(4,", String(q), ")" ),
                   shortname:= Concatenation( "3D4(", String( q ), ")" ));
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
                   name:=Concatenation( "2E(6,", String(q), ")" ),
                   shortname:= Concatenation( "2E6(", String( q ), ")" ));
    fi;

    # test if <G> is the Ree group 2F(4,q)'
    if size = 2^12 * (2^6+1)*(2^4-1)*(2^3+1)*(2-1) / 2  then
        return rec(series:="2F",parameter:=2,
                   name:="2F(4,2)' = Ree(2)' = Tits",
                   shortname:= "2F4(2)'");
    fi;

    # test whether <G> is a Ree group 2F(4,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^12 * (q^6+1)*(q^4-1)*(q^3+1)*(q-1);
    until size <= size2;
    if p = 2  and 1 < m  and m mod 2 = 1  and size = size2  then
        return rec(series:="2F",parameter:=q,
                   name:=Concatenation( "2F(4,", String(q), ") ",
                            "= Ree(",            String(q), ")" ),
                   shortname:= Concatenation( "2F4(", String( q ), ")" ));
    fi;

    # test whether <G> is a Ree group 2G(2,q)
    m := 0;  q := 1;
    repeat
        m := m + 1;  q := q * p;
        size2 := q^3 * (q^3+1)*(q-1);
    until size <= size2;
    if p = 3  and 1 < m  and m mod 2 = 1  and size = size2  then
        return rec(series:="2G",parameter:=q,
                   name:=Concatenation( "2G(2,", String(q), ") ",
                            "= Ree(",            String(q), ")" ),
                   shortname:= Concatenation( "R(", String( q ), ")" ));
    fi;

    # or a new simple group is found
    if IsGroup( G ) then
      Error( "A new simple group, whoaw" );
    else
      return fail;
    fi;
end;

InstallMethod( IsomorphismTypeInfoFiniteSimpleGroup,
    [ IsGroup ], IsomorphismTypeInfoFiniteSimpleGroup_fun );

InstallMethod( IsomorphismTypeInfoFiniteSimpleGroup,
    [ IsPosInt ], IsomorphismTypeInfoFiniteSimpleGroup_fun );

Unbind( IsomorphismTypeInfoFiniteSimpleGroup_fun );


#############################################################################
##
#F  SmallSimpleGroup( <order>, <i> )
#F  SmallSimpleGroup( <order> )
##
InstallGlobalFunction( SmallSimpleGroup,

  function ( arg )

    local  order, i, grps,j;

    if   not Length(arg) in [1,2] or not ForAll(arg,IsPosInt)
    then Error("usage: SmallSimpleGroup( <order> [, <i> ] )"); fi;

    order := arg[1];
    if Length(arg) = 2 then i := arg[2]; else i := 1; fi;

    if IsPrime(order) then
      if i = 1 then return CyclicGroup(order); else return fail; fi;
    fi;

    if order < 60 then return fail; fi;

    if   order > SIMPLE_GROUPS_ITERATOR_RANGE then
      Error("simple groups of order > ",SIMPLE_GROUPS_ITERATOR_RANGE,
                " are currently\n",
               "not available via this function.");
    fi;

    order:=SimpleGroupsIterator(order,order);
    for j in [1..i-1] do NextIterator(order);od;
    return NextIterator(order);

  end );


#############################################################################
##
#F  AllSmallNonabelianSimpleGroups( <orders> )
##
InstallGlobalFunction( AllSmallNonabelianSimpleGroups,

  function ( orders )

    local  grps,it,a,min,max;

    if   not IsList(orders) or not ForAll(orders,IsPosInt)
    then Error("usage: AllSmallNonabelianSimpleGroups( <orders> )"); fi;

    min:=Minimum(orders);
    max:=Maximum(orders);
    if max> SIMPLE_GROUPS_ITERATOR_RANGE then
      Error("simple groups of order > ",SIMPLE_GROUPS_ITERATOR_RANGE,
        " are currently\n",
        "not available via this function.");
    fi;
    it:=SimpleGroupsIterator(min,max);
    grps:=[];
    for a in it do
      if Size(a) in orders then
        Add(grps,a);
      fi;
    od;

    return grps;
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

InstallMethod( String,
    "for a group",
    [ IsGroup ],
    function( G )
    return "Group( ... )";
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

InstallMethod( String,
    "for a group with generators",
    [ IsGroup and HasGeneratorsOfGroup ],
    function( G )
    if IsEmpty( GeneratorsOfGroup( G ) ) then
      return STRINGIFY( "Group( ", One( G ), " )" );
    else
      return STRINGIFY( "Group( ", GeneratorsOfGroup( G ), " )" );
    fi;
    end );

InstallMethod( PrintString,
    "for a group with generators",
    [ IsGroup and HasGeneratorsOfGroup ],
    function( G )
    if IsEmpty( GeneratorsOfGroup( G ) ) then
      return PRINT_STRINGIFY( "Group( ", One( G ), " )" );
    else
      return PRINT_STRINGIFY( "Group( ", GeneratorsOfGroup( G ), " )" );
    fi;
    end );

#############################################################################
##
#M  ViewObj( <M> )  . . . . . . . . . . . . . . . . . . . . . .  view a group
##
InstallMethod( ViewString,
    "for a group",
    [ IsGroup ],
    function( G )
    return "<group>";
end );

InstallMethod( ViewString,
    "for a group with generators",
    [ IsGroup and HasGeneratorsOfMagmaWithInverses ],
    function( G )
    local nrgens;
    nrgens := Length( GeneratorsOfMagmaWithInverses( G ) );
    if nrgens = 0 then
        return "<trivial group>";
    fi;
    return Concatenation("<group with ", Pluralize( nrgens, "generator" ), ">");
    end );

InstallMethod( ViewString,
    "for a group with generators and size",
    [ IsGroup and HasGeneratorsOfMagmaWithInverses and HasSize],
    function( G )
    local nrgens;
    nrgens := Length(GeneratorsOfMagmaWithInverses( G ) );
    if nrgens = 0 then
        return "<trivial group>";
    fi;
    return Concatenation("<group of size ", String(Size(G))," with ",
                         Pluralize(nrgens, "generator"), ">");
    end );

InstallMethod( ViewObj, "for a group",
    [ IsGroup ],
        function(G)
    Print(ViewString(G));
end);

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

#F  MakeGroupyType( <fam>, <filt>, <gens>, <id>, <isgroup> )
# type creator function to incorporate basic deductions so immediate methods
# are not needed. Parameters are family, filter to start with, generator
# list, is it indeed a group (or only magma)?
InstallGlobalFunction(MakeGroupyType,
function(fam,filt,gens,id,isgroup)

  filt:=filt and HasIsEmpty;  # having HasIsEmpty but not IsEmpty indicates "non-empty"
  if IsFinite(gens) then
    if isgroup then
      filt:=filt and IsFinitelyGeneratedGroup;
    fi;

    if Length(gens)>0 and CanEasilyCompareElements(gens) then
      if id=false then
        id:=One(gens[1]);
      fi;
      if id<>fail then # cannot do identity in magma
        if ForAny(gens,x->x<>id) then
          filt:=filt and IsNonTrivial;
          if isgroup and Length(gens)<=1 then # cyclic not for magmas
            filt:=filt and IsCyclic;
          fi;
        else
          filt:=filt and IsTrivial;
        fi;
      fi;
    elif isgroup and Length(gens)<=1 then # cyclic not for magmas
      if Length(gens) = 0 then
        filt:=filt and IsTrivial;
      else
        filt:=filt and IsCyclic;
      fi;
    fi;
  fi;
  return NewType(fam,filt);
end);

InstallGlobalFunction(MakeGroupyObj,
function(fam,filt,gens,id,attr...)
  local isgroup, typ;
  Assert(0, IsList(attr));
  Assert(0, IsEvenInt(Length(attr)));

  # set generators
  Append(attr, [ GeneratorsOfMagmaWithInverses, gens ]);

  # set one, if given
  if not IsBool(id) then
    Append(attr, [ One, id ]);
  fi;

  # make the type
  filt := IsAttributeStoringRep and filt;
  isgroup := IS_IMPLIED_BY(IsGroup, filt);
  typ := MakeGroupyType(fam,filt,gens,id,isgroup);

  if isgroup and IS_IMPLIED_BY(IsTrivial, typ) then
    Append(attr, [ Size, 1 ]);
  fi;

  return CallFuncList(ObjectifyWithAttributes, Concatenation([rec(), typ], attr));

end);

#############################################################################
##
#M  GroupWithGenerators( <gens> ) . . . . . . . . group with given generators
#M  GroupWithGenerators( <gens>, <id> ) . . . . . group with given generators
##
InstallMethod( GroupWithGenerators,
    "generic method for collection",
    [ IsCollection ],
function( gens )

  if IsGroup(gens) then
    Info( InfoPerformance, 1,
      "Calling `GroupWithGenerators' on a group usually is very inefficient.");
    Info( InfoPerformance, 1,
      "Use the list of generators of the group instead.");
  fi;

  gens:=AsList(gens);
  return MakeGroupyObj(FamilyObj(gens), IsGroup, gens, false);
end );

InstallMethod( GroupWithGenerators,
    "generic method for collection and identity element",
    IsCollsElms, [ IsCollection, IsMultiplicativeElementWithInverse ],
function( gens, id )

  if IsGroup(gens) then
    Info( InfoPerformance, 1,
      "Calling `GroupWithGenerators' on a group usually is very inefficient.");
    Info( InfoPerformance, 1,
      "Use the list of generators of the group instead.");
  fi;

  gens:=AsList(gens);
  return MakeGroupyObj(FamilyObj(gens), IsGroup, gens, id);
end );

InstallMethod( GroupWithGenerators,"method for empty list and element",
  [ IsList and IsEmpty, IsMultiplicativeElementWithInverse ],
  function( empty, id )
local fam;

  fam:= CollectionsFamily( FamilyObj( id ) );

  return MakeGroupyObj(fam, IsGroup, empty, id);
end );


InstallMethod( GroupWithGenerators,
    "generic method for cyclotomic collection",
    [ IsCyclotomicCollection ],
function( gens )
  Error("no groups of cyclotomics allowed because of incompatible ^");
end );

InstallMethod( GroupWithGenerators,
    "generic method for cyclotomic collection and identity element",
    IsCollsElms, [ IsCollection, IsCyclotomic ],
function( gens, id )
  Error("no groups of cyclotomics allowed because of incompatible ^");
end );

InstallMethod( GroupWithGenerators,"method for empty list and cyclotomic element",
  [ IsList and IsEmpty, IsCyclotomic ],
function( empty, id )
  Error("no groups of cyclotomics allowed because of incompatible ^");
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
    #  special case for matrices, because they may look like lists
    if Length( arg ) = 1 and IsMatrix( arg[1] )
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
                           and IsGeneratorsOfMagmaWithInverses( arg[1] )
                           and IsOne( arg[2] ) then
      return GroupByGenerators( arg[1], arg[2] );

    elif 0 < Length( arg ) and IsGeneratorsOfMagmaWithInverses( arg ) then
      return GroupByGenerators( arg );
    fi;

    # no argument given, error
    Error("usage: Group(<gen>,...), Group(<gens>), Group(<gens>,<id>)");
end );

#############################################################################
##
#M  \in( <g>, <G> ) . for groups, checking for <g> being among the generators
##
InstallMethod(\in,
              "default method, checking for <g> being among the generators",
              ReturnTrue,
              [ IsMultiplicativeElementWithInverse,
                IsGroup and HasGeneratorsOfGroup ], 0,

  function ( g, G )
    if   g = One(G)
      or (IsFinite(GeneratorsOfGroup(G)) and g in GeneratorsOfGroup(G))
    then return true;
    else TryNextMethod(); fi;
  end );

#############################################################################
##
#F  SubgroupByProperty ( <G>, <prop> )
##
InstallGlobalFunction( SubgroupByProperty, function( G, prop )
local K, S;

  K:= NewType( FamilyObj(G), IsMagmaWithInverses
                  and IsAttributeStoringRep
                  and HasElementTestFunction);
  S:=rec();
  ObjectifyWithAttributes(S, K, ElementTestFunction, prop );
  SetParent( S, G );
  return S;
end );

InstallMethod( PrintObj, "subgroup by property",
    [ IsGroup and HasElementTestFunction ],100,
function( G )
  Print( "SubgroupByProperty( ", Parent( G ), ",",
          ElementTestFunction(G)," )" );
end );

InstallMethod( ViewObj, "subgroup by property",
    [ IsGroup and HasElementTestFunction ],100,
function( G )
  Print( "<subgrp of ");
  View(Parent(G));
  Print(" by property>");
end );

InstallMethod( \in, "subgroup by property",
    [ IsObject, IsGroup and HasElementTestFunction ],100,
function( e,G )
  return e in Parent(G) and ElementTestFunction(G)(e);
end );

InstallMethod(GeneratorsOfGroup, "Schreier generators",
    [ IsGroup and HasElementTestFunction ],0,
function(G )
  return GeneratorsOfGroup(Stabilizer(Parent(G),RightCoset(G,One(G)),OnRight));
end );

#############################################################################
##
#F  SubgroupShell ( <G> )
##
InstallGlobalFunction( SubgroupShell, function( G )
local K, S;

  K:= NewType( FamilyObj(G), IsMagmaWithInverses
                  and IsAttributeStoringRep);
  S:=rec();
  Objectify(K,S);
  SetParent( S, G );
  return S;
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
    f := Factors(Integers, o );
    if Length( Set( f ) ) = 1  then
        return [ g ];
    else
        p := f[1];
        x := Number( f, y -> y = p );
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

    f := Factors(Integers, o );
    x := Number( f, x -> x = p );
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
InstallMethod(\.,"group generators",true,
  [IsGroup and HasGeneratorsOfGroup,IsPosInt],
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
    SortBy(nrm, Size);

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
##  *Note* that for abelian and solvable groups the maximal normal subgroups
##  can be computed very quickly. Thus if you suspect your group to be
##  abelian or solvable, then check it before computing the maximal normal
##  subgroups.
##
InstallMethod( MaximalNormalSubgroups,
    "generic search",
    [ IsGroup and IsFinite ],
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

RedispatchOnCondition( MaximalNormalSubgroups, true,
    [ IsGroup ],
    [ IsFinite ], 0);

#############################################################################
##
#M  MaximalNormalSubgroups( <G> )
##
InstallMethod( MaximalNormalSubgroups, "for simple groups",
              [ IsGroup and IsSimpleGroup ], SUM_FLAGS,
              function(G) return [ TrivialSubgroup(G) ]; end);


#############################################################################
##
#M  MaximalNormalSubgroups( <G> )
##
InstallMethod( MaximalNormalSubgroups, "general method selection",
              [ IsGroup ],
    function(G)

    if 0 in AbelianInvariants(G) then
      # (p) is a maximal normal subgroup in Z for every prime p
      Error("number of maximal normal subgroups is infinity");
    else
      TryNextMethod();
    fi;
end);


##############################################################################
##
#F  MinimalNormalSubgroups(<G>)
##
InstallMethod( MinimalNormalSubgroups,
    "generic search in NormalSubgroups",
    [ IsGroup and IsFinite],
    function (G)

    local grps, sizes, n, min, i, j, k, size;

    # force an IsNilpotent check
    # should have and IsSolvable check, as well,
    # but methods for solvable groups are only in CRISP
    # which aggeressively checks for solvability, anyway
    if (not HasIsNilpotentGroup(G) and IsNilpotentGroup(G)) then
      return MinimalNormalSubgroups( G );
    fi;

    grps := ShallowCopy (NormalSubgroups (G));
    sizes := List (grps, Size);
    n := Length (grps);
    if n = 0 then
      return [];
    fi;
    SortParallel (sizes, grps);

    # if a group is not minimal, we set the corresponding size to 1,

    min := [];

    for i in [1..n] do
      if sizes[i] > 1 then
        G := grps[i];
        Add (min, G);
        size := sizes[i];
        j := i + 1;
        while j <= n and sizes[j] <= size do
          j := j + 1;
        od;
        for k in [j..n] do
          if sizes[k] mod size = 0 and IsSubgroup (grps[k], G) then
            sizes[k] := 1; # mark grps[k] as deleted
          fi;
        od;
      fi;
    od;
    return min;
  end);


RedispatchOnCondition(MinimalNormalSubgroups, true,
    [IsGroup],
    [IsFinite], 0);


#############################################################################
##
#M  MinimalNormalSubgroups (<G>)
##
InstallMethod (MinimalNormalSubgroups,
   "handled by nice monomorphism",
   true,
   [IsGroup and IsHandledByNiceMonomorphism and IsFinite],
   0,
   function( grp )
      local hom;
      hom := NiceMonomorphism (grp);
      return List (MinimalNormalSubgroups (NiceObject (grp)),
        N -> PreImagesSet (hom, N));
   end);


#############################################################################
##
#M  MinimalNormalSubgroups( <G> )
##
InstallMethod( MinimalNormalSubgroups, "for simple groups",
              [ IsGroup and IsSimpleGroup ], SUM_FLAGS,
              function(G) return [ G ]; end);


#############################################################################
##
#M  MinimalNormalSubgroups (<G>)
##
InstallMethod( MinimalNormalSubgroups, "for nilpotent groups",
              [ IsGroup and IsNilpotentGroup ],
  # IsGroup and IsFinite ranks higher than IsGroup and IsNilpotentGroup
  # so we have to increase the rank, otherwise the method for computation
  # by NormalSubgroups above is selected.
  {} -> RankFilter( IsGroup and IsFinite and IsNilpotentGroup )
  - RankFilter( IsGroup and IsNilpotentGroup ),
  function(G)
    local soc, i, p, primes, gen, min, MinimalSubgroupsOfPGroupByGenerators;

    MinimalSubgroupsOfPGroupByGenerators := function(G, p, gen)
    # G is the big group
    # p is the prime p
    # gens is the generators by which the p-group is given
      local min, tuples, g, h, k, i;

      min := [ ];
      if Length(gen[p])=1 then
        Add(min, Subgroup(G, gen[p]));
      else
        g := Remove(gen[p]);
        for tuples in IteratorOfTuples([0..p-1], Length(gen[p])) do
          h := g;
          for i in [1..Length(tuples)] do
            h := h*gen[p][i]^tuples[i];
          od;
          Add(min, Subgroup(G, [h]));
        od;
        Append(min, MinimalSubgroupsOfPGroupByGenerators(G, p, gen));
      fi;

      return min;
    end;

    soc := Socle(G);
    primes := [ ];
    gen := [ ];
    min := [ ];
    for i in [1..Length(AbelianInvariants(soc))] do
      p := AbelianInvariants(soc)[i];
      AddSet(primes, p);
      if not IsBound(gen[p]) then
        gen[p] := [ IndependentGeneratorsOfAbelianGroup(soc)[i] ];
      else
        Add(gen[p], IndependentGeneratorsOfAbelianGroup(soc)[i]);
      fi;
    od;

    for p in primes do
      Append(min, MinimalSubgroupsOfPGroupByGenerators(G, p, gen));
    od;
    return min;
  end);

RedispatchOnCondition(MinimalNormalSubgroups, true,
    [IsGroup],
    [IsNilpotentGroup], 0);

#############################################################################
##
#M  SmallGeneratingSet(<G>)
##
BindGlobal("SMALLGENERATINGSETGENERIC",function (G)
local  i, U, gens,test;
  gens := Set(GeneratorsOfGroup(G));
  i := 1;
  while i < Length(gens)  do
    U:= SubgroupNC( G, gens{ Difference( [ 1 .. Length( gens ) ], [ i ] ) } );
    if HasIsFinite(G) and IsFinite(G) and CanComputeSizeAnySubgroup(G) then
      test:=Size(U)=Size(G);
    else
      test:=IsSubset(U,G);
    fi;
    if test then
      gens:=GeneratorsOfGroup(U);
      # this throws out i, so i is the new i+1;
    else
      i:=i+1;
    fi;
  od;
  return gens;
end);

InstallMethod(SmallGeneratingSet,"generators subset",
  [IsGroup and HasGeneratorsOfGroup],SMALLGENERATINGSETGENERIC);

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
#F  PowerMapOfGroupWithInvariants( <n>, <ccl>, <invariants> )
##
InstallGlobalFunction( PowerMapOfGroupWithInvariants,
    function( n, ccl, invariants )

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
          powinv,    # invariants of `pow'
          limit;     # do we limit calculation if exponent exceeds order?

    reps := List( ccl, Representative );
    ord  := List( reps, Order );
    invs := [];
    map  := [];
    nccl := Length( ccl );
    limit:=ValueOption("onlyuptoorder")=true;

    # Loop over the classes
    for i in [ 1 .. nccl ] do

      if ord[i]=1 then
        # identity always maps to itself
        map[i]:=i;
      elif n>ord[i] and limit then
        map[i]:=0;
      else
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
    return PowerMapOfGroupWithInvariants( n, ccl, [] );
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
    return PowerMapOfGroupWithInvariants( n, ccl, [CycleStructurePerm] );
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
    return PowerMapOfGroupWithInvariants( n, ccl, [ TraceMat ] );
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
  [IsGroup,IsEmpty], ReturnTrue);

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
  if HasIsAbelian(G) and IsAbelian(G) then
    return true;
  fi;
  Assert(2,IsNormal(G,N) and IsSubgroup(G,N));
  gen:=Filtered(GeneratorsOfGroup(G),i->not i in N);
  return ForAll([1..Length(gen)],
                i->ForAll([1..i-1],j->Comm(gen[i],gen[j]) in N));
end);

#############################################################################
##
#M  HasSolvableFactorGroup(<G>,<N>)   test whether G/N is solvable
##
InstallGlobalFunction(HasSolvableFactorGroup,function(G,N)
local gen, D, s, l;

  if HasIsSolvableGroup(G) and IsSolvableGroup(G) then
    return true;
  fi;
  Assert(2,IsNormal(G,N) and IsSubgroup(G,N));
  if HasDerivedSeriesOfGroup(G) then
    s := DerivedSeriesOfGroup(G);
    l := Length(s);
    return IsSubgroup(N,s[l]);
  fi;
  D := G;
  repeat
    gen:=Filtered(GeneratorsOfGroup(D),i->not i in N);
    if ForAll([1..Length(gen)],
                i->ForAll([1..i-1],j->Comm(gen[i],gen[j]) in N)) then
      return true;
    fi;
    D := DerivedSubgroup(D);
  until IsPerfectGroup(D);
  # this may be dangerous if N does not contain the identity of G
  SetIsSolvableGroup(G, false);
  return false;
end);

#############################################################################
##
#M  HasElementaryAbelianFactorGroup(<G>,<N>)   test whether G/N is el. abelian
##
InstallGlobalFunction(HasElementaryAbelianFactorGroup,function(G,N)
local gen,p;
  if HasIsElementaryAbelian(G) and IsElementaryAbelian(G) then
    return true;
  fi;
  if not HasAbelianFactorGroup(G,N) then
    return false;
  fi;
  gen:=Filtered(GeneratorsOfGroup(G),i->not i in N);
  if gen = [] then
    return true;
  fi;
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
    if CanEasilySortElements(One(grp)) then
        gens := Set(GeneratorsOfGroup(grp));
    elif CanEasilyCompareElements(One(grp)) then
        gens := DuplicateFreeList(GeneratorsOfGroup( grp ));
    else
        gens := GeneratorsOfGroup(grp);
    fi;
    if 0 = Length(gens)  then
        SetPseudoRandomSeed( grp, [[],One(grp),One(grp)] );
        return;
    fi;
    len := Maximum( len, Length(gens), 2 );

    # add random generators
    seed := ShallowCopy(gens);
    for i  in [ Length(gens)+1 .. len ]  do
        seed[i] := Random(gens);
    od;
    SetPseudoRandomSeed( grp, [seed,One(grp),One(grp)] );

    # scramble seed
    for i  in [ 1 .. scramble ]  do
        PseudoRandom(grp);
    od;

end);


InstallGlobalFunction(Group_PseudoRandom,
function( grp )
    local   seed,  i,  j, k;

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
    i := Random( 1, Length(seed[1]) );
    j := Random( 1, Length(seed[1]) );
    k := Random( 1, Length(seed[1]) );

    seed[3] := seed[3]*seed[1][i];
    seed[1][j] := seed[1][j]*seed[3];
    seed[2] := seed[2]*seed[1][k];

    return seed[2];

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

#############################################################################
##
#M  CharacteristicSubgroups( <G> )
##
InstallMethod(CharacteristicSubgroups,"use automorphisms",true,[IsGroup],
  G->Filtered(NormalSubgroups(G),x->IsCharacteristicSubgroup(G,x)));

InstallTrueMethod( CanComputeSize, HasSize );

InstallMethod( CanComputeIndex,"by default impossible unless identical",
  IsIdenticalObj, [IsGroup,IsGroup], IsIdenticalObj );

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
#F  Factorization( <G>, <elm> ) . . . . . . . . . . . . . . .  generic method
##

BindGlobal("GenericFactorizationGroup",
# code based on work by N. Rohrbacher
function(G,elm)
  local maxlist, rvalue, setrvalue, one, hom, names, F, gens, letters, info,
  iso, e, objelm, objnum, numobj, actobj, S, cnt, SC, i, p, olens, stblst,
  l, rs, idword, dist, aim, ll, from, to, total, diam, write, count, cont,
  ri, old, new, a, rna, w, stop, num, hold, g,OG,spheres;

  # A list can have length at most 2^27
  maxlist:=2^27;
  # for determining the mod3 entry for element number i we need to access
  # within the right list
  rvalue:=function(i)
  local q, r, m;
    i:=(i-1)*2; # 2 bits per number
    q:=QuoInt(i,maxlist);
    r:=rs[q+1];
    m:=(i mod maxlist)+1;
    if r[m] then
      if r[m+1] then
        return 2;
      else
        return 1;
      fi;
    elif r[m+1] then
      return 0;
    else
      return 8; # both false is ``infinity'' value
    fi;
  end;

  setrvalue:=function(i,v)
  local q, r, m;
    i:=(i-1)*2; # 2 bits per number
    q:=QuoInt(i,maxlist);
    r:=rs[q+1];
    m:=(i mod maxlist)+1;
    if v=0 then
      r[m]:=false;r[m+1]:=true;
    elif v=1 then
      r[m]:=true;r[m+1]:=false;
    elif v=2 then
      r[m]:=true;r[m+1]:=true;
    else
      r[m]:=false;r[m+1]:=false;
    fi;
  end;

  if not elm in G and elm<>fail then
    return fail;
  fi;

  spheres:=[];
  one:=One(G);

  OG:=G;
  if not IsBound(G!.factorinfo) then
    names:=ValueOption("names");
    if not IsList(names) or Length(names)<>Length(GeneratorsOfGroup(G)) then
      names:="x";
    fi;
    hom:=EpimorphismFromFreeGroup(G:names:=names);
    G!.factFreeMap:=hom; # compatibility
    F:=Source(hom);
    gens:=ShallowCopy(MappingGeneratorsImages(hom)[2]);
    letters:=List(MappingGeneratorsImages(hom)[1],UnderlyingElement);
    info:=rec(hom:=hom);

    iso:=fail;
    if not (IsPermGroup(G) or IsPcGroup(G)) then
      # the group likely does not have a good enumerator
      iso:=IsomorphismPermGroup(G);
      G:=Image(iso,G);
      one:=One(G);
      gens:=List(gens,i->Image(iso,i));
      hom:=GroupHomomorphismByImagesNC(F,G,
               MappingGeneratorsImages(hom)[1],gens);
      if not HasEpimorphismFromFreeGroup(G) then
        SetEpimorphismFromFreeGroup(G,hom);
        G!.factFreeMap:=hom; # compatibility
      fi;
    fi;
    info.iso:=iso;
    e:= Enumerator(G);
    objelm:=x->x;
    objnum:=x->e[x];
    numobj:=x->PositionCanonical(e,x);
    actobj:=OnRight;
    if IsPermGroup(G) and Size(G)>1 then

      #tune enumerator (use a bit more memory to get unfactorized transversal
      # on top level)
      if not IsPlistRep(e) then
        e:=EnumeratorByFunctions( G, rec(
                    ElementNumber:=e!.ElementNumber,
                    NumberElement:=e!.NumberElement,
                    Length:=e!.Length,
                    PrintObj:=e!.PrintObj,
                    stabChain:=ShallowCopy(e!.stabChain)));
        S:=e!.stabChain;
      else
        S:=ShallowCopy(StabChainMutable(G));
      fi;

      cnt:=QuoInt(10^6,4*NrMovedPoints(G));
      SC:=S;
      repeat
        S.newtransversal:=ShallowCopy(S.transversal);
        S.stabilizer:=ShallowCopy(S.stabilizer);
        i:=1;
        while i<=Length(S.orbit) do
          p:=S.orbit[i];
          S.newtransversal[p]:=InverseRepresentative(S,p);
          i:=i+1;
        od;
        cnt:=cnt-Length(S.orbit);
        S.transversal:=S.newtransversal;
        Unbind(S.newtransversal);
        S:=S.stabilizer;
      until cnt<1 or Length(S.generators)=0;
      # store orbit lengths
      olens:=[];
      stblst:=[];
      S:=SC;
      while Length(S.generators)>0 do
        Add(olens,Length(S.orbit));
        Add(stblst,S);
        S:=S.stabilizer;
      od;
      stblst:=Reversed(stblst);

      # do we want to use base images instead
      if Length(BaseStabChain(SC))<Length(SC.orbit)/3 then
        e:=BaseStabChain(SC);
        objelm:=x->OnTuples(e,x);
        objnum:=
          function(pos)
          local stk, S, l, img, te, d, elm, i;
            pos:=pos-1;
            stk:=[];
            S:=SC;
            l:=Length(e);
            for d in [1..l] do
              img:=S.orbit[pos mod olens[d] + 1];
              pos:=QuoInt(pos,olens[d]);
              while img<>S.orbit[1] do
                te:=S.transversal[img];
                Add(stk,te);
                img:=img^te;
              od;
              S:=S.stabilizer;
            od;
            elm:=ShallowCopy(e); # base;
            for d in [Length(stk),Length(stk)-1..1] do
              te:=stk[d];
              for i in [1..l] do
                elm[i]:=elm[i]/te;
              od;
            od;
            return elm;
          end;

        numobj:=
          function(elm)
          local pos, val, S, img, d,te;
            pos:=1;
            val:=1;
            S:=SC;
            for d in [1..Length(e)] do
              img:=elm[d]; # image base point
              #pos:=pos+val*S.orbitpos[img];
              #val:=val*S.ol;
              pos:=pos+val*(Position(S.orbit,img)-1);
              val:=val*Length(S.orbit);
              #elm:=OnTuples(elm,InverseRepresentative(S,img));
              while img<>S.orbit[1] do
                te:=S.transversal[img];
                img:=img^te;
                elm:=OnTuples(elm,te);
              od;
              S:=S.stabilizer;
            od;
            return pos;
          end;

        actobj:=OnTuples;
      fi;

    fi;

    info.objelm:=objelm;
    info.objnum:=objnum;
    info.numobj:=numobj;
    info.actobj:=actobj;
    info.dist:=[1];

    l:=Length(gens);
    gens:=ShallowCopy(gens);
    for i in [1..l] do
      if Order(gens[i])>2 then
        Add(gens,gens[i]^-1);
        Add(letters,letters[i]^-1);
      fi;
    od;

    info.mygens:=gens;
    info.mylett:=letters;
    info.fam:=FamilyObj(One(Source(hom)));
    info.rvalue:=rvalue;
    info.setrvalue:=setrvalue;

    # initialize all lists
    rs:=List([1..QuoInt(2*Size(G),maxlist)],i->BlistList([1..maxlist],[]));
    Add(rs,BlistList([1..(2*Size(G) mod maxlist)],[]));
    setrvalue(numobj(objelm(one)),0);
    info.prodlist:=rs;
    info.count:=Order(G)-1;
    info.last:=[numobj(objelm(one))];
    info.from:=1;
    info.write:=1;
    info.to:=1;

    info.diam:=0;
    info.spheres:=spheres;
    OG!.factorinfo:=info;

  else
    info:=G!.factorinfo;
    spheres:=info.spheres;
    rs:=info.prodlist;
    if info.iso<>fail then
      G:=Image(info.iso);
    fi;
  fi;

  hom:=info.hom;
  if info.iso<>fail then
    elm:=Image(info.iso,elm);
  fi;

  F:=Source(hom);
  idword:=One(F);
  if elm<>fail and IsOne(elm) then return idword;fi; # special treatment length 0

  gens:=info.mygens;
  letters:= info.mylett;
  objelm:=info.objelm;
  objnum:=info.objnum;
  numobj:=info.numobj;
  actobj:=info.actobj;

  dist:=info.dist;

  if elm=fail then
    aim:=fail;
  else
    aim:=numobj(objelm(elm));
  fi;
  if aim=fail or rvalue(aim)=8 then
    # element not yet found. We need to expand

    ll:=info.last;
    from:=info.from;
    to:=info.to;
    total:=to-from+1;
    diam:=info.diam;
    write:=info.write;
    count:=info.count;
    if diam>1 then
      Info(InfoGroup,1,"continue diameter ",diam,", extend ",total,
           " elements, ",count," elements left");
    fi;

    cont:=true;

    while cont do
      if from=1 then
        diam:=diam+1;
        dist[diam]:=total;
        Info(InfoGroup,1,"process diameter ",diam,", extend ",total,
          " elements, ",count," elements left");
        if IsMutable(spheres) then
          Add(spheres,total);
        fi;
        if count=0 and elm=fail then
          info.from:=from;
          info.to:=to;
          info.write:=write;
          info.count:=count;
          info.diam:=diam;
          MakeImmutable(spheres);
          return spheres;
        fi;
      fi;
      i:=ll[from];
      from:=from+1;
      if 0=from mod 20000 then
        CompletionBar(InfoGroup,2,"#I  processed ",(total-(to-from))/(total+1));
      fi;
      ri:=(rvalue(i)+1) mod 3;
      old:=objnum(i);
      for g in gens do
        new:=numobj(actobj(old,g));
        if rvalue(new)=8 then
          setrvalue(new,ri);
          if new=aim then cont:=false;fi;
          # add new element
          if from>write then
            # overwrite old position
            ll[write]:=new;
            write:=write+1;
          else
            Add(ll,new);
          fi;
          count:=count-1;
        fi;
      od;
      if from>to then
        # we did all of the current length
        l:=Length(ll);
        # move the end in free space
        i:=write;
        while i<=to and l>to do
          ll[i]:=ll[l];
          Unbind(ll[l]);
          i:=i+1;
          l:=l-1;
        od;
        # the list gets shorter
        while i<=to do
          Unbind(ll[i]);
          i:=i+1;
        od;

        if from>19999 then
          CompletionBar(InfoGroup,2,"#I  processed ",false);
        fi;
        from:=1;
        to:=Length(ll);
        total:=to-from+1;
        write:=1;
      fi;

    od;
    CompletionBar(InfoGroup,2,"#I  processed ",false);
    info.from:=from;
    info.to:=to;
    info.write:=write;
    info.count:=count;
    info.diam:=diam;
  fi;


  # no pool needed: If the length of w is n, and g is a generator, the
  # length of w/g cannot be less than n-1 (otherwise (w/g)*g is a shorter
  # word) and cannot be more than n+1 (otherwise w/g is a shorter word for
  # it). Thus, if the length of w/g is OK mod 3, it is the right path.

  one:=objelm(One(G));
  a:=objelm(elm);
  rna:=rvalue(numobj(a));
  w:=UnderlyingElement(idword);
  while a<>one do
    stop:=false;
    num:=1;
    while num<=Length(gens) and stop=false do
      old:=actobj(a,gens[num]^-1);
      hold:=numobj(old);
      if rvalue(hold)= (rna - 1) mod 3 then
        # reduced to shorter
        a:=old;
        w:=w/letters[num];
        rna:=rna-1;
        stop:=true;
      fi;
      num:=num+1;
    od;
  od;
  return ElementOfFpGroup(info.fam,w^-1);

end);

InstallMethod(Factorization,"generic method", true,
               [ IsGroup, IsMultiplicativeElementWithInverse ], 0,
  GenericFactorizationGroup);

InstallMethod(GrowthFunctionOfGroup,"finite groups",[IsGroup and
  HasGeneratorsOfGroup and IsFinite],0,
function(G)
local s;
  s:=GenericFactorizationGroup(G,fail);
  return s;
end);

InstallMethod(GrowthFunctionOfGroup,"groups and orders",
  [IsGroup and HasGeneratorsOfGroup,IsPosInt],0,
function(G,r)
local s,prev,old,sort,geni,new,a,i,j,g;
  geni:=DuplicateFreeList(Concatenation(GeneratorsOfGroup(G),
                          List(GeneratorsOfGroup(G),Inverse)));
  if (IsFinite(G) and (CanEasilyTestMembership(G) or HasSize(G))
   and Length(geni)^r>Size(G)/2) or HasGrowthFunctionOfGroup(G) then
    s:=GrowthFunctionOfGroup(G);
    return s{[1..Minimum(Length(s),r+1)]};
  fi;

  # enumerate the bubbles
  s:=[1];
  prev:=[One(G)];
  old:=ShallowCopy(prev);
  sort:=CanEasilySortElements(One(G));
  for i in [1..r] do
    new:=[];
    for j in prev do
      for g in geni do
        a:=j*g;
        if not a in old then
          Add(new,a);
          if sort then
            AddSet(old,a);
          else
            Add(old,a);
          fi;
        fi;
      od;
    od;
    if Length(new)>0 then
      Add(s,Length(new));
    fi;
    prev:=new;
  od;
  return s;
end);

#############################################################################
##
#M  Order( <G> )
##
##  Since groups are domains, the recommended command to compute the order
##  of a group is `Size' (see~"Size").
##  For convenience, group orders can also be computed with `Order'.
##
##  *Note* that the existence of this method makes it necessary that no
##  group will ever be regarded as a multiplicative element!
##
InstallOtherMethod( Order,
    "for a group",
    [ IsGroup ],
    Size );
