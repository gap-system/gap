#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Gábor Horváth, Stefan Kohl, Markus Püschel, Sebastian Egner.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains a method for determining structure descriptions for
##  given finite groups and implementations of related functionality.
##
##  The purpose of this method is to give a human reader a rough impression
##  of the group structure -- it does neither determine the group up to
##  isomorphism (this would make the description for larger groups quite long
##  and difficult to read) nor is it usually the only ``sensible''
##  description for a given group.
##
##  The code has been translated, simplified and extended by Stefan Kohl
##  from GAP3 code written by Markus Püschel and Sebastian Egner.
##


#############################################################################
##
#M  IsTrivialNormalIntersectionInList( <L>, <U>, <V> ) . . . . generic method
##
InstallGlobalFunction( IsTrivialNormalIntersectionInList,

  function( MinNs, U, V )
    local N, g;

    for N in MinNs do
      g := First(GeneratorsOfGroup(N), g -> g<>One(N));
      if g <> fail and g in U and g in V then
        return false;
      fi;
    od;
    return true;
  end);

#############################################################################
##
#M  IsTrivialNormalIntersection( <G>, <U>, <V> ) . . . . . . . generic method
##

InstallMethod( IsTrivialNormalIntersection,
               "if minimal normal subgroups are computed", IsFamFamFam,
               [ IsGroup and HasMinimalNormalSubgroups, IsGroup, IsGroup ],

  function( G, U, V )
    local N, g;

    for N in MinimalNormalSubgroups(G) do
      g := First(GeneratorsOfGroup(N), g -> g<>One(N));
      if g <> fail and g in U and g in V then
        # found a nontrivial common element
        return false;
      fi;
    od;
    # if U and V intersect nontrivially, then their intersection must contain
    # a minimal normal subgroup, and therefore both U and V contains any of
    # its generators
    return true;
  end);

InstallMethod( IsTrivialNormalIntersection,
               "generic method", IsFamFamFam,
               [ IsGroup, IsGroup, IsGroup ],

  function( G, U, V )

    return IsTrivial(NormalIntersection(U, V));
  end);

#############################################################################
##
#M  UnionIfCanEasilySortElements( <L1>[, <L2>, ... ] ) . . . . generic method
##
InstallGlobalFunction( UnionIfCanEasilySortElements,

  function( arg )

    if ForAll(arg, CanEasilySortElements) then
      return Union(arg);
    else
      return Concatenation(arg);
    fi;
  end);

#############################################################################
##
#M  AddSetIfCanEasilySortElements( <list>[, <obj> ) . . . . . generic method
##
InstallGlobalFunction( AddSetIfCanEasilySortElements,

  function( list, obj )

    if CanEasilySortElements( list ) and IsSet( list ) then
      AddSet( list, obj );
    else
      Add( list, obj );
    fi;
  end);

#############################################################################
##
#M  NormalComplement( <G>, <N> ) . . . . . . . . . . . generic method
##
InstallMethod( NormalComplement,
               "generic method", IsIdenticalObj, [ IsGroup,  IsGroup ],

  function( G, N )

    # if <N> is trivial then the only complement is <G>
    if IsTrivial(N) then
      return G;

    # if <G> and <N> are equal then the only complement is trivial
    elif G = N  then
      return TrivialSubgroup(G);

    elif not (IsSubgroup(G, N) and IsNormal(G, N)) then
      Error("N must be a normal subgroup of G");

    else
      return NormalComplementNC(G, N);
    fi;
  end);

InstallMethod( NormalComplementNC,
               "generic method", IsIdenticalObj, [ IsGroup,  IsGroup ],

  function( G, N )

    local F,    # G/N
          DfF,  # Direct factors of F=G/N
          gF,   # element of F=G/N
          g,    # element of G corresponding to gF
          x,    # element of G
          i,    # running index
          l,    # list for storing stuff
          b,    # elements of abelian complement
          C,    # Center of G
          S,    # Subgroup of C
          r,    # RationalClass of C
          R,    # right coset
          gens, # generators of subgroup of C
          B,    # complement to N
          T,    # = [C_G(N), G] = 1 x B'
          Gf,   # = G/T = N x B/B'
          Nf,   # = NT/T
          Bf,   # abelian complement to Nf in Gf ( = B/B')
          nat,
          BfF;  # Direct factors of Bf

    # if <N> is trivial then the only complement is <G>
    if IsTrivial(N) then
      return G;

    # if <G> and <N> are equal then the only complement is trivial
    elif G = N  then
      return TrivialSubgroup(G);

    # if G/N is abelian
    elif HasAbelianFactorGroup(G, N) then
      nat:=NaturalHomomorphismByNormalSubgroupNC(G,N);
      #F := FactorGroupNC(G, N);
      F:=Image(nat,G);
      b := [];
      l := [];
      i:=0;
      for gF in IndependentGeneratorsOfAbelianGroup(F) do
        i := i+1;
        g := PreImagesRepresentative(nat, gF);
        R := RightCoset(N, g);
        # DirectFactorsOfGroup already computed Center and RationalClasses
        # when calling NormalComplement
        if HasCenter(G) and HasRationalClasses(Center(G)) then
          l := [];
          C := Center(G);
          for r in RationalClasses(C) do
            if Order(Representative(r)) = Order(gF) then
              for x in Set(r) do
                if x in R then
                  l := [x];
                  break;
                fi;
              od;
            fi;
          od;
          # Intersection(l, R) can take a long time
          l := First(l, ReturnTrue);
        # if N is big, then Center is hopefully small and fast to compute
        elif HasCenter(G) or Size(N) > Index(G, N) then
          C := Center(G);
          # it is enough to look for the Order(gF)-part of C
          gens := [];
          for x in IndependentGeneratorsOfAbelianGroup(C) do
            Add(gens, x^(Order(x)/GcdInt(Order(x), Order(gF))));
          od;
          S := SubgroupNC(C, gens);
          if Size(S) > Size(N) then
            # Intersection(S, R) can take a long time
            l := First(R, x -> Order(x) = Order(gF) and x in S);
          else
            # Intersection(C, R) can take a long time
            l := First(S, x -> Order(x) = Order(gF) and x in R);
          fi;
        # N is small, then looping through its elements might be more
        # efficient than computing the Center
        else
          l := First(R, x -> Order(x) = Order(gF)
                          and IsCentral(G, SubgroupNC(G, [x])));
        fi;
        if l <> fail then
          b[i] := l;
        else
          return fail;
        fi;
      od;
      B := SubgroupNC(G, b);
      return B;

    # if G/N is not abelian
    else
      T := CommutatorSubgroup(Centralizer(G, N), G);
      if not IsTrivial(T) and IsTrivialNormalIntersection(G, T, N) then
        #Gf := FactorGroupNC(G, T);
        #Nf := Image(NaturalHomomorphism(Gf), N);
        nat:=NaturalHomomorphismByNormalSubgroupNC(G, T);
        Gf:=Image(nat,G);
        Nf:=Image(nat,N);
        # not quite sure if this check is needed
        if HasAbelianFactorGroup(Gf, Nf) then
          Bf := NormalComplementNC(Gf, Nf);
          if Bf = fail then
            return fail;
          else
            B := PreImage(nat, Bf);
            return B;
          fi;
        else
          return fail;
        fi;
      else
        return fail;
      fi;
    fi;
  end);

#############################################################################
##
#M  DirectFactorsOfGroup( <G> ) . . . . . . . . . . . . . . .  generic method
##
InstallMethod(DirectFactorsOfGroup,
            "for direct products if normal subgroups are computed", true,
            [ IsGroup and HasDirectProductInfo and HasNormalSubgroups ], 0,

  function(G)
    local i, info, Ns, MinNs, H, Df, DfNs, DfMinNs, N, g, gs;

    Ns := NormalSubgroups(G);
    MinNs := MinimalNormalSubgroups(G);
    Df := [];
    info := DirectProductInfo(G).groups;
    for i in [1..Length(info)] do
      H := Image(Embedding(G,i),info[i]);
      DfMinNs := Filtered(MinNs, N ->IsSubset(H, N));
      if Length(DfMinNs) = 1 then
        # size of DfMinNs is an upper bound to the number of components of H
        Df := UnionIfCanEasilySortElements(Df, [H]);
      else
        DfNs := Filtered(Ns, N ->IsSubset(H, N));
        gs := [ ];
        for N in DfMinNs do
          g := First(GeneratorsOfGroup(N), g -> g<>One(N));
          if g <> fail then
            AddSetIfCanEasilySortElements(gs, g);
          fi;
        od;
        # normal subgroup containing all minimal subgroups cannot have complement in H
        DfNs := Filtered(DfNs, N -> not IsSubset(N, gs));
        Df := UnionIfCanEasilySortElements(Df,
                            DirectFactorsOfGroupFromList(H, DfNs, DfMinNs));
      fi;
    od;
    return Df;
  end);

InstallMethod(DirectFactorsOfGroup, "for direct products", true,
                      [ IsGroup and HasDirectProductInfo ], 0,

  function(G)
    local i, info, Ns;

    Ns := [];
    info := DirectProductInfo(G).groups;
    for i in [1..Length(info)] do
      Ns := UnionIfCanEasilySortElements(Ns,
                        DirectFactorsOfGroup(Image(Embedding(G,i),info[i])));
    od;
    return Ns;
  end);

InstallMethod(DirectFactorsOfGroup, "if normal subgroups are computed", true,
                      [ IsGroup and HasNormalSubgroups ], 0,

  function(G)
    local Ns, MinNs, GGd, g, N, gs;

    Ns := NormalSubgroups(G);
    MinNs := MinimalNormalSubgroups(G);

    if Length(MinNs)= 1 then
      # size of MinNs is an upper bound to the number of components
      return [ G ];
    fi;

    if IsSolvableGroup(G) then
      GGd := CommutatorFactorGroup(G);
      if IsCyclic(GGd) and IsPrimePowerInt(Size(GGd)) then
        # G is direct indecomposable, because has a unique maximal subgroup
        return [ G ];
      fi;
    else
      GGd := CommutatorFactorGroup(G);
      # if GGd is not cyclic of prime power size then there are at least two
      # maximal subgroups
      if (IsTrivial(GGd) or (IsCyclic(GGd) and IsPrimePowerInt(Size(GGd))))
        and Length(MaximalNormalSubgroups(G))= 1 then
        # size of MaximalNormalSubgroups is an upper bound to the number of
        # components
        return [ G ];
      fi;
    fi;

    gs := [ ];
    for N in MinNs do
      g := First(GeneratorsOfGroup(N), g -> g<>One(N));
      if g <> fail then
        AddSetIfCanEasilySortElements(gs, g);
      fi;
    od;
    # normal subgroup containing all minimal subgroups cannot have complement
    Ns := Filtered(Ns, N -> not IsSubset(N, gs));

    return DirectFactorsOfGroupFromList(G, Ns, MinNs);
  end);

InstallMethod(DirectFactorsOfGroup, "generic method", true,
                        [ IsGroup ], 0,
  function(G)

    local Gd,       # G'
          GGd,      # G/G'
          C,        # Center(G)
          D,        # Intersection(C, Gd)
          Ns,       # list of normal subgroups
          MinNs,    # list of minimal normal subgroups
          gs,       # list containing one generator for each MinNs
          g,        # group element
          N,        # (possible) component of G, containing g
          B;        # (possible) complement of G in N

    # for abelian groups return the canonical decomposition
    if IsTrivial(G) then
      return [G];
    elif IsAbelian(G) then
      Ns := [];
      for g in IndependentGeneratorsOfAbelianGroup(G) do
        Ns := UnionIfCanEasilySortElements(Ns, [SubgroupNC(G, [g])]);
      od;
      return Ns;
    fi;

    if not IsFinite(G) then TryNextMethod(); fi;

    # the KN method performs slower in practice, only called if forced
    if ValueOption("useKN") = true then
      return DirectFactorsOfGroupByKN(G);
    fi;

    # nilpotent groups are direct products of Sylow subgroups
    if IsNilpotentGroup(G) then
      if not IsPGroup(G) then
        Ns := [ ];
        for N in SylowSystem(G) do
          Ns := UnionIfCanEasilySortElements(Ns, DirectFactorsOfGroup(N));
        od;
        return Ns;
      elif IsCyclic(Center(G)) then
        # G is direct indecomposable, because has a unique minimal subgroup
        return [ G ];
      fi;
    # nonabelian p-groups cannot have a unique maximal subgroup
    elif IsSolvableGroup(G) then
      GGd := CommutatorFactorGroup(G);
      if IsCyclic(GGd) and IsPrimePowerInt(Size(GGd)) then
        # G is direct indecomposable, because has a unique maximal subgroup
        return [ G ];
      fi;
    fi;

    # look for abelian cyclic component from the center
    C := Center(G);
    # abelian cyclic components have trivial intersection with the commutator
    Gd := DerivedSubgroup(G);
    D := Intersection(C, Gd);
    for g in RationalClasses(C) do
      N := Subgroup(C, [Representative(g)]);
      if not IsTrivial(N) and IsTrivialNormalIntersection(C, D, N) then
        B := NormalComplementNC(G, N);
        # if B is a complement to N
        if B <> fail then
          return UnionIfCanEasilySortElements( DirectFactorsOfGroup(N),
                                                  DirectFactorsOfGroup(B));
        fi;
      fi;
    od;

    # all components are nonabelian
    if IsCyclic(Gd) and IsPrimePowerInt(Size(Gd)) then
      # if A and B are two nonabelian components, then
      # A' and B' must be nontrivial
      # this can only help for some metabelian groups
      return [ G ];
    fi;

    if not IsTrivial(C) and HasAbelianFactorGroup(G, C)
      and Length(DirectFactorsOfGroup(G/C)) < 4 then
      # if A and B are two nonabelian components,
      # where A/Center(A) and B/Center(B) are abelian, then
      # A/Center(A) and B/Center(B) must have at least two components each
      return [ G ];
    fi;

    # if everything else fails, compute all normal subgroups
    Ns := NormalSubgroups(G);
    if IsNilpotentGroup(G) then
        # minimal normal subgroups are central in nilpotent groups
        MinNs := MinimalNormalSubgroups(Center(G));
    else
      # MinimalNormalSubgroups seems to compute faster after NormalSubgroups
      MinNs := MinimalNormalSubgroups(G);
    fi;

    if Length(MinNs)= 1 then
      # size of MinNs is an upper bound to the number of components
      return [ G ];
    fi;

    if not IsSolvableGroup(G) then
      GGd := CommutatorFactorGroup(G);
      # if GGd is not cyclic of prime power size then there are at least two
      # maximal subgroups
      if (IsTrivial(GGd) or (IsCyclic(GGd) and IsPrimePowerInt(Size(GGd))))
        and Length(MaximalNormalSubgroups(G))= 1 then
        # size of MaximalNormalSubgroups is an upper bound to the number of
        # components
        return [ G ];
      fi;
    fi;

    gs := [ ];
    for N in MinNs do
      g := First(GeneratorsOfGroup(N), g -> g<>One(N));
      if g <> fail then
        AddSetIfCanEasilySortElements(gs, g);
      fi;
    od;
    # normal subgroup containing all minimal subgroups cannot have complement
    Ns := Filtered(Ns, N -> not IsSubset(N, gs));

    return DirectFactorsOfGroupFromList(G, Ns, MinNs);
  end);

InstallMethod(CharacteristicFactorsOfGroup, "generic method", true,
                        [ IsGroup ], 0,
function(G)
local Ns,MinNs,sel,a,sz,j,gs,g,N;

  Ns := ShallowCopy(CharacteristicSubgroups(G));
  SortBy(Ns,Size);
  MinNs:=[];
  sel:=[2..Length(Ns)-1];
  while Length(sel)>0 do
    a:=sel[1];
    sz:=Size(Ns[a]);
    RemoveSet(sel,sel[1]);
    Add(MinNs,Ns[a]);
    for j in ShallowCopy(sel) do
      if Size(Ns[j])>sz and Size(Ns[j]) mod sz=0 and IsSubset(Ns[j],Ns[a]) then
        RemoveSet(sel,j);
      fi;
    od;
  od;

  if Length(MinNs)= 1 then
    # size of MinNs is an upper bound to the number of components
    return [ G ];
  fi;

  gs := [ ];
  for N in MinNs do
    g := First(GeneratorsOfGroup(N), g -> g<>One(N));
    if g <> fail then
      AddSetIfCanEasilySortElements(gs, g);
    fi;
  od;
  # normal subgroup containing all minimal subgroups cannot have complement
  Ns := Filtered(Ns, N -> not IsSubset(N, gs));

  return DirectFactorsOfGroupFromList(G, Ns, MinNs);
end);

InstallGlobalFunction( DirectFactorsOfGroupFromList,

  function ( G, NList, MinList )

    local g, N, gs, Ns, MinNs, NNs, MinNNs, facts, sizes, i, j, s1, s2;

    if Length(MinList)=1 then
      # size of MinList is an upper bound to the number of components
      return [ G ];
    fi;

    Ns := ShallowCopy(NList);
    MinNs := ShallowCopy(MinList);
    gs := [ ];
    for N in MinNs do
      g := First(GeneratorsOfGroup(N), g -> g<>One(N));
      if g <> fail then
        AddSetIfCanEasilySortElements(gs, g);
      fi;
    od;
    # normal subgroup containing all minimal subgroups cannot have complement
    Ns := Filtered(Ns, N -> not IsSubset(N, gs));
    sizes := List(Ns,Size);
    SortParallel(sizes,Ns);
    for s1 in Difference(Set(sizes),[Size(G),1]) do
      i := PositionSet(sizes,s1);
      s2 := Size(G)/s1;
      if s1 <= s2 then
        repeat
          if s2 > s1 then
            j := PositionSet(sizes,s2);
            if j = fail then break; fi;
          else
            j := i + 1;
          fi;
          while j <= Size(sizes) and sizes[j] = s2 do
            if IsTrivialNormalIntersectionInList(MinList,Ns[i],Ns[j]) then
            # Ns[i] is the smallest direct factor, hence direct irreducible
            # we keep from Ns only the subgroups of Ns[j] having size min. s1
              NNs := Filtered(Ns{[i..j]}, N -> Size(N) >= s1
                              and s2 mod Size(N) = 0 and IsSubset(Ns[j], N));
              MinNNs := Filtered(MinNs, N -> s2 mod Size(N) = 0
                                                and IsSubset(Ns[j], N));
              return UnionIfCanEasilySortElements( [ Ns[i] ],
                          DirectFactorsOfGroupFromList(Ns[j], NNs, MinNNs));
            fi;
            j := j + 1;
          od;
          i := i + 1;
        until i>=Size(sizes) or sizes[i] <> s1;
      fi;
    od;
    return [ G ];
  end );

InstallGlobalFunction(DirectFactorsOfGroupByKN,

  function(G)

    local Ns,       # list of some direct components
          i,        # running index
          Gd,       # derived subgroup G'
          p,        # prime
          N,        # (possible) component of G
          B,        # complement of G in N
          K,        # normal subgroup
          prodK,    # product of normal subgroups
          Z1,       # contains a (unique) component with trivial center
          g,a,b,    # elements of G
          C,        # Center(G)
          D,        # Intersection(C, Gd)
          Cl,       # all conjugacy classes of G
          Clf,      # filtered list of conjugacy classes of G
          c1,c2,c3, # conjugacy class of G
          com,      # true if c1 and c2 commute, false otherwise
          prod,     # product of c1 and c2
          RedCl,    # reducible conjugacy classes of G
          IrrCl,    # irreducible conjugacy classes of G
          preedges, # pre-edges of the non-commuting graph
          edges,    # final edges of the non-commuting graph
          e,        # one edge of the non-commuting graph
          comp,     # components of the non-commuting graph
          DfZ1,     # nonabelian direct factors of Z1
          S1;       # index set corresponding to first component

    # for abelian groups return the canonical decomposition
    if IsTrivial(G) then
      return [G];
    elif IsAbelian(G) then
      Ns := [];
      for g in IndependentGeneratorsOfAbelianGroup(G) do
        Ns := UnionIfCanEasilySortElements(Ns, [SubgroupNC(G, [g])]);
      od;
      return Ns;
    fi;

    # look for abelian cyclic component from the center
    C := Center(G);
    # abelian cyclic components have trivial intersection with the commutator
    Gd := DerivedSubgroup(G);
    D := Intersection(C, Gd);
    for g in RationalClasses(C) do
      N := Subgroup(C, [Representative(g)]);
      if not IsTrivial(N) and IsTrivialNormalIntersection(C, D, N) then
        B := NormalComplementNC(G, N);
        # if B is a complement to N
        if B <> fail then
          return UnionIfCanEasilySortElements( DirectFactorsOfGroup(N),
                                                    DirectFactorsOfGroup(B));
        fi;
      fi;
    od;

    # all components are nonabelian
    # !!! this can (and should) be made more efficient later !!!
    # instead of conjugacy classes we should calculate by normal subgroups
    # generated by 1 element
    Cl := Set(ConjugacyClasses(G));
    RedCl := Set(Filtered(Cl, x -> Size(x) = 1));
    Clf := Difference(Cl, RedCl);
    preedges := [];
    for c1 in Clf do
      for c2 in Clf do
        com := true;
        prod := [];
        if c1 <> c2 then
          for a in c1 do
            for b in c2 do
              g := a*b;
              if g<>b*a then
                com := false;
                AddSetIfCanEasilySortElements(preedges, [c1, c2]);
                break;
              else
                AddSetIfCanEasilySortElements(prod, g);
              fi;
            od;
            if not com then
              break;
            fi;
          od;
          if com and Size(prod) = Size(c1)*Size(c2) then
            a := Representative(c1);
            b := Representative(c2);
            c3 := ConjugacyClass(G, a*b);
            if Size(c3)=Size(prod) then
              AddSetIfCanEasilySortElements(RedCl, c3);
            fi;
          fi;
        fi;
      od;
    od;
    IrrCl := Difference(Clf, RedCl);

    # need to remove edges corresponding to reducible classes
    edges := ShallowCopy(preedges);
    for e in preedges do
      if Intersection(e, RedCl) <> [] then
        RemoveSet(edges, e);
      fi;
    od;

    # now we create the graph components of the irreducible class graph
    # as an equivalence relation
    # this is not compatible with and not using the grape package
    comp := EquivalenceRelationPartition(
              EquivalenceRelationByPairsNC(IrrCl, edges));

    # replace classes in comp by their representatives
    comp := List(comp, x-> Set(x, Representative));

    # now replace every list by their generated normal subgroup
    Ns := List(comp, x-> NormalClosure(G, SubgroupNC(G, x)));
    Ns := UnionIfCanEasilySortElements(Ns);
    if IsTrivial(C) or Size(Ns)=1 then
      return Ns;
    fi;

    # look for the possible direct components from Ns
    # partition to two sets, consider both
    for S1 in IteratorOfCombinations(Ns) do
      if S1 <> [] and S1<>Ns then
        prodK := TrivialSubgroup(G);
        for K in S1 do
          prodK := ClosureGroup(prodK, K);
        od;
        Z1 := Centralizer(G, prodK);
        # Z1 is nonabelian <==> contains a nonabelian factor
        if not IsAbelian(Z1) then
          N := First(DirectFactorsOfGroupByKN(Z1), x-> not IsAbelian(x));
          # not sure if IsNormal(G, N) should be checked

          # this certainly can be done better,
          # because we basically know all possible normal subgroups
          # but it suffices for now
          B := NormalComplement(G, N);
          if B <> fail then
            # N is direct indecomposable by construction
            return UnionIfCanEasilySortElements([N],
                                                  DirectFactorsOfGroupByKN(B));
          fi;
        fi;
      fi;
    od;

    # if no direct component is found
    return [ G ];
  end);


#############################################################################
##
#M  SemidirectDecompositions( <G> ) . . . . . . . . . . . . .  generic method
##
InstallGlobalFunction(SemidirectDecompositionsOfFiniteGroup, function( arg )

  local  G, Ns, fullNs, method, NHs, i, N, H, NH; #, sizes;

  method := "all";
  if Length(arg) = 1 and IsGroup(arg[1]) then
    G := arg[1];
    fullNs := true;
  elif Length(arg) = 2 and IsGroup(arg[1]) and arg[2] in ["all",
                                                          "any", "str"] then
    G := arg[1];
    method := arg[2];
    fullNs := true;
  elif Length(arg) = 2 and IsGroup(arg[1]) and IsList(arg[2])
      and ForAll( Set(arg[2]), N ->
                              IsSubgroup(arg[1], N) and IsNormal(arg[1], N))
      then
    G := arg[1];
    Ns := ShallowCopy(arg[2]);
    fullNs := false;
  elif Length(arg) = 3 and IsGroup(arg[1]) and IsList(arg[2])
      and ForAll( Set(arg[2]), N ->
                              IsSubgroup(arg[1], N) and IsNormal(arg[1], N))
      and arg[3] in ["all", "any", "str"] then
    G := arg[1];
    Ns := ShallowCopy(arg[2]);
    method := arg[3];
    fullNs := false;
  else
    Error("usage: SemidirectDecompositionsOfFiniteGroup(<G> [, <Ns>] [, <mthd>])");
  fi;

  if HasSemidirectDecompositions(G) then
    NHs := [ ];
    for NH in SemidirectDecompositions(G) do
      N := NH[1];
      H := NH[2];
      if method in [ "any", "str" ] and not IsTrivial(N)
        and not IsTrivial(H) and
        ( not IsBound(Ns) or N in Ns ) then
        return [ N, H ];
      elif method="all" and
        ( not IsBound(Ns) or N in Ns ) then
        AddSetIfCanEasilySortElements(NHs, [ N, H ]);
      fi;
    od;
    if method in [ "any", "str" ] then
      return fail;
    elif method = "all" then
      return NHs;
    fi;
  fi;

  if method in [ "any", "str" ] then
    if HasSemidirectProductInfo(G) then
      N := Image(Embedding(G, 2));
      H := Image(Embedding(G, 1));
      if not IsTrivial(N) and not IsTrivial(H) and
        ( not IsBound(Ns) or N in Ns ) then
        return [ N, H ];
      fi;
    fi;
    N := NormalHallSubgroupsFromSylows(G, "any");
    if N <> fail then
      # by the Schur-Zassenhaus theorem there must exist a complement
      if method = "any" then
        H := ComplementClassesRepresentatives(G, N)[1];
        return [ N, H ];
      # only the isomorphism type of the complement is interesting
      elif method = "str" then
        Assert(1, Length( ComplementClassesRepresentatives(G, N) ) > 0);
        return [ N, G/N ];
      fi;
    fi;
  fi;

  # simple groups have no nontrivial normal subgroups
  if IsSimpleGroup(G) then
    if method in [ "any", "str" ] then
      return fail;
    elif method = "all" then
      return [ [TrivialSubgroup(G), G], [G, TrivialSubgroup(G)] ];
    fi;
  fi;

  if not IsBound(Ns) then
    Ns := ShallowCopy(NormalSubgroups(G));
  fi;
# does not seem to make things faster
#  if method in [ "any", "str" ] then
#    sizes := List(Ns, Size);
#    SortParallel(sizes, Ns);
#    Ns := Reversed(Ns);
#  fi;

  NHs := [ ];
  for N in Ns do
    if not IsSolvableGroup(N) and not HasSolvableFactorGroup(G, N) then
      # compute subgroup lattice, currently no other method for complement
      ConjugacyClassesSubgroups(G);;
    fi;
    H := ComplementClassesRepresentatives(G, N);
    if Length(H)>0 then
      if method in ["any", "str"] and not IsTrivial(N)
                                  and not IsTrivial(H[1]) then
        return [ N, H[1] ];
      else
        for i in [1..Length(H)] do
          AddSetIfCanEasilySortElements( NHs, [ N, H[i] ] );
        od;
      fi;
    fi;
  od;
  if method in [ "any", "str" ] then
    # no nontrivial decompositions exist
    if fullNs then
      SetSemidirectDecompositions(G,
                      [ [TrivialSubgroup(G), G], [G, TrivialSubgroup(G)] ]);
    fi;
    return fail;
  else
    if fullNs then
      SetSemidirectDecompositions(G, NHs);
    fi;
    return NHs;
  fi;
end);

InstallMethod( SemidirectDecompositions,
               "generic method", true, [ IsGroup and IsFinite ], 0,

  function( G )
    return SemidirectDecompositionsOfFiniteGroup(G);
  end );

RedispatchOnCondition( SemidirectDecompositions, true,
    [ IsGroup ],
    [ IsFinite ], 0);

#############################################################################
##
#M  DecompositionTypesOfGroup( <G> ) . . . . . . . . . . . . . generic method
##
InstallMethod( DecompositionTypesOfGroup,
               "generic method", true, [ IsGroup ], 0,

  function ( G )

    local  AG, a,  # abelian invariants; an invariant
           CS,     # conjugacy classes of non-(1-or-G) subgroups
           H,      # a subgroup (possibly normal)
           N,      # a normal subgroup
           T,      # an isom. type
           TH, tH, # isom. types for H, a type
           TN, tN, # isom. types for N, a type
           DTypes; # the decomposition types

    if not IsFinite(G) then TryNextMethod(); fi;

    DTypes := [ ];

    # abelian special case
    if IsAbelian(G) then
      AG := AbelianInvariants(G);
      if Length(AG) = 1 then DTypes := Set([AG[1]]); else
        T := ["x"];
        for a in AG do Add(T,a); od;
        DTypes := Set([T]);
      fi;
      return DTypes;
    fi;

    # brute force enumeration
    CS  := ConjugacyClassesSubgroups( G );
    CS  := CS{[2..Length(CS)-1]};
    for N in Filtered(List(Reversed(CS),Representative),
                      N -> IsNormal(G,N)) do
      for H in List(CS, Representative) do # Lemma1 (`SemidirectFactors...')
        if    Size(H)*Size(N) = Size(G)
          and IsTrivial(NormalIntersection(N,H))
        then
          # recursion (exponentially) on (semi-)factors
          TH := DecompositionTypesOfGroup(H);
          TN := DecompositionTypesOfGroup(N);
          if IsNormal(G,H)
          then
            # non-trivial G = H x N
            for tH in TH do
              for tN in TN do
                T := [ ];
                if   IsList(tH) and tH[1] = "x"
                then Append(T,tH{[2..Length(tH)]});
                else Add(T,tH); fi;
                if   IsList(tN) and tN[1] = "x"
                then Append(T,tN{[2..Length(tN)]});
                else Add(T,tN); fi;
                Sort(T);
                AddSet(DTypes,Concatenation(["x"],T));
              od;
            od;
          else
            # non-direct, non-trivial G = H semidirect N
            for tH in TH do
              for tN in TN do
                AddSet(DTypes,[":",tH,tN]);
              od;
            od;
          fi;
        fi;
      od;
    od;

    # default: a non-split extension
    if Length(DTypes) = 0 then DTypes := Set([["non-split",Size(G)]]); fi;

    return DTypes;
  end );

#############################################################################
##
#M  IsDihedralGroup( <G> ) . . . . . . . . . . . . . . . . . . generic method
##

BindGlobal( "DoComputeDihedralGenerators", function(G)
    local  Zn, G1, T, n, t, s, i;

    if Size(G) mod 2 <> 0 then return fail; fi;
    n := Size(G)/2;

    # find a normal subgroup of G of type Zn
    if n mod 2 <> 0 then
      # G = < s, t | s^n = t^2 = 1, s^t = s^-1 >
      # ==> Comm(s, t) = s^-1 t s t = s^-2 ==> G' = < s^2 > = < s >
      Zn := DerivedSubgroup(G);
      if not ( IsCyclic(Zn) and Size(Zn) = n ) then return fail; fi;
    else # n mod 2 = 0
      # G = < s, t | s^n = t^2 = 1, s^t = s^-1 >
      # ==> Comm(s, t) = s^-1 t s t = s^-2 ==> G' = < s^2 >
      G1 := DerivedSubgroup(G);
      if not ( IsCyclic(G1) and Size(G1) = n/2 ) then return fail; fi;
      # G/G1 = {1*G1, t*G1, s*G1, t*s*G1}
      T := RightTransversal(G,G1);
      i := 1;
      repeat
        Zn := ClosureGroup(G1,T[i]);
        i  := i + 1;
      until i > 4 or ( IsCyclic(Zn) and Size(Zn) = n );
      if not ( IsCyclic(Zn) and Size(Zn) = n ) then return fail; fi;
    fi; # now Zn is normal in G and Zn = < s | s^n = 1 >

    # choose t in G\Zn and check dihedral structure
    repeat t := Random(G); until not t in Zn;
    if not (Order(t) = 2 and ForAll(GeneratorsOfGroup(Zn),s->t*s*t*s=s^0))
    then return fail; fi;

    # choose generator s of Zn
    repeat s := Random(Zn); until Order(s) = n;
    return [t,s];
end );

InstallMethod( IsDihedralGroup,
               "for a group",
               true,
               [ IsGroup and IsFinite ], 0,
function(G)
    local gens;

    gens := DoComputeDihedralGenerators(G);
    if gens = fail then
        return false;
    else
        SetDihedralGenerators(G, gens);
    fi;
    return true;
end);

InstallMethod( DihedralGenerators,
               "for a group",
               [ IsGroup and IsFinite ],
function(G)
    local gens;

    gens := DoComputeDihedralGenerators(G);
    SetIsDihedralGroup(G, gens <> fail);
    if gens = fail then
        ErrorNoReturn("G is not a dihedral group");
    fi;
    return gens;
end);

#############################################################################
##
#M  IsQuaternionGroup( <G> ) . . . . . . . . . . . . . . . . . generic method
##
BindGlobal( "DoComputeGeneralisedQuaternionGenerators", function(G)
    local  N,    # size of G
           k,    # ld(N)
           n,    # N/2
           G1,   # derived subgroup of G
           Zn,   # cyclic normal subgroup of index 2 in G
           T,    # transversal of G/G1
           t, s, # canonical generators of the quaternion group
           i;    # counter

    N := Size(G);
    k := LogInt(N,2);
    if not( 2^k = N and k >= 3 ) then return fail; fi;
    n := N/2;

    # G = <t, s | s^(2^k) = 1, t^2 = s^(2^k-1), s^t = s^-1>
    # ==> Comm(s, t) = s^-1 t s t = s^-2 ==> G' = < s^2 >
    G1 := DerivedSubgroup(G);
    if not ( IsCyclic(G1) and Size(G1) = n/2 ) then return fail; fi;

    # find a normal subgroup of G of type Zn
    # G/G1 = {1*G1, t*G1, s*G1, t*s*G1}
    T := RightTransversal(G, G1);
    i := 1;
    repeat
      Zn := ClosureGroup(G1,T[i]);
      i  := i + 1;
    until i > 4 or ( IsCyclic(Zn) and Size(Zn) = n );
    if not ( IsCyclic(Zn) and Size(Zn) = n ) then return fail; fi;

    # now Zn is normal in G and Zn = < s | s^n = 1 >
    # choose t in G\Zn and check quaternion structure
    repeat t := Random(G); until not t in Zn;
    if not (Order(t) = 4 and ForAll(GeneratorsOfGroup(Zn), s->s^t*s = s^0))
    then return fail; fi;

    # choose generator s of Zn
    repeat s := Random(Zn); until Order(s) = n;
    return [t,s];
end );

InstallMethod( IsGeneralisedQuaternionGroup,
               "for a group",
               true,
               [ IsGroup and IsFinite ],
               0,
function(G)
    local gens;

    gens := DoComputeGeneralisedQuaternionGenerators(G);
    if gens = fail then
        return false;
    else
        SetGeneralisedQuaternionGenerators(G, gens);
    fi;
    return true;
end);

InstallMethod( GeneralisedQuaternionGenerators,
               "for a group",
               [ IsGroup and IsFinite ],
function(G)
    local gens;

    gens := DoComputeGeneralisedQuaternionGenerators(G);
    SetIsGeneralisedQuaternionGroup(G, gens <> fail);
    if gens = fail then
        ErrorNoReturn("G is not a generalised quaternion group");
    fi;
    return gens;
end);
#############################################################################
##
#M  IsQuasiDihedralGroup( <G> ) . . . . . . . . . . . . . . .  generic method
##
InstallMethod( IsQuasiDihedralGroup,
               "generic method", true, [ IsGroup ], 0,

  function ( G )

    local  N,    # size of G
           k,    # ld(N)
           n,    # N/2
           G1,   # derived subgroup of G
           Zn,   # cyclic normal subgroup of index 2 in G
           T,    # transversal of G/G1
           t, s, # canonical generators of the quasidihedral group
           i;    # counter

    if not IsFinite(G) then TryNextMethod(); fi;

    N := Size(G);
    k := LogInt(N, 2);
    if not( 2^k = N and k >= 4 ) then return false; fi;
    n := N/2;

    # G = <t, s | s^(2^n) = t^2 = 1, s^t = s^(-1 + 2^(n-1))>.
    # ==> Comm(s, t) = s^-1 t s t = s^(-2+2^(n-1))
    # ==> G' = < s^(-2+2^(n-1)) >, |G'| = n/2.
    G1 := DerivedSubgroup(G);
    if not ( IsCyclic(G1) and Size(G1) = n/2 ) then return false; fi;

    # find a normal subgroup of G of type Zn
    # G/G1 = {1*G1, t*G1, s*G1, t*s*G1}
    T := RightTransversal(G, G1);
    i := 1;
    repeat
      Zn := ClosureGroup(G1,T[i]);
      i  := i + 1;
    until i > 4 or ( IsCyclic(Zn) and Size(Zn) = n );
    if not ( IsCyclic(Zn) and Size(Zn) = n ) then return false; fi;

    # now Zn is normal in G and Zn = < s | s^n = 1 >
    # now remain only the possibilities for the structure:
    #   dihedral, quaternion, quasidihedral
    repeat t := Random(G); until not t in Zn;

    # detect cases: dihedral, quaternion
    if   ForAll(GeneratorsOfGroup(Zn), s -> s^t*s = s^0)
    then return false; fi;

    # choose t in Zn of order 2
    repeat
      t := Random(G);
    until not( t in Zn and Order(t) = 2 ); # prob = 1/4

    # choose generator s of Zn
    repeat s := Random(Zn); until Order(s) = n;

    SetQuasiDihedralGenerators(G,[t,s]);
    return true;
  end );

#############################################################################
##
#M  IsAlternatingGroup( <G> ) . . . . . . . . . . . . . . . .  generic method
##
##  This method additionally sets the attribute `AlternatingDegree' in case
##  <G> is isomorphic to a natural alternating group.
##
InstallMethod( IsAlternatingGroup,
               "generic method", true, [ IsGroup ], 0,

  function ( G )

    local  n, ids, info;

    if not IsFinite(G) then TryNextMethod(); fi;

    if IsNaturalAlternatingGroup(G) then return true;fi;
    if Size(G) < 60 then
      if Size(G) = 1 then
        SetAlternatingDegree(G,0); return true;
      elif Size(G) = 3 then
        SetAlternatingDegree(G,3); return true;
      elif Size(G) = 12 and IdGroup(G) = [ 12, 3 ] then
        SetAlternatingDegree(G,4); return true;
      else return false; fi;
    fi;

    if not IsSimpleGroup(G) then return false; fi;

    info := IsomorphismTypeInfoFiniteSimpleGroup(G);
    if   info.series = "A"
    then SetAlternatingDegree(G,info.parameter); return true;
    else return false; fi;
  end );

#############################################################################
##
#M  AlternatingDegree( <G> ) generic method, dispatch to `IsAlternatingGroup'
##
InstallMethod( AlternatingDegree,
               "generic method, dispatch to `IsAlternatingGroup'",
               true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if IsNaturalAlternatingGroup(G) then return DegreeAction(G); fi;
    if not IsAlternatingGroup(G) then return fail; fi;
    if HasAlternatingDegree(G) then return AlternatingDegree(G); fi;

    if Size(G) = 1 then return 0;
    elif Size(G) = 3 then return 3;
    elif Size(G) = 12 then return 4;
    else return IsomorphismTypeInfoFiniteSimpleGroup(G).parameter;
    fi;
  end );

#############################################################################
##
#M  IsNaturalAlternatingGroup( <G> ) . . . . . . .  for non-permutation group
##
InstallOtherMethod( IsNaturalAlternatingGroup, "for non-permutation group",
                    true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsPermGroup(G) then return false; else TryNextMethod(); fi;
  end );

#############################################################################
##
#M  IsSymmetricGroup( <G> ) . . . . . . . . . . . . . . . . .  generic method
##
##  This method additionally sets the attribute `SymmetricDegree' in case
##  <G> is isomorphic to a natural symmetric group.
##
InstallMethod( IsSymmetricGroup,
               "generic method", true, [ IsGroup ], 0,

  function ( G )

    local  G1;

    if IsNaturalSymmetricGroup(G) then return true;fi;
    if not IsFinite(G) then TryNextMethod(); fi;

    # special treatment of small cases
    if Size(G)<=2 then SetSymmetricDegree(G,Size(G)); return true;
    elif Size(G)=6 and not IsAbelian(G) then
      SetSymmetricDegree(G,3);
      return true;
    fi;

    G1 := DerivedSubgroup(G);
    if   not (IsAlternatingGroup(G1) and Index(G,G1) = 2)
      # this requires deg>=4
      or not IsTrivial(Centralizer(G,G1))
      or Size(G) = 720 and IdGroup(G) <> [ 720, 763 ]
    then return false; fi;
    SetSymmetricDegree(G,AlternatingDegree(G1));
    return true;
  end );

#############################################################################
##
#M  IsNaturalSymmetricGroup( <G> ) . . . . . . . .  for non-permutation group
##
InstallOtherMethod( IsNaturalSymmetricGroup, "for non-permutation group",
                    true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsPermGroup(G) then return false; else TryNextMethod(); fi;
  end );

#############################################################################
##
#M  SymmetricDegree( <G> ) . . generic method, dispatch to `IsSymmetricGroup'
##
InstallMethod( SymmetricDegree,
               "generic method, dispatch to `IsSymmetricGroup'",
               true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if IsNaturalSymmetricGroup(G) then return DegreeAction(G); fi;
    if not IsSymmetricGroup(G) then return fail; fi;
    # calling IsSymmetricGroup may have computed the SymmetricDegree
    if HasSymmetricDegree(G) then return SymmetricDegree(G); fi;

    # special treatment of small cases
    if Size(G)<=2 then
      return Size(G);
    elif Size(G)=6 then
      return 3;
    fi;
    return AlternatingDegree(DerivedSubgroup(G));
  end );

#############################################################################
##
#F  SizeGL(  <n>, <q> )
##
InstallGlobalFunction( SizeGL,

  function ( n, q )

    local N, qn, k;

    N  := 1;
    qn := q^n;
    for k in [0..n-1] do
      N := N * (qn - q^k);
    od;
    return N;
  end );

#############################################################################
##
#F  SizeSL(  <n>, <q> )
##
InstallGlobalFunction( SizeSL,

  function ( n, q )

    local N, qn, k;

    N  := 1;
    qn := q^n;
    for k in [0..n-1] do
      N := N * (qn - q^k);
    od;
    return N/(q - 1);
  end );

#############################################################################
##
#F  SizePSL(  <n>, <q> )
##
InstallGlobalFunction( SizePSL,

  function ( n, q )

    local N, qn, k;

    N  := 1;
    qn := q^n;
    for k in [0..n-1] do
      N := N * (qn - q^k);
    od;
    return N/((q - 1)*(Gcd(n, q - 1)));
  end );

#############################################################################
##
#F  LinearGroupParameters(  <N>  )
##
InstallGlobalFunction( LinearGroupParameters,

  function ( N )

    local  npeGL,      # list of possible [n, p, e] for a GL
           npeSL,      # list of possible [n, p, e] for a SL
           npePSL,     # list of possible [n, p, e] for a PSL
           n, p, e,    # N = Size(GL(n, p^e))
           pe, p2, ep, # p^ep is maximal prime power divisor of N
           e2,         # a divisor of ep
           x, r, G;    # temporaries

    if not IsPosInt(N) then Error("<N> must be positive integer"); fi;

    # Formeln:
    # |GL(n, q)|  = Product(q^n - q^k : k in [0..n-1])
    # |SL(n, q)|  = |GL(n, q)| / (q - 1)
    # |PSL(n, q)| = |SL(n, q)| / gcd(n, q - 1)
    #   mit q = p^e f"ur p prim, e >= 1, n >= 1.

    # Betrachte N = |GL(n,q)|. Dann gilt f"ur n >= 2
    #   (1) nu_p(N) = e * Binomial(n,2) und
    #   (2) (q - 1)^n teilt N.
    npeGL := [ ]; npeSL := [ ]; npePSL := [ ];
    if N = 1 then
      return rec( npeGL := npeGL, npeSL := npeSL, npePSL := npePSL );
    fi;
    for pe in Collected(Factors(N)) do
      p  := pe[1];
      ep := pe[2];

      # find e, n such that (1) e*Binomial(n,2) = ep
      for e in DivisorsInt(ep) do

        # find n such that Binomial(n, 2) = ep/e
        # <==> 8 ep/e + 1 = (2 n - 1)^2
        x := 8*ep/e + 1;
        r := RootInt(x, 2);
        if r^2 = x then
          n := (r + 1)/2;

          # decide it
          G := SizeGL(n, p^e);
          if N = G then Add(npeGL,[n, p, e]); fi;
          if N = G/(p^e - 1) then Add(npeSL, [n, p, e]); fi;
          if N = G/((p^e - 1)*GcdInt(p^e - 1, n)) then
            Add(npePSL, [n, p, e]);
          fi;
        fi;
      od;
    od;
    return rec( npeGL := npeGL, npeSL := npeSL, npePSL := npePSL );
  end );

#############################################################################
##
#M  IsPSL( <G> )
##
InstallMethod( IsPSL,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )

    local  npes, npe;  # list of possible PSL-parameters

    if not IsFinite(G) then TryNextMethod(); fi;

    if Size(G)>12 and not IsSimpleGroup(G) then
      return false;
    fi;

    # check if G has appropriate size
    npes := LinearGroupParameters(Size(G)).npePSL;
    if Length(npes) = 0 then return false; fi;

    # more than one npe-triple should only
    # occur in the cases |G| in [60, 168, 20160]
    if   Length(npes) > 1 and not( Size(G) in [60, 168, 20160] )
    then Error("algebraic panic! probably npe does not work"); fi;

    # set the parameters
    npe := npes[1];

    # catch the cases:
    #   PSL(2, 2) ~= S3, PSL(2, 3) ~= A4,
    # in which the PSL is not simple

    # PSL(2, 2)
    if npes[1] = [2, 2, 1] then
      if IsAbelian(G) then return false; fi;
      SetParametersOfGroupViewedAsPSL(G,npe); return true;

    # PSL(2, 3)
    elif npes[1] = [2, 3, 1] then
      if Size(DerivedSubgroup(G)) <> 4 then return false; fi;
      SetParametersOfGroupViewedAsPSL(G,npe); return true;

   # PSL(3, 4) / PSL(4, 2)
    elif npes = [ [ 4, 2, 1 ], [ 3, 2, 2 ] ] then
      if   IdGroup(SylowSubgroup(G,2)) = [64,138] then npe := npes[1];
      elif IdGroup(SylowSubgroup(G,2)) = [64,242] then npe := npes[2]; fi;
      SetParametersOfGroupViewedAsPSL(G,npe); return true;

    # other cases
    else
      if not IsSimpleGroup(G) then return false; fi;
      SetParametersOfGroupViewedAsPSL(G,npe); return true;
    fi;
  end );

#############################################################################
##
#M  PSLDegree( <G> ) . . . . . . . . . . . . generic method for finite groups
##
InstallMethod( PSLDegree,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsPSL(G) then return fail; fi;
    return ParametersOfGroupViewedAsPSL(G)[1];
  end );

#############################################################################
##
#M  PSLUnderlyingField( <G> ) . . . . . . .  generic method for finite groups
##
InstallMethod( PSLUnderlyingField,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsPSL(G) then return fail; fi;
    return GF(ParametersOfGroupViewedAsPSL(G)[2]^ParametersOfGroupViewedAsPSL(G)[3]);
  end );

#############################################################################
##
#M  IsSL( <G> ) . . . . . . . . . . . . . .  generic method for finite groups
##
InstallMethod( IsSL,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )

    local  npes,  # list of possible SL-parameters
           C;     # centre of G

    if not IsFinite(G) then TryNextMethod(); fi;

    # check if G has appropriate size
    npes := LinearGroupParameters(Size(G)).npeSL;
    if Length(npes) = 0 then return false; fi;

    # more than one npe-triple should never occur
    if Length(npes) > 1 then
      Error("algebraic panic! this should not occur");
    fi;
    npes := npes[1];

    # catch the cases:
    #   SL(2, 2) ~= S3, SL(2, 3)
    # in which the corresponding FactorGroup PSL is not simple

    # SL(2, 2)
    if npes = [2, 2, 1] then
      if IsAbelian(G) then return false; fi;
      SetParametersOfGroupViewedAsSL(G,npes); return true;

    # SL(2, 3)
    elif npes = [2, 3, 1] then
      if Size(DerivedSubgroup(G)) <> 8 then return false; fi;
      SetParametersOfGroupViewedAsSL(G,npes); return true;

    # other cases, in which the contained PSL is simple
    else

      # calculate the centre C of G, which should have the
      # size gcd(n, p^e - 1), and if so, check if G/C (which
      # should be the corresponding PSL) is simple
      C := Centre(G);
      if   Size(C) <> Gcd(npes[1],npes[2]^npes[3] - 1)
        or not IsSimpleGroup(G/C)
        or Size(G)/2 in List(NormalSubgroups(G),Size)
      then return false; fi;
     if   IsomorphismGroups(G,SL(npes[1],npes[2]^npes[3])) = fail
     then return false; fi;
     SetParametersOfGroupViewedAsSL(G,npes); return true;
    fi;
  end );

#############################################################################
##
#M  SLDegree( <G> ) . . . . . . . . . . . .  generic method for finite groups
##
InstallMethod( SLDegree,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsSL(G) then return fail; fi;
    if   HasIsNaturalSL(G) and IsNaturalSL(G)
    then return DimensionOfMatrixGroup(G); fi;
    return ParametersOfGroupViewedAsSL(G)[1];
  end );

#############################################################################
##
#M  SLUnderlyingField( <G> ) . . . . . . . . generic method for finite groups
##
InstallMethod( SLUnderlyingField,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsSL(G) then return fail; fi;
    if   HasIsNaturalSL(G) and IsNaturalSL(G)
    then return FieldOfMatrixGroup(G); fi;
    return GF(ParametersOfGroupViewedAsSL(G)[2]^ParametersOfGroupViewedAsSL(G)[3]);
  end );

#############################################################################
##
#M  IsGL( <G> )
##
InstallMethod( IsGL,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )

    local  npes,  # list of possible GL-parameters
           G1,    # derived subgroup of G
           C1;    # centre of G1

    if not IsFinite(G) then TryNextMethod(); fi;

    # check if G has appropriate size
    npes := LinearGroupParameters(Size(G)).npeGL;
    if Length(npes) = 0 then return false; fi;

    # more than one npe-triple should never occur
    if Length(npes) > 1 then
      Error("algebraic panic! this should not occur");
    fi;
    npes := npes[1];

    # catch the cases:
    #   GL(2, 2) ~= S3, GL(2, 3)
    # in which the contained group PSL is not simple

    # GL(2, 2)
    if npes = [2, 2, 1] then
      if IsAbelian(G) then return false; fi;
      SetParametersOfGroupViewedAsGL(G,npes); return true;

    # GL(2, 3)
    elif npes = [2, 3, 1] then
      if IdGroup(G) <> [48,29] then return false; fi;
      SetParametersOfGroupViewedAsGL(G,npes); return true;

    # other cases, in which contained PSL is simple
    else

      # calculate the derived subgroup which should be the
      # corresponding SL of index p^e - 1
      G1 := DerivedSubgroup(G);
      if Index(G, G1) <> npes[2]^npes[3] - 1 then return false; fi;

      # calculate the centre C1 of G1, which should have the
      # size gcd(n, p^e - 1), and if so, check if G1/C1
      # (which should be the corresponding PSL) is simple
      C1 := Centre(G1);
      if   Size(C1) <> Gcd(npes[1],npes[2]^npes[3] - 1)
        or not IsSimpleGroup(G1/C1)
      then return false; fi;
      if   IsomorphismGroups(G,GL(npes[1],npes[2]^npes[3])) = fail
      then return false; fi;
      SetParametersOfGroupViewedAsGL(G,npes); return true;
    fi;
  end );

#############################################################################
##
#M  GLDegree( <G> ) . . . . . . . . . . . .  generic method for finite groups
##
InstallMethod( GLDegree,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsGL(G) then return fail; fi;
    if   HasIsNaturalGL(G) and IsNaturalGL(G)
    then return DimensionOfMatrixGroup(G); fi;
    return ParametersOfGroupViewedAsGL(G)[1];
  end );

#############################################################################
##
#M  GLUnderlyingField( <G> ) . . . . . . . . generic method for finite groups
##
InstallMethod( GLUnderlyingField,
               "generic method for finite groups", true, [ IsGroup ], 0,

  function ( G )
    if not IsFinite(G) then TryNextMethod(); fi;
    if not IsGL(G) then return fail; fi;
    if   HasIsNaturalGL(G) and IsNaturalGL(G)
    then return FieldOfMatrixGroup(G); fi;
    return GF(ParametersOfGroupViewedAsGL(G)[2]^ParametersOfGroupViewedAsGL(G)[3]);
  end );

#############################################################################
##
#M  StructureDescription( <G> ) . . . . . . . . . for abelian or finite group
##
BindGlobal( "SD_insertsep", # function to join parts of name
    function ( strs, sep, brack )

      local  short, s, i;

      short := ValueOption("short") = true;

      if strs = [] then return ""; fi;
      strs := Filtered(strs,str->str<>"");
      if Length(strs) > 1 then
        for i in [1..Length(strs)] do
          if   Intersection(strs[i],brack) <> ""
          then strs[i] := Concatenation("(",strs[i],")"); fi;
        od;
      fi;
      s := strs[1];
      for i in [2..Length(strs)] do
        s := Concatenation(s,sep,strs[i]);
      od;
      if short then RemoveCharacters(s," "); fi;
      return s;
    end);

BindGlobal( "SD_cyclic",
    function ( n )
      if n = 0 or n = infinity then
        return "Z";
      fi;
      return Concatenation("C",String(n));
    end);

BindGlobal( "SD_cycsaspowers", # function to write C2 x C2 x C2 as 2^3, etc.
    function ( name, cycsizes )

      local  short, g, d, k, j, n;

      short := ValueOption("short") = true;
      if not short then return name; fi;
      RemoveCharacters(name," ");
        cycsizes := Collected(cycsizes);
        for n in cycsizes do
          d := n[1]; k := n[2];
          g := SD_cyclic(d);
          if d = 0 then
            d := "Z";
          else
            d := String(d);
          fi;
          if k > 1 then
            for j in Reversed([2..k]) do
              name := ReplacedString(name,SD_insertsep(List([1..j],i->g),"x",""),
                        Concatenation(d,"^",String(j)));
            od;
          fi;
        od;
      RemoveCharacters(name,"C");
      return name;
    end);

BindGlobal( "StructureDescriptionForAbelianGroups", # for abelian groups

  function ( G )

    local  cycsizes;     # sizes of cyclic factors of G

    # special case trivial group
    if IsTrivial(G) then return "1"; fi;

    # special case abelian group
    cycsizes := AbelianInvariants(G);
    cycsizes := Reversed(ElementaryDivisorsMat(DiagonalMat(cycsizes)));
    cycsizes := Filtered(cycsizes,n->n<>1);
    return SD_cycsaspowers(SD_insertsep(List(cycsizes, SD_cyclic),
                                        " x ",""), cycsizes);
  end );

BindGlobal( "StructureDescriptionForFiniteSimpleGroups", # for simple groups

  function ( G )

    local  name,         # buffer for computed name
           series,       # series of simple groups
           parameter;    # parameters of G in series

    # special case abelian group
    if IsAbelian(G) then return StructureDescriptionForAbelianGroups(G); fi;

    # special case alternating group
    if   IsAlternatingGroup(G)
    then return Concatenation("A",String(AlternatingDegree(G))); fi;

    # special case PSL
    if IsPSL(G) then
      return Concatenation("PSL(",String(PSLDegree(G)),",",
                                  String(Size(PSLUnderlyingField(G))),")");
    fi;

    name := SplitString(IsomorphismTypeInfoFiniteSimpleGroup(G).name," ");
    name := name[1];
    if Position(name,',') = fail then RemoveCharacters(name,"()"); else
      series    := IsomorphismTypeInfoFiniteSimpleGroup(G).series;
      parameter := IsomorphismTypeInfoFiniteSimpleGroup(G).parameter;
      if   series = "2A" then
        name := Concatenation("PSU(",String(parameter[1]+1),",",
                                     String(parameter[2]),")");
      elif series = "B" then
        name := Concatenation("O(",String(2*parameter[1]+1),",",
                                   String(parameter[2]),")");
      elif series = "2B" then
        name := Concatenation("Sz(",String(parameter),")");
      elif series = "C" then
        name := Concatenation("PSp(",String(2*parameter[1]),",",
                                     String(parameter[2]),")");
      elif series = "D" then
        name := Concatenation("O+(",String(2*parameter[1]),",",
                                    String(parameter[2]),")");
      elif series = "2D" then
        name := Concatenation("O-(",String(2*parameter[1]),",",
                                    String(parameter[2]),")");
      elif series = "3D" then
        name := Concatenation("3D(4,",String(parameter),")");
      elif series in ["2F","2G"] and parameter > 2 then
        name := Concatenation("Ree(",String(parameter),")");
      fi;
    fi;
    return name;
  end );

BindGlobal( "StructureDescriptionForFiniteGroups", # for finite groups

  function ( G )

    local  G1,           # the group G reconstructed; result
           Hs,           # split factors of G
           Gs,           # factors of G
           cyclics,      # cyclic factors of G
           cycsizes,     # sizes of cyclic factors of G
           noncyclics,   # noncyclic factors of G
           cycname,      # part of name corresponding to cyclics
           noncycname,   # part of name corresponding to noncyclics
           name,         # buffer for computed name
           cname,        # name for centre of G
           dname,        # name for derived subgroup of G
           NH, H, N, N1, # semidirect factors of G
           NHs,          # [N, H] decompositions
           NHname,       # name of NH
           NHs1,         # NH's with preferred N and H
           NHs1Names,    # names of products in NHs1
           len,          # maximal number of direct factors
           g,            # an element of G
           id,           # id of G in the library of perfect groups
           short,        # short / long output format
           nice,         # nice output (slower)
           i,j,          # counters
           primes,       # prime divisors of Size(G)
           d,            # divisor of Size(G)
           k,            # maximal power of d in Size(G)
           pi;           # subset of primes

    short := ValueOption("short") = true;
    nice := ValueOption("nice") = true;

    # fetch name from precomputed list, if available
    if ValueOption("recompute") <> true and Size(G) <= 2000 then
      if IsBound(NAMES_OF_SMALL_GROUPS[Size(G)]) then
        i := IdGroup(G)[2];
        if IsBound(NAMES_OF_SMALL_GROUPS[Size(G)][i]) then
          name := ShallowCopy(NAMES_OF_SMALL_GROUPS[Size(G)][i]);
          cycsizes := [];
          if short then
          # DivisorsInt is rather slow, but we only call it for small groups
            for d in Reversed(DivisorsInt(Size(G))) do
              if d >1 then
                k := LogInt(Size(G), d);
                if k>1 then
                  for j in [1..k] do
                    Add(cycsizes, d);
                  od;
                fi;
              fi;
            od;
          fi;
          return SD_cycsaspowers(name, cycsizes);
        fi;
      fi;
    fi;

    # special case trivial group
    if IsTrivial(G) then return "1"; fi;

    # special case abelian group
    if IsAbelian(G) then return StructureDescriptionForAbelianGroups(G); fi;

    # special case alternating group
    if   IsAlternatingGroup(G)
    then return Concatenation("A",String(AlternatingDegree(G))); fi;

    # special case symmetric group
    if   IsSymmetricGroup(G)
    then return Concatenation("S",String(SymmetricDegree(G))); fi;

    # special case dihedral group
    if   IsDihedralGroup(G) and Size(G) > 6
    then return Concatenation("D",String(Size(G))); fi;

    # special case quaternion group
    if   IsQuaternionGroup(G)
    then return Concatenation("Q",String(Size(G))); fi;

    # special case quasidihedral group
    if   IsQuasiDihedralGroup(G)
    then return Concatenation("QD",String(Size(G))); fi;

    # special case PSL
    if IsPSL(G) then
      return Concatenation("PSL(",String(PSLDegree(G)),",",
                                  String(Size(PSLUnderlyingField(G))),")");
    fi;

    # special case SL
    if IsSL(G) then
      return Concatenation("SL(",String(SLDegree(G)),",",
                                 String(Size(SLUnderlyingField(G))),")");
    fi;

    # special case GL
    if IsGL(G) then
      return Concatenation("GL(",String(GLDegree(G)),",",
                                 String(Size(GLUnderlyingField(G))),")");
    fi;

    # other simple group
    if IsSimpleGroup(G) then
      return StructureDescriptionForFiniteSimpleGroups(G);
    fi;

    # direct product decomposition
    Gs := DirectFactorsOfGroup( G );
    if Length(Gs) > 1 then

      # decompose the factors
      Hs := List(Gs,StructureDescription);

      # construct
      cyclics  := Filtered(Gs,IsCyclic);
      if cyclics <> [] then
        cycsizes := ElementaryDivisorsMat(DiagonalMat(List(cyclics,Size)));
        cycsizes := Filtered(cycsizes,n->n<>1);
        cycname  := SD_cycsaspowers(SD_insertsep(List(cycsizes, SD_cyclic),
                                    " x ",":."), cycsizes);
      else cycname := ""; fi;
      noncyclics := Difference(Gs,cyclics);
      noncycname := SD_insertsep(List(noncyclics,StructureDescription),
                                 " x ",":.");

      return SD_insertsep([cycname,noncycname]," x ",":.");
    fi;

    # semidirect product decomposition
    if not nice then
      NH := SemidirectDecompositionsOfFiniteGroup( G, "str" );
      if NH <> fail then
        H := NH[2]; N := NH[1];
        return SD_insertsep([StructureDescription(N),
                             StructureDescription(H)]," : ","x:.");
      fi;
    else
      NHs := [ ];
      for NH in SemidirectDecompositions( G ) do
        if not IsTrivial( NH[1] ) and not IsTrivial( NH[2] ) then
          AddSetIfCanEasilySortElements(NHs, [ NH[1], NH[2] ]);
        fi;
      od;
      if Length(NHs) > 0 then

        # prefer abelian H; abelian N; many direct factors in N; phi injective
        NHs1 := Filtered(NHs, NH -> IsAbelian(NH[2]));
        if Length(NHs1) > 0 then NHs := NHs1; fi;
        NHs1 := Filtered(NHs, NH -> IsAbelian(NH[1]));
        if Length(NHs1) > 0 then
          NHs := NHs1;
          len := Maximum( List(NHs, NH -> Length(AbelianInvariants(NH[1]))) );
          NHs := Filtered(NHs, NH -> Length(AbelianInvariants(NH[1])) = len);
        fi;
        NHs1 := Filtered(NHs, NH -> Length(DirectFactorsOfGroup(NH[1])) > 1);
        if Length(NHs1) > 0 then
          NHs := NHs1;
          len := Maximum(List(NHs,NH -> Length(DirectFactorsOfGroup(NH[1]))));
          NHs := Filtered(NHs,NH -> Length(DirectFactorsOfGroup(NH[1]))=len);
        fi;
        NHs1 := Filtered(NHs, NH -> IsTrivial(Centralizer(NH[2],NH[1])));
        if Length(NHs1) > 0 then NHs := NHs1; fi;
        if Length(NHs) > 1 then

          # decompose the pairs [N, H] and remove isomorphic copies
          NHs1      := [];
          NHs1Names := [];
          for NH in NHs do
            NHname := SD_insertsep([StructureDescription(NH[1]),
                                    StructureDescription(NH[2])],
                                                                " : ","x:.");
            if not NHname in NHs1Names then
              Add(NHs1,      NH);
              Add(NHs1Names, NHname);
            fi;
          od;
          NHs := NHs1;

          if Length(NHs) > 1 then
            Info(InfoWarning,2,"Warning! Non-unique semidirect product:");
            Info(InfoWarning,2,List(NHs,NH -> List(NH,StructureDescription)));
          fi;
        fi;

        H := NHs[1][2]; N := NHs[1][1];

        return SD_insertsep([StructureDescription(N:nice),
                             StructureDescription(H:nice)]," : ","x:.");
      fi;
    fi;

    # non-splitting, non-simple group
    if not IsTrivial(Centre(G)) then
      cname := SD_insertsep([StructureDescription(Centre(G)),
                             StructureDescription(G/Centre(G))]," . ","x:.");
    fi;
    if not IsPerfectGroup(G) then
      dname := SD_insertsep([StructureDescription(DerivedSubgroup(G)),
                             StructureDescription(G/DerivedSubgroup(G))],
                            " . ","x:.");
    fi;
    if   IsBound(cname) and IsBound(dname) and cname <> dname
    then return Concatenation(cname," = ",dname);
    elif IsBound(cname) then return cname;
    elif IsBound(dname) then return dname;
    elif not IsTrivial(FrattiniSubgroup(G))
    then return SD_insertsep([StructureDescription(FrattiniSubgroup(G)),
                              StructureDescription(G/FrattiniSubgroup(G))],
                             " . ","x:.");
    elif     IsPosInt(NrPerfectGroups(Size(G)))
         and not Size(G) in [ 86016, 368640, 737280 ]
    # this does not happen for Size(G)<10^6
    then
         id := PerfectIdentification(G);
         return Concatenation("PerfectGroup(",String(id[1]),",",
                                              String(id[2]),")");
    else return Concatenation("<a non-simple perfect group of order ",
                Size(G)," with trivial centre and trivial Frattini ",
                "subgroup, which cannot be written as a direct or ",
                "semidirect product of smaller groups>");
    fi;
  end );

InstallMethod( StructureDescription, "for abelian groups",
               true, [ IsGroup and IsAbelian ], 0,
               StructureDescriptionForAbelianGroups );

RedispatchOnCondition( StructureDescription, true,
    [ IsGroup ],
    [ IsAbelian ], 0);

InstallMethod( StructureDescription, "for finite simple groups",
               true, [ IsGroup and IsFinite and IsSimpleGroup ], 0,
               StructureDescriptionForFiniteSimpleGroups );

InstallMethod( StructureDescription, "for finite groups",
               true, [ IsGroup and IsFinite ], 0,
               StructureDescriptionForFiniteGroups );

RedispatchOnCondition( StructureDescription, true,
    [ IsGroup ],
    [ IsFinite ], 0);

#############################################################################
##
#M  ViewObj( <G> ) . . . . . . . . for group with known structure description
##
InstallMethod( ViewObj,
               "for groups with known structure description",
               true, [ IsGroup and HasStructureDescription ], SUM_FLAGS,

  function ( G )
    if HasName(G) then TryNextMethod(); fi;
    Print(StructureDescription(G));
  end );
