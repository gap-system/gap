#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen, Alexander Hulpke, Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for symmetric and alternating groups
##

#############################################################################
##
#M  <perm> in <nat-alt-grp>
##
InstallMethod( \in,
    "alternating",
    true,
    [ IsPerm,
      IsNaturalAlternatingGroup ],
    0,

function( g, S )
    local   m,  l;

    if SignPerm(g)=-1 then
      return false;
    fi;
    m := MovedPoints(S);
    l := NrMovedPoints(S);

    if g = One( g )  then
        return true;
    elif l = 0  then
        return false;
    elif IsRange(m) and ( l = 1 or m[2] - m[1] = 1 )  then
        return SmallestMovedPoint(g) >= m[1]
           and LargestMovedPoint(g)  <= m[l];
    else
        return IsSubset( m, MovedPoints( [g] ) );
    fi;
end );






#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, <opr> ). . for alternating groups
##
## This method may fail if d and e are the same integer. RepresentativeAction
## catches this case first, so this may be acceptable.
##
##
InstallOtherMethod( RepresentativeActionOp, "natural alternating group",
  true, [ IsNaturalAlternatingGroup, IsObject, IsObject, IsFunction ],
  # the objects might be group elements: rank up
  {} -> 2*RankFilter(IsMultiplicativeElementWithInverse),
function ( G, d, e, opr )
local dom,dom2,sortfun,cd,ce,rep,dp,ep;
  # test for internal rep
  if HasGeneratorsOfGroup(G) and
    not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
    TryNextMethod();
  fi;
  dom:=Set(MovedPoints(G));
  if opr=OnPoints then
    if IsInt(d) and IsInt(e) then
      if d in dom and e in dom and Length(dom)>2 then
        return (d,e,First(dom,i->i<>d and i<>e));
      else
        return fail;
      fi;
    elif IsPerm(d) and IsPerm(e) and d in G and e in G then
      sortfun:=function(a,b) return Length(a)<Length(b);end;
      if Order(d)=1 then #LargestMovedPoint does not work for ().
        if Order(e)=1 then
          return ();
        else
          return fail;
        fi;
      fi;
      if CycleStructurePerm(d)<>CycleStructurePerm(e) then
        return fail;
      fi;
      dp:=d;
      ep:=e;
      cd:=ShallowCopy(Cycles(d,dom));
      ce:=ShallowCopy(Cycles(e,dom));
      Sort(cd,sortfun);
      Sort(ce,sortfun);
      rep:=MappingPermListList(Concatenation(cd),Concatenation(ce));
      if SignPerm(rep)=-1 then
        dom2:=Difference(dom,Union(Concatenation(cd),Concatenation(ce)));
        if Length(dom2)>1 then
          rep:=rep*(dom2[1],dom2[2]);
        else
          #this is more complicated
          TryNextMethod();

          # temporarily disabled, Situation is more complicated
          cd:=Filtered(cd,i->IsSubset(dom,i));
          d:=CycleStructurePerm(d);
          e:=PositionProperty([1..Length(d)],i->IsBound(d[i]) and
            # cycle structure is shifted, so this is even length
            # we need either to swap a pair of even cycles or to 3-cycle
            # odd cycles
            ((IsInt((i+1)/2) and d[i]>1) or
            (IsInt(i/2) and d[i]>2)));
          if e=fail then
            rep:=fail;
          elif IsInt((e+1)/2) then
            cd:=Filtered(cd,i->Length(i)=e+1);
            cd:=cd{[1,2]};
            rep:=MappingPermListList(Concatenation(cd),
                                         Concatenation([cd[2],cd[1]]))*rep;
          else
            cd:=Filtered(cd,i->Length(i)=e+1);
            cd:=cd{[1,2,3]};
            rep:=MappingPermListList(Concatenation(cd),
                                     Concatenation([cd[2],cd[3],cd[1]]))*rep;
          fi;
        fi;
      fi;
      if rep<>fail then
        Assert(1,dp^rep=ep);
      fi;
      return rep;
    fi;
  elif (opr=OnSets or opr=OnTuples) and (IsDuplicateFreeList(d) and
    IsDuplicateFreeList(e)) then
    if Length(d)<>Length(e) then
      return fail;
    fi;
    if IsSubset(dom,Set(d)) and IsSubset(dom,Set(e)) then
      rep:=MappingPermListList(d,e);
      if SignPerm(rep)=-1 then
        cd:=Difference(dom,e);
        if Length(cd)>1 then
          rep:=rep*(cd[1],cd[2]);
        elif opr=OnSets then
          if Length(d)>1 then
            rep:=(d[1],d[2])*rep;
          else
            rep:=fail; # set Length <2, maximal 1 further point in dom,imposs.
          fi;
        else # opr=OnTuples, not enough points left
          rep:=fail;
        fi;
      fi;
      return rep;
    fi;
  fi;
  TryNextMethod();
end);


InstallMethod( SylowSubgroupOp,
    "alternating",
    true,
    [ IsNaturalAlternatingGroup, IsPosInt ], 0,
function ( G, p )
    local   S,          # <p>-Sylow subgroup of <G>, result
            sgs,        # strong generating set of <G>
            q,          # power of <p>
            i,          # loop variable
            trf,
            mov,
            deg;

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;
    mov:=MovedPoints(G);
    deg:=Length(mov);
    # make the strong generating set
    sgs := [];
    for i  in [3..deg]  do
        q := p;
        if p = 2  and i mod 2 = 0  then
            Add( sgs, (mov[1],mov[2])(mov[i-1],mov[i]) );
            q := q * p;
        fi;
        trf:=MappingPermListList([1..deg],mov); # translating perm
        while i mod q = 0  do
            Add( sgs, PermList( Concatenation(
                        [1..i-q], [i-q+1+q/p..i], [i-q+1..i-q+q/p] ) )^trf );
            q := q * p;
        od;
    od;

    # make the Sylow subgroup
    S := SubgroupNC( G, sgs );
    SetSize(S,p^Length(sgs));


    # add the stabilizer chain
    #MakeStabChainStrongGenerators( S, Reversed([1..G.degree]), sgs );

    if Size( S ) > 1 then
        SetIsPGroup( S, true );
        SetPrimePGroup( S, p );
        SetHallSubgroup(G, [p], S);
    fi;

    # return the Sylow subgroup
    return S;
end);


InstallMethod( ConjugacyClasses,
    "alternating",
    true,
    [ IsNaturalAlternatingGroup ], 0,
function ( G )
    local   classes,    # conjugacy classes of <G>, result
            prt,        # partition of <G>
            sum,        # partial sum of the entries in <prt>
            rep,        # representative of a conjugacy class of <G>
            mov,deg,trf, # degree, moved points, transfer
            i;          # loop variable

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;
    mov:=MovedPoints(G);
    deg:=Length(mov);
    if deg=0 then
      TryNextMethod();
    fi;
    trf:=MappingPermListList([1..deg],mov);
    # loop over the partitions
    classes := [];
    for prt  in Partitions( deg )  do

        # only take those partitions that lie in the alternating group
        if Number( prt, i -> i mod 2 = 0 ) mod 2 = 0  then

            # compute the representative of the conjugacy class
            rep := [2..deg];
            sum := 1;
            for i  in prt  do
                rep[sum+i-1] := sum;
                sum := sum + i;
            od;
            rep := PermList( rep )^trf;

            # add the new class to the list of classes
            Add( classes, ConjugacyClass( G, rep ) );

            # some classes split in the alternating group
            if      ForAll( prt, i -> i mod 2 = 1 )
                and Length( prt ) = Length( Set( prt ) )
            then
                Add( classes, ConjugacyClass(G,rep^(mov[deg-1],mov[deg])) );
            fi;

        fi;

    od;

    # return the classes
    return classes;
end);

BindGlobal("CheapIsomSymAlt",function(a,b)
local hom;
  if IsPermGroup(a) then
    hom:=SmallerDegreePermutationRepresentation(a:cheap);
    if Image(hom)=b then return hom;
    elif NrMovedPoints(Range(hom))<NrMovedPoints(a) then
      return hom*IsomorphismGroups(Image(hom),b);
    fi;
  fi;
  return IsomorphismGroups(a,b);
end);

InstallMethod( IsomorphismFpGroup, "alternating group, supply name", true,
    [ IsAlternatingGroup ],
    40, # override `IsSimple...' method
function(G)
  if Size(G)=1 then TryNextMethod();fi;
  return IsomorphismFpGroup(G,
           Concatenation("A_",String(AlternatingDegree(G)),".") );
end);

InstallOtherMethod( IsomorphismFpGroup, "alternating perm group,name",
    true,
    [ IsAlternatingGroup and IsPermGroup, IsString ],
    35, # override `IsSimpleGroup' method
function ( G,str )
local   F,      # free group
        imgs,
        premap, # map to apply first
        hom,    # bijection
        mov,deg,# moved pts, degree
        m,      #[n/2]
        relators,
        r,s,    # generators
        d,      # subset of pts
        p,      # permutation
        j;      # loop variables

    # test for internal rep
    if (HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep)) or Size(G)=1 then
      TryNextMethod();
    fi;

    #are we natural?
    if not IsNaturalAlternatingGroup(G) then
      F:=G;
      G:=AlternatingGroup(AlternatingDegree(G));
      premap:=CheapIsomSymAlt(F,G);
    else
      premap:=fail;
    fi;

    mov:=MovedPoints(G);
    deg:=Length(mov);

    #special case for degree 3, cyclic
    if deg=3 then
      F := FreeGroup( 1, str);
      imgs:=[(mov[1],mov[2],mov[3])];
      relators:=[F.1^3];

    else
      # create the finitely presented group with <G>.degree-1 generators
      F := FreeGroup( 2, str);

      # add the relations according to the presentation by Coxeter
      # (see Coxeter/Moser)
      r:=F.1;
      s:=F.2;
      if IsOddInt(deg) then
        m:=(deg-1)/2;
        relators:=[r^deg/s^deg,r^deg/(r*s)^m];
        for j in [2..m] do
          Add(relators,(r^-j*s^j)^2);
        od;
        #(1,2,3,..deg) and (1,3,2,4,5,..deg)
        p:=MappingPermListList(mov,Concatenation(mov{[2..deg]},[mov[1]]));
        imgs:=[p,p^(mov[2],mov[3])];
      else
        m:=deg/2;
        relators:=[r^(deg-1)/s^(deg-1),r^(deg-1)/(r*s)^m];
        for j in [1..m-1] do
          Add(relators,(r^-j*s^-1*r*s^j)^2);
        od;
        # (1,2,3,4..,deg-2,deg),(1,2,3,4,deg-3,deg-1,deg);
        d:=Concatenation(mov{[1..deg-2]},[mov[deg]]);
        p:=MappingPermListList(d,Concatenation(d{[2..deg-1]},[d[1]]));
        imgs:=[p];
        d:=Concatenation(mov{[1..deg-3]},mov{[deg-1,deg]});
        p:=MappingPermListList(d,Concatenation(d{[2..deg-1]},[d[1]]));
        Add(imgs,p);
      fi;
    fi;

    F:=F/relators;

    SetSize(F,Size(G));
    UseIsomorphismRelation( G, F );

    # return the isomorphism to the finitely presented group
    hom:= GroupHomomorphismByImagesNC(G,F,imgs,GeneratorsOfGroup(F));
    if premap<>fail then hom:=premap*hom;fi;
    SetIsBijective( hom, true );
    ProcessEpimorphismToNewFpGroup(hom);
    return hom;
end);

# Presentation that gives nicer rewriting (from Derek Holt)
# A_n = < x_1, ..., x_{n-2} | x_1^3, x_i^2 (i > 1),
#                           (x_i x_{i+1})^3 (1 <= i <= n-3)
#                           (x_i x_j)^2  (1 <= i, i+1 < j, j <= n-2) >.
InstallMethod(IsomorphismFpGroupForRewriting,"alternating",
  [IsNaturalAlternatingGroup],0,
function ( G )
local   F,      # free group
        gens,   #generators of F
        imgs,
        hom,    # bijection
        mov,deg,
        relators,
        i, j;       # loop variables

  if Size(G)=1 then TryNextMethod();fi;
  mov:=MovedPoints(G);
  deg:=Length(mov);

  # create the finitely presented group with <G>.degree-1 generators
  F := FreeGroup( deg-2, Concatenation("A_",String(deg),".") );
  gens:=GeneratorsOfGroup(F);

  relators := [];
  Add(relators,gens[1]^3);
  for i in [2..deg-2]  do
    Add(relators,gens[i]^2);
  od;
  for i  in [1..deg-3]  do
    Add(relators,(gens[i]*gens[i+1])^3);
    for j in [i+2..deg-2]  do
          Add(relators,(gens[i]*gens[j])^2);
    od;
  od;

  F:=F/relators;

  SetSize(F,Size(G));
  UseIsomorphismRelation( G, F );

  # compute the bijection
  imgs:=[];
  Add(imgs,(mov[1],mov[2],mov[3]));
  for i in [3..deg-1] do
    Add(imgs,(mov[1],mov[2])(mov[i],mov[i+1]));
  od;

  # return the isomorphism to the finitely presented group
  hom:= GroupHomomorphismByImagesNC(G,F,imgs,GeneratorsOfGroup(F));
  SetIsBijective( hom, true );
  return hom;
end);

################################################
# h has socle A_n^{l1}, acting on l1-tuples of l2-sets
#output is a subset of the permutation domain, consisting
#of tuples which agree in l1-1 coordinates and intersect in l2-1 points
#in the last coordinate
BindGlobal( "PermNatAnTestDetect", function(h,n,l1,l2)
local schreiertree, cosetrepresentative, flag, schtree, stab, k, p, j,
      cosetrep, orbits, neworb, int, set, count, flag2, neworb2, o, i,dom,pt1;

  #permutation group h, on m points, Schreier tree with root k
  schreiertree:=function(h,m,k)
  local mark, gens, inv, schtree, i, j, list;

    mark:=BlistList([1..m],[k]);
    gens:=GeneratorsOfGroup(h);
    inv:=List(gens,x->x^(-1));
    list:=[k];
    schtree:=[ ];
    schtree[k]:=();
    for i in list do
      for j in [1..Length(gens)] do
        if mark[i^(inv[j])]=false then
            Add(list,i^(inv[j]));
            mark[i^(inv[j])]:=true;
            schtree[i^(inv[j])]:=gens[j];
        fi;
      od;
    od;
    return schtree;
  end;

  cosetrepresentative:=function(schtree,k,j)
  local cosetrep;

    cosetrep:=();
    repeat
      cosetrep:=cosetrep*schtree[j];
      j:=j^schtree[j];
    until j=k;
    return cosetrep;
  end;

  flag:=true;
  # create a domain of moved points, at least (n choose l2)^l1 long
  dom:=Set(MovedPoints(h));
  k:=Binomial(n,l2)^l1;
  while Length(dom)<k do
    AddSet(dom,dom[Length(dom)]+1);
  od;

  pt1:=dom[1];
  schtree:= schreiertree(h,dom[Length(dom)],pt1);

  # group generated by ten random elements of the stabilizer of k in h
  stab:=[];
  k:=pt1;
  for i in [1..10] do
    p:=PseudoRandom(h);
    j:=k^p;
    cosetrep:=cosetrepresentative(schtree,k,j);
    Add(stab,p*cosetrep);
  od;
  stab:=Group(stab);

  orbits:=Orbits(stab,dom{[1..Binomial(n,l2)^l1]},OnPoints);
  k:=Position(List(orbits, Length),l1*l2*(n-l2));
  if k = fail then
    flag:= false;
  else
    j:=orbits[k][1];
    cosetrep:=cosetrepresentative(schtree,1,j);
    cosetrep:=cosetrep^(-1);
    neworb:=List(orbits[k],x->x^cosetrep);
    int:=Intersection(orbits[k],neworb);
    Add(int,orbits[k][1]);
    Add(int,1);
    if Length(int) <> n then
        flag:=false;
    else
      # int contains l2-1 extra l2-sets
      if l2=1 then
        set:=Set(int);
      else
        count:=1;
        flag2:=false;
        repeat
          j:=int[count];
          cosetrep:=cosetrepresentative(schtree,pt1,j);
          cosetrep:=cosetrep^(-1);
          neworb2:=List(orbits[k],x->x^cosetrep);
          if Length(Intersection(int,neworb2))=n-l2 then
            set:= Union(Intersection(int,neworb2),[int[count]]);
            flag2:=true;
          else
            count:=count+1;
          fi;
        until flag2 or count>l2;
        if not flag2 then
            flag:=false;
        fi;
      fi;
    fi;
  fi;

  if flag=true then
    o:=Orbit(h,set,OnSets);
    if Length(o) <> l1*Binomial(n,l2)^(l1-1)*Binomial(n,l2-1) then
      flag:=false;
    fi;
  fi;
  if flag=false then
    return fail;
  else
    return set;
  fi;
end );

# see Ákos Seress, Permutation group algorithms. Cambridge Tracts in
# Mathematics, 152. Section 10.2 for the background of this function.
BindGlobal("DoSnAnGiantTest",function(g,dom,kind)
local bound, n, i, p, l, pnt;
  pnt := dom[1];
  n:=Length(dom);
  # From the above reference we see that with these bounds this function
  # will fail on a symmetric group with probability < 10^-10.
  if kind=1 then
    bound:=10*LogInt(n,2);
  else
    bound:=50*LogInt(n,2);
  fi;
  i:=0;
  # We are looking for an element with a cycle of prime length > n/2
  # and < n-2. Instead of computing the complete cycle structure we just
  # look at the cycle length of one moved point (if there is a cycle as
  # desired, it will contain this point with probability > 1/2).
  repeat
    i:=i+1;
    p:=PseudoRandom(g);
    l:=CYCLE_LENGTH_PERM_INT(p,pnt);
  until (i>bound) or (l> n/2 and l<n-2 and IsPrime(l));
  if i>bound then
    return fail;
  else
    return true;
  fi;
end);

BindGlobal("PermgpContainsAn",function(g)
local dom, n, mine, root, d, k, b, m, l,lh;

  dom:=MovedPoints(g);
  n:=Length(dom);
  if not IsTransitive(g,dom) then
    return false;
  fi;

  if DoSnAnGiantTest(g,dom,1)=true then
    # we've found elements that prove the group must contain A_n.
    return true;
  fi;
  # otherwise, the group is likely (but not proven) to be different

  if not IsPrimitive(g,dom) then
    return false;
  fi;
  # so the group is primitive

  if n>10 then # otherwise the size is immediate
    # test whether its socle could be A_l^m, acting on k-tuples in product
    # action.
    mine:=Minimum(List(Collected(Factors(n)),i->i[2]));
    for m in [1..mine] do
      root:=RootInt(n,m);
      if root^m=n then
        # case k=1 -> A_root on points
        if m>1 then # k=1, m=1: then it's A_n
          d:=PermNatAnTestDetect(g,root,m,1);
          if d<>fail then
            Info(InfoGroup,3,"Detected ",root,",",m,",",1,"\n");
            return d;
          fi;
        fi;

        for l in [2..RootInt(2*root,2)+1] do
          lh:=Int(l/2)+1;
          k:=2;
          b:=Binomial(l,k);
          while b<root and k<lh do
            k:=k+1;
            b:=Binomial(l,k);
          od;
          if b=root then
            d:=PermNatAnTestDetect(g,l,m,k);
            if d<>fail then
              Info(InfoGroup,3,"Detected ",l,",",m,",",k,"\n");
              return d;
            fi;
          fi;
        od;
      fi;
    od;
  fi;

  if DoSnAnGiantTest(g,dom,2)=true then
    # we've found elements that prove the group must contain A_n.
    return true;
  fi;

  # now the socle is not a power of A_l or n is small. So the group is small
  # base enforce a stabilizer chain calculation

  return Size(g)>=Factorial(n)/2;

end);

#############################################################################
##
#M  IsNaturalAlternatingGroup( <sym> )
##

InstallMethod(IsNaturalAlternatingGroup,"knows size",true,[IsPermGroup
        and HasSize],0,
        function( g )
    local s, i, n;
    s := Size(g);
    n := NrMovedPoints(g);
    # avoid computing Factorial(n)
    for i in  [3..n] do
        if s mod i <> 0 then
            return false;
        else
            s := s/i;
        fi;
    od;
    return s = 1;
end );

InstallMethod(IsNaturalAlternatingGroup,"comprehensive",true,[IsPermGroup],0,
G -> IsTrivial(G) or
  ForAll(GeneratorsOfGroup(G),i->SignPerm(i)=1) and PermgpContainsAn(G)=true);

#############################################################################
##
#M  IsNaturalSymmetricGroup( <sym> )
##

InstallMethod(IsNaturalSymmetricGroup,"knows size",true,[IsPermGroup
        and HasSize],0,
        function( g )
    local s, i, n;
    s := Size(g);
    n := NrMovedPoints(g);
    # avoid computing Factorial(n)
    for i in  [2..n] do
        if s mod i <> 0 then
            return false;
        else
            s := s/i;
        fi;
    od;
    return true;
end );

InstallMethod(IsNaturalSymmetricGroup,"comprehensive",true,[IsPermGroup],0,
G -> IsTrivial(G) or
  ForAny(GeneratorsOfGroup(G),i->SignPerm(i)=-1) and PermgpContainsAn(G)=true);

#############################################################################
##
#M  <perm> in <nat-sym-grp>
##
InstallMethod( \in,"perm in natsymmetric group",
    true,
    [ IsPerm,
      IsNaturalSymmetricGroup ],
    0,

function( g, S )
    local   m,  l;

    m := MovedPoints(S);
    l := NrMovedPoints(S);

    if g = One( g )  then
        return true;
    elif l = 0  then
        return false;
    elif IsRange(m) and ( l = 1 or m[2] - m[1] = 1 )  then
        return SmallestMovedPoint(g) >= m[1]
           and LargestMovedPoint(g)  <= m[l];
    else
        return IsSubset( m, MovedPoints( [g] ) );
    fi;
end );

#############################################################################
##
#M  IsSubset(<nat-sym-grp>,<permgrp>
##
InstallMethod( IsSubset,"permgrp of natsymmetric group", true,
    [ IsNaturalSymmetricGroup,IsPermGroup ],
    # we need to override a method that computes the size.
    SUM_FLAGS,

function( S,G )
  return IsSubset(MovedPoints(S),MovedPoints(G));
end );


#############################################################################
##
#M  Socle( <nat-sym/alt-grp> )
##
InstallMethod( Socle,
    true, [ IsNaturalSymmetricGroup ], 0,
function(sym)
  if NrMovedPoints(sym)<=4 then
    TryNextMethod();
  else
    return AlternatingGroup(MovedPoints(sym));
  fi;
end);

InstallMethod( Socle, true, [ IsNaturalAlternatingGroup ], 0,
function(alt)
  if NrMovedPoints(alt)<=4 then
    TryNextMethod();
  else
    return alt;
  fi;
end);

#############################################################################
##
#M  Size( <nat-sym-grp> )
##
InstallMethod( Size,
    true,
    [ IsNaturalSymmetricGroup ], 0,
    sym -> Factorial( NrMovedPoints(sym) ) );

BindGlobal("FLOYDS_ALGORITHM", function(rs, deg, even)
    local  rnd, sgn, i, k, tmp;
    rnd := [1..deg];
    sgn := 1;
    for i  in [1..deg-1] do
        k := Random( rs, i, deg );
        if k <> i then
            tmp := rnd[i];
            rnd[i] := rnd[k];
            rnd[k] := tmp;
            sgn := -sgn;
        fi;
    od;
    if even and sgn = -1 then
        tmp := rnd[deg];
        rnd[deg] := rnd[deg-1];
        rnd[deg-1] := tmp;
    fi;
    return rnd;
end);



InstallMethodWithRandomSource( Random,
    "for a random source and a natural symmetric group: floyd's algorithm",
    true,
    [ IsRandomSource, IsNaturalSymmetricGroup ],
    10, # override perm group method
function ( rs, G )
    local   rnd,        # random permutation, result
            deg,
            mov;

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

    # use Floyd\'s algorithm
    mov:=MovedPoints(G);
    deg:=Length(mov);
    rnd:=FLOYDS_ALGORITHM(rs,deg,false);

    # return the permutation
    return PermList( rnd )^MappingPermListList([1..deg],mov);
end);


InstallMethodWithRandomSource( Random,
    "for a random source and a natural alternating group: floyd's algorithm",
    true,
    [ IsRandomSource, IsNaturalAlternatingGroup ],
    10, # override perm group method
function ( rs, G )
    local   rnd,        # random permutation, result
            deg,
            mov;

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

    # use Floyd\'s algorithm
    mov:=MovedPoints(G);
    deg:=Length(mov);
    rnd:=FLOYDS_ALGORITHM(rs,deg,true);

    # return the permutation
    return PermList( rnd )^MappingPermListList([1..deg],mov);
end);


#############################################################################
##
#M  Size( <nat-alt-grp> )
##
InstallMethod( Size,
    true,
        [ IsNaturalAlternatingGroup ], 0,
        function(a)
    local n;
    n := NrMovedPoints(a);
    if n <= 2 then
        return 1;
    fi;
    return Factorial( n )/2;
end);


#############################################################################
##
#M Intersection2

InstallMethod( Intersection2, [IsNaturalSymmetricGroup, IsNaturalSymmetricGroup],
        function(s1,s2)
    return SymmetricGroup(Intersection(MovedPoints(s1),MovedPoints(s2)));
end);

InstallMethod( Intersection2, [IsNaturalSymmetricGroup, IsNaturalAlternatingGroup],
        function(s1,s2)
    return AlternatingGroup(Intersection(MovedPoints(s1),MovedPoints(s2)));
end);

InstallMethod( Intersection2, [IsNaturalAlternatingGroup, IsNaturalSymmetricGroup],
        function(s1,s2)
    return AlternatingGroup(Intersection(MovedPoints(s1),MovedPoints(s2)));
end);

InstallMethod( Intersection2, [IsNaturalAlternatingGroup, IsNaturalAlternatingGroup],
        function(s1,s2)
    return AlternatingGroup(Intersection(MovedPoints(s1),MovedPoints(s2)));
end);


InstallMethod( Intersection2, [IsNaturalSymmetricGroup, IsPermGroup],
        function(s,g)
    return Stabilizer(g,Difference(MovedPoints(g),MovedPoints(s)), OnTuples);
end);

InstallMethod( Intersection2, [IsPermGroup, IsNaturalSymmetricGroup],
        function(g,s)
    return Stabilizer(g,Difference(MovedPoints(g),MovedPoints(s)), OnTuples);
end);

InstallMethod( Intersection2, [IsNaturalAlternatingGroup, IsPermGroup],
        function(s,g)
    return AlternatingSubgroup(Stabilizer(g,Difference(MovedPoints(g),MovedPoints(s)), OnTuples));
end);

InstallMethod( Intersection2, [IsPermGroup, IsNaturalAlternatingGroup],
        function(g,s)
    return AlternatingSubgroup(Stabilizer(g,Difference(MovedPoints(g),MovedPoints(s)), OnTuples));
end);


#############################################################################
##
#M DerivedSubgroup
##

InstallMethod( DerivedSubgroup, [IsNaturalSymmetricGroup],
        function(g)
    local d;
    d := AlternatingGroup(MovedPoints(g));
    d := AsSubgroup(g,d);
    SetIsNaturalAlternatingGroup(d, true);
    return d;
end);



#############################################################################
##
#M  StabilizerOp( <nat-sym-grp>, ...... )
##
BindGlobal( "SYMGP_STABILIZER", function(sym, arg...)
    local  k, act, pt, mov, stab, nat, diff, int, bls, mov1, parts,
           part, bl, i, gens, size;
    k := Length(arg);
    act := arg[k];
    pt := arg[k-3];

    if arg[k-1] <> arg[k-2] then
        TryNextMethod();
    fi;
    mov := MovedPoints(sym);
    if act = OnPoints and IsPosInt(pt) then
        if pt in mov then
            stab := SymmetricGroup(Difference(mov,[pt]));
        else
            stab := sym;
        fi ;
        nat := true;
    elif (act = OnTuples or act = OnPairs) and IsList(pt) and ForAll(pt, IsPosInt) then
        stab := SymmetricGroup(Difference(mov, Set(pt)));
        nat := true;
    elif act = OnSets and IsSet(pt) and ForAll(pt, IsPosInt) then
        diff := Difference(mov, pt);
        int := Intersection(mov,pt);
        if Length(diff) = 0 or Length(int) = 0 then
            stab := sym;
            nat := true;
        else
            stab := Group(Concatenation(GeneratorsOfGroup(SymmetricGroup(diff)),
                            GeneratorsOfGroup(SymmetricGroup(int))),());
            SetSize(stab, Factorial(Length(diff))*Factorial(Length(int)));
            nat := Length(diff) = 1 or Length(int) = 1;
        fi;
    elif act = OnTuplesTuples and IsList(pt) and ForAll(pt, x->IsList(x) and ForAll(x,IsPosInt)) then
        stab := SymmetricGroup(Difference(mov,Set(Flat(pt))));
        nat := true;
    elif act = OnTuplesSets and IsList(pt) and ForAll(pt, x-> IsSet(x) and ForAll(x,IsPosInt)) then
        bls := List(mov, x-> List(pt, y-> x in y));
        mov1 := ShallowCopy(mov);
        SortParallel(bls, mov1);
        parts := [];
        part := [mov1[1]];
        bl := bls[1];
        for i in [2..Length(mov)] do
            if bls[i] <> bl then
                if Length(part) > 1 then
                    Add(parts, part);
                fi;
                bl := bls[i];
                part := [mov1[i]];
            else
                Add(part, mov1[i]);
            fi;
        od;
        if Length(part) > 1 then
            Add(parts, part);
        fi;

        gens := [];
        size := 1;
        for part in parts do
            Append(gens, GeneratorsOfGroup(SymmetricGroup(part)));
            size := size*Factorial(Length(part));
        od;
        stab := Group(gens,());
        SetSize(stab,size);
        nat := Length(parts) <= 1;
    else
        TryNextMethod();
    fi;
    stab := AsSubgroup(sym, stab);
    if nat then
        SetIsNaturalSymmetricGroup(stab,true);
    fi;
    return stab;
end );







InstallOtherMethod( StabilizerOp,"symmetric group", true,
    [ IsNaturalSymmetricGroup, IsObject, IsList, IsList, IsFunction ],
  # the objects might be a group element: rank up
        {} -> RankFilter(IsMultiplicativeElementWithInverse) +
        RankFilter(IsSolvableGroup),
        SYMGP_STABILIZER);

InstallOtherMethod( StabilizerOp,"symmetric group", true,
    [ IsNaturalSymmetricGroup, IsDomain, IsObject, IsList, IsList, IsFunction ],
  # the objects might be a group element: rank up
        {} -> RankFilter(IsMultiplicativeElementWithInverse) +
        RankFilter(IsSolvableGroup),
        SYMGP_STABILIZER);

InstallOtherMethod( StabilizerOp,"alternating group", true,
    [ IsNaturalAlternatingGroup, IsObject, IsList, IsList, IsFunction ],
  # the objects might be a group element: rank up
        {} -> RankFilter(IsMultiplicativeElementWithInverse) +
        RankFilter(IsSolvableGroup),
function(g, arg...)
local s;
  s:=SymmetricParentGroup(g);
  # we cannot go to the symmetric group if the acting elements are different
  if arg[2]<>arg[3] or not IsSubset(s,arg[2]) then
    TryNextMethod();
  fi;
  return AlternatingSubgroup(Stabilizer(s,arg[1],GeneratorsOfGroup(s),GeneratorsOfGroup(s),arg[4]));
end);


InstallOtherMethod( StabilizerOp,"alternating group", true,
    [ IsNaturalAlternatingGroup, IsDomain, IsObject, IsList, IsList, IsFunction ],
  # the objects might be a group element: rank up
        {} -> RankFilter(IsMultiplicativeElementWithInverse) +
        RankFilter(IsSolvableGroup),
        function(g, arg...)
    return AlternatingSubgroup(CallFuncList(Stabilizer, Concatenation([SymmetricParentGroup(g)], arg)));
end);

InstallMethod( CentralizerOp,
    "element in natural alternating group",
    IsCollsElms,
    [ IsNaturalAlternatingGroup, IsPerm ], 0,
        function ( G, g )
    return AlternatingSubgroup(Centralizer(SymmetricParentGroup(G),g));
end);


InstallMethod( CentralizerOp,
    "element in natural symmetric group",
    IsCollsElms,
    [ IsNaturalSymmetricGroup, IsPerm ], 0,
function ( G, g )
    local   C,          # centralizer of <g> in <G>, result
            sgs,        # strong generating set of <C>
            gen,        # one generator in <sgs>
            cycles,     # cycles of <g>
            cycle,      # one cycle from <cycles>
            lasts,      # '<lasts>[<l>]' is the last cycle of length <l>
            last,       # one cycle from <lasts>
            counts,     # number of cycles of each length
            mov,        # moved points of group
            siz,        # size of centraliser
            l;

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

    if not g in G then
      TryNextMethod();
    fi;

    # handle special case
    mov:=MovedPoints(G);

    # start with the empty strong generating system
    sgs := [];

    # compute the cycles and find for each length the last one
    # and the count
    cycles := Cycles( g, mov );
    lasts := [];
    counts := [];
    for cycle  in cycles  do
        l := Length(cycle);
        lasts[l] := cycle;
        if not IsBound(counts[l]) then
            counts[l] := 1;
        else
            counts[l] := counts[l]+1;
        fi;
    od;

    # loop over the cycles
    for cycle  in cycles  do
        l := Length(cycle);
      # add that cycle itself to the strong generators
      if l <> 1  then
          gen := MappingPermListList(cycle,
                    Concatenation(cycle{[2..l]},[cycle[1]]));
          Add( sgs, gen );
      fi;

      # and this cycle can be mapped to the last cycle of this length
      if cycle <> lasts[ Length(cycle) ]  then
          last := lasts[ Length(cycle) ];
          gen := MappingPermListList(Concatenation(cycle,last),
                                      Concatenation(last,cycle));
          Add( sgs, gen );
      fi;

  od;

  siz := 1;
  for l in [1..Length(counts)] do
      if IsBound(counts[l]) then
          siz := siz*l^counts[l]*Factorial(counts[l]);
      fi;
  od;

  # make the centralizer
  C := SubgroupNC(  G , sgs );
  SetSize(C,siz);


  # return the centralizer
  return C;
end);


BindGlobal("AllNormalizerfixedBlockSystem",function(G,dom)
local b, bl,prop;

  # what properties can we find easily
  prop:=function(s)
  local p;

    s:=Set(dom{s});
    p:=[Length(s)];

    if  ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
      Info(InfoPerformance,2,"Using Transitive Groups Library");

      # type of action on blocks
      if TransitiveGroupsAvailable(Length(dom)/Length(s)) then
        Add(p,TransitiveIdentification(Action(G,Orbit(G,s,OnSets),OnSets)));
      fi;

      # type of action on blocks
      if TransitiveGroupsAvailable(Length(s)) then
        Add(p,TransitiveIdentification(Action(Stabilizer(G,s,OnSets),s)));
      fi;
    fi;

    if Length(p)=1 then
      return p[1];
    else
      return p;
    fi;
  end;

  if IsPrimeInt(Length(dom)) then
    # no need trying
    return fail;
  fi;
  b:=AllBlocks(Action(G,dom));
  b:=ShallowCopy(b);

  #Print(List(b,Length),"\n");
  bl:=Collected(List(b,prop));
  bl:=Filtered(bl,i->i[2]=1);
  if Length(bl)=0 then
    Info(InfoGroup,3,"No normalizerfixed block found");
    return fail;
  fi;
  b:=Filtered(b,i->prop(i)=bl[1][1]);
  Info(InfoGroup,3,"Normalizerfixed block system blocksize ",List(b,Length));
  return List(b,x->Set(Orbit(G,Set(dom{x}),OnSets)));
end);

# Calculate subgroup of Sn/An that must contain the normalizer. Then a
# subsequent backtrack search is in a smaller group and thus much faster.
# Parameters: Overgroup (must be symmetric or alternating, otherwise just
# returns this overgroup), subgroup.
InstallGlobalFunction(NormalizerParentSA,function(s,u)
local dom, issym, o, b, beta, alpha, emb, nb, na, w, perm, pg, l, is, ie, ll,
syll, act, typ, sel, bas, wdom, comp, lperm, other, away, i, j,b0,opg,bp;

  dom:=Set(MovedPoints(s));
  issym:=IsNaturalSymmetricGroup(s);
  if not IsSubset(dom,MovedPoints(u)) or
    (not issym and (not IsNaturalAlternatingGroup(s) or
      ForAny(GeneratorsOfGroup(u),x->SignPerm(x)=-1))) then
    return s; # cannot get parent, as not contained
  fi;
  # get orbits
  o:=ShallowCopy(Orbits(u,dom));
  Info(InfoGroup,1,"SymmAlt normalizer: orbits ",List(o,Length));

  if Length(o)=1 and IsAbelian(u) then
    b:=List(PrimeDivisors(Size(u)),p->Omega(SylowSubgroup(u,p),p,1));
    if Length(b)=1 and IsTransitive(b[1],dom) then
      # elementary abelian, regular -- construct the correct AGL
      b:=b[1];
      bas:=Pcgs(b);
      pg:=Centralizer(s,b);
      for i in GeneratorsOfGroup(GL(Length(bas),RelativeOrders(bas)[1])) do
        bp:=dom[1];
        w:=GroupHomomorphismByImagesNC(b,b,bas,
          List([1..Length(bas)],x->PcElementByExponents(bas,i[x])));
        w:=List(dom,x->bp^Image(w,First(AsSSortedList(b),a->bp^a=x)));
        w:=MappingPermListList(dom,w);
        pg:=ClosureGroup(pg,w);
      od;
      return Intersection(s,pg);
    else
      SortBy(b,Size);
      b:=Reversed(b); # larger ones should give most reduction.
      pg:=NormalizerParentSA(s,b[1]);
      for i in [2..Length(b)] do
        pg:=Normalizer(pg,b[i]);
      od;
      return Intersection(s,pg);
    fi;
  elif Length(o)=1 and IsPrimitive(u,dom) then
    # natural symmetric/alternating
    if IsNormal(s,u) then
      return s;
    fi;
    # can there be more in the normalizer -- primitive groups
    b:=Socle(u);
    if IsElementaryAbelian(b) then
      return NormalizerParentSA(s,b);
    fi;
    # nonabelian socle
    if PrimitiveGroupsAvailable(Length(dom))
      and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
      Info(InfoPerformance,2,"Using Primitive Groups Library");
      # use library
      beta:=Factorial(Length(dom))/2;
      w:=CallFuncList(ValueGlobal("AllPrimitiveGroups"),
          [NrMovedPoints,Length(dom),IsSolvableGroup,false,
          x->Size(x)>Size(u) and Size(x) mod Size(u)=0 and
          Size(x)<beta,true]);
      if Length(w)=0 then
        return u; # must be self-normalizing
      fi;
    fi;
    # find right automorphisms (socle cannot have centralizer)
    w:=AutomorphismGroup(b);
    opg:=NaturalHomomorphismByNormalSubgroupNC(w,
          InnerAutomorphismsAutomorphismGroup(w));
    ll:=List(AsSSortedList(Image(opg)),x->PreImagesRepresentative(opg,x));
    ll:=Filtered(ll,IsConjugatorAutomorphism);
    ll:=List(ll,ConjugatorInnerAutomorphism);
    pg:=b;
    for i in ll do
      pg:=ClosureGroup(pg,i);
    od;
    return Intersection(s,pg);

  elif Length(o)=1 then

    b0:=AllNormalizerfixedBlockSystem(u,o[1]);
    if b0=fail then
      # none -- no improvement
      return s;
    fi;
    # the normalizer must fix these block system
    opg:=fail;
    for b in b0 do
      beta:=ActionHomomorphism(u,b,OnSets,"surjective");
      alpha:=ActionHomomorphism(Stabilizer(u,b[1],OnSets),b[1],"surjective");
      emb:=KuKGenerators(u,beta,alpha);
      nb:=Normalizer(SymmetricGroup(Length(b)),Image(beta));
      na:=Normalizer(SymmetricGroup(Length(b[1])),Image(alpha));
      w:=WreathProduct(na,nb);
      if issym then
        perm:=s;
      else
        perm:=SymmetricGroup(MovedPoints(s));
      fi;
      perm:=RepresentativeAction(perm,emb,GeneratorsOfGroup(u),OnTuples);
      if perm<>fail then
        pg:=w^perm;
      else
        #Print("Embedding Problem!\n");
        w:=WreathProduct(SymmetricGroup(Length(b[1])),SymmetricGroup(Length(b)));
        perm:=MappingPermListList([1..Length(o[1])],Concatenation(b));
        pg:=w^perm;
      fi;
      if opg<>fail then
        pg:=Intersection(pg,opg);

      fi;
      opg:=pg;
    od;
    if Length(GeneratorsOfGroup(pg))>5 then
      opg:=Group(SmallGeneratingSet(pg));
      SetSize(opg,Size(pg));
      pg:=opg;
    fi;

  else

    # first sort by Length
    SortBy(o, Length);
    l:=Length(o);
    pg:=[]; # parent generators
    is:=1;
    ie:=1;
    while is<=l do
      ll:=Length(o[is]);
      while ie<=l and Length(o[ie])=ll do
        ie:=ie+1;
      od;
      # now length block is from is to ie-1

      syll:=SymmetricGroup(ll);
      # if the degrees are small enough, even get local types
      if ll>1 and TransitiveGroupsAvailable(ll)
        and ValueOption(NO_PRECOMPUTED_DATA_OPTION)<>true then
        Info(InfoPerformance,2,"Using Transitive Groups Library");
        Info(InfoGroup,1,"Length ",ll," sort by types");
        act:=[];
        typ:=[];
        for i in [is..ie-1] do
          act[i]:=Action(u,o[i]);
          typ[i]:=TransitiveIdentification(act[i]);
        od;
        # rearrange
        for i in Set(typ) do
          sel:=Filtered([is..ie-1],j->typ[j]=i);
          bas:=NormalizerParentSA(syll,act[sel[1]]);
          bas:=Normalizer(bas,act[sel[1]]);
          w:=WreathProduct(bas,SymmetricGroup(Length(sel)));
          wdom:=[1..ll*Length(sel)];
          comp:=WreathProductInfo(w).components;
          # now the suitable permutation
          perm:=();
          # first permutation on each component
          for j in [1..Length(sel)] do
            if j=1 then
              lperm:=();
            else
              lperm:=RepresentativeAction(syll,act[sel[1]],act[sel[j]]);
            fi;
            other:=Difference(wdom,comp[j]);
            away:=[1..Length(other)]+Length(wdom);
            perm:=perm*MappingPermListList(Concatenation(comp[j],other),
                                Concatenation([1..ll],away)) # j-th component
                  *lperm # standard form
                  *MappingPermListList(Concatenation([1..ll],away),
                                Concatenation(comp[j],other)); # to j orbit
          od;
          # and then of components
          perm:=perm*MappingPermListList(wdom,Concatenation(o{sel}));
          for i in SmallGeneratingSet(w) do
            Add(pg,i^perm);
          od;
        od;

      else
        bas:=syll;
        w:=WreathProduct(bas,SymmetricGroup(ie-is));
        perm:=MappingPermListList([1..ll*(ie-is)],Concatenation(o{[is..ie-1]}));
        for i in SmallGeneratingSet(w) do
          Add(pg,i^perm);
        od;
      fi;
      is:=ie;
    od;
    pg:=Group(pg,());
  fi;
  if not issym then
    pg:=AlternatingSubgroup(pg);
  fi;
  if (Size(pg)/Size(u))>10000 and IsSolvableGroup(pg) then
    perm:=IsomorphismPcGroup(pg);
    pg:=PreImage(perm,Normalizer(Image(perm,pg),Image(perm,u)));
  fi;
  return pg;
end);

BindGlobal("DoNormalizerSA",function ( G, U )
local P;
    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

  P:=NormalizerParentSA(G,U);
  if Size(P)<Size(G) then
    Info(InfoGroup,1,"Normalizer parent deg ",NrMovedPoints(G),
         " reduces by ",Index(G,P));
    return AsSubgroup(G,Normalizer(P,U));
  else
    Info(InfoGroup,2,"No improvement by symm/alt normalizer");
    TryNextMethod(); # go way of permutations
  fi;
end);

InstallMethod( NormalizerOp, "subgp of natural symmetric group",
    IsIdenticalObj, [ IsNaturalSymmetricGroup, IsPermGroup ], 0,
    DoNormalizerSA);

InstallMethod( NormalizerOp, "subgp of natural alternating group",
    IsIdenticalObj, [ IsNaturalAlternatingGroup, IsPermGroup ], 0,
    DoNormalizerSA);


# conjugate subgroups of symmetric group.
# false indicates the method does not work
BindGlobal("SubgpConjSymmgp",function(s,g,h)
local og,oh,cb,cc,cac,perm1,perm2,
  dom,n,a,c,b,b2,w,p1,p2,perm,t,ac,ac2,no,no2,i;


  p1:=Set(MovedPoints(g));
  p2:=Set(MovedPoints(h));
  dom:=Set(MovedPoints(s));

  og:=Orbits(g,p1);
  oh:=Orbits(h,p2);

  # different orbits lengths -- cannot be conjugate
  if Collected(List(og,Length))<>Collected(List(oh,Length)) then
    return fail;
  fi;

  if Length(og)>1 or p1<>p2 or p1<>dom then
    # intransitive
    if not (IsSubset(dom,p1) and IsSubset(dom,p2)) then
      return false;
    fi;
    if Collected(List(og,Length))<>Collected(List(oh,Length)) then
      return fail;
    fi;
    og:=Set(og,Set);
    oh:=Set(oh,Set);
    ac:=[];
    a:=1;
    perm:=();
    perm1:=[];
    perm2:=[];
    if p1<>p2 then
      Add(perm1,Difference(dom,p1));
      Add(perm2,Difference(dom,p2));
    fi;
    for i in (Set(og,Length)) do
      c:=Filtered(og,x->Length(x)=i);
      #Append(p1,c);
      ac2:=Filtered(oh,x->Length(x)=i);
      #Append(p2,ac2);
      w:=WreathProduct(SymmetricGroup(i),SymmetricGroup(Length(ac2)));
      b:=Blocks(w,MovedPoints(w),[1..i]);
      cc:=Concatenation(c);
      cb:=Concatenation(b);
      cac:=Concatenation(ac2);
      Add(perm1,cc);
      Add(perm2,cac);
      c:=MappingPermListList(cc,cb);
      b:=MappingPermListList(cb,cac);

      # make projections the same
      p1:=List(GeneratorsOfGroup(g),x->RestrictedPerm(x,cc)^c);
      p1:=SubgroupNC(w,p1);
      p2:=List(GeneratorsOfGroup(h),x->b*RestrictedPerm(x,cac)/b);
      p2:=SubgroupNC(w,p2);
      no:=Normalizer(w,p2);
#Print(i," ",Length(ac2)," ",Size(w)," ",Index(w,no),"\n");
      t:=RepresentativeAction(w,p1,p2);
      if t=fail then return fail;fi; # can't map projection OK

#Print(List(Filtered(og,x->Length(x)=i),x->Position(oh,OnSets(x,c*b))),"\n");

      Append(ac,List(GeneratorsOfGroup(no),x->x^b));
      perm:=perm*t^b;
      a:=a*Size(no);
    od;
    perm1:=MappingPermListList(Concatenation(perm1),Concatenation(perm2));
    perm:=perm1*perm;
    ac:=SubgroupNC(s,ac);
    SetSize(ac,a);
    a:=RepresentativeAction(ac,g^perm,h);
    if a=fail then
      return fail;
    else
      return perm*a;
    fi;

  fi;

  n:=NrMovedPoints(s);
  a:=AllBlocks(g);
  c:=Collected(List(a,Length));
  c:=Filtered(c,i->i[2]=1);
  if Length(c)=0 then
    return false;
  else
    c:=c[1][1];
    a:=First(a,i->Length(i)=c);
    b:=Blocks(g,MovedPoints(g),a);
    ac:=Action(g,b,OnSets);
    a:=AllBlocks(h);
    a:=Filtered(a,i->Length(i)=c);
    if Length(a)<>1 then
      # different blocks
      return fail;
    fi;
    b2:=Blocks(h,MovedPoints(h),a[1]);
    ac2:=Action(h,b2,OnSets);
    t:=SymmetricGroup(n/c);
    perm:=RepresentativeAction(t,ac,ac2);
    if perm=fail then
      return fail;
    else
      b:=Permuted(b,perm);
      Assert(1,Action(g,b,OnSets)=ac2);
    fi;
    p1:=MappingPermListList(Concatenation(b),[1..n]);
    p2:=MappingPermListList(Concatenation(b2),[1..n]);
    no:=Normalizer(t,ac2);
    #Print(" using blocks ",c," factorgp size ",Size(no),"\n");
    g:=g^p1;
    h:=h^p2;
    b:=List(b,i->OnSets(Set(i),p1));
    ac:=Action(Stabilizer(g,b[1],OnSets),b[1]);
    t:=SymmetricGroup(c);
    for i in [1..Length(b)] do
      ac2:=Action(Stabilizer(g,b[i],OnSets),b[i]);
      perm:=RepresentativeAction(t,ac2,ac);
      if perm=fail then
        # b cannot be conjugated -- inconsistent
        Error("inconsistence");
      fi;
      perm:=perm^MappingPermListList([1..c],b[i]);
      g:=g^perm;
      p1:=p1*perm;

      ac2:=Action(Stabilizer(h,b[i],OnSets),b[i]);
      perm:=RepresentativeAction(t,ac2,ac);
      if perm=fail then
        # cannot map onto -- wrong
        return fail;
      fi;
      perm:=perm^MappingPermListList([1..c],b[i]);
      h:=h^perm;
      p2:=p2*perm;
    od;

    no2:=Normalizer(t,ac);

    w:=WreathProduct(no2,no);
    perm:=RepresentativeAction(w,g,h);
    if perm<>fail then
      Assert(1,ForAll(GeneratorsOfGroup(g),i->i^perm in h));
      perm:=p1*perm/p2;
    fi;
    return perm;
  fi;
end);

InstallMethod( IsConjugate, "for natural symmetric group",
    true, [ IsNaturalSymmetricGroup, IsGroup, IsGroup ],
function (s, g, h)
  local res;
  res := SubgpConjSymmgp(s, g, h);
  if IsPerm(res) then
    return true;
  elif res = fail then
    return false;
  else
   TryNextMethod();
  fi;
end);

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, <opr> ) .  . for symmetric groups
##
InstallOtherMethod( RepresentativeActionOp, "for natural symmetric group",
    true, [ IsNaturalSymmetricGroup, IsObject, IsObject, IsFunction ],
  # the objects might be group elements: rank up
  {} -> 2*RankFilter(IsMultiplicativeElementWithInverse),
function ( G, d, e, opr )
local dom,n,sortfun,cd,ce,p1,p2;
  # test for internal rep
  if HasGeneratorsOfGroup(G) and
    not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
    TryNextMethod();
  fi;

  dom:=Set(MovedPoints(G));
  n:=Length(dom);
  if opr=OnPoints then
    if IsInt(d) and IsInt(e) then
      if d in dom and e in dom then
        return (d,e);
      else
        return fail;
      fi;
    elif IsPerm(d) and IsPerm(e) and d in G and e in G then
      sortfun:=function(a,b) return Length(a)<Length(b);end;
      if Order(d)=1 then #LargestMovedPoint does not work for ().
        if Order(e)=1 then
          return ();
        else
          return fail;
        fi;
      fi;
      if CycleStructurePerm(d)<>CycleStructurePerm(e) then
        return fail;
      fi;
      cd:=ShallowCopy(Cycles(d,dom));
      ce:=ShallowCopy(Cycles(e,dom));
      Sort(cd,sortfun);
      Sort(ce,sortfun);
      return MappingPermListList(Concatenation(cd),Concatenation(ce));
    elif IsPermGroup(d) and IsPermGroup(e)
      #and IsTransitive(d,dom) and IsTransitive(e,dom)
      and IsSubset(G,d) and IsSubset(G,e) then

      if dom<>[1..n] then
        # translate
        p1:=MappingPermListList(dom,[1..n]);
        p2:=SubgpConjSymmgp(G^p1,d^p1,e^p1);
        if p2=false then
            TryNextMethod();
        elif p2<>fail then
          p2:=p2^Inverse(p1);
        fi;
        return p2;
      else
        p2:=SubgpConjSymmgp(G,d,e);
        if p2=false then
          TryNextMethod();
        fi;
        return p2;
      fi;
    fi;
  elif (opr=OnSets or opr=OnTuples) and (IsDuplicateFreeList(d) and
    IsDuplicateFreeList(e)) then
    if Length(d)<>Length(e) then
      return fail;
    fi;
    if IsSubset(dom,Set(d)) and IsSubset(dom,Set(e)) then
      if dom <> [1..n] then
        p1 := MappingPermListList(dom,[1..n]);
        return p1*MappingPermListList(OnTuples(d,p1),OnTuples(e,p1))/p1;
      fi;
      return MappingPermListList(d,e);
    fi;
  fi;
  TryNextMethod();
end);

InstallMethod( SylowSubgroupOp,
    "symmetric",
    true,
    [ IsNaturalSymmetricGroup, IsPosInt ], 0,
function ( G, p )
local   S,          # <p>-Sylow subgroup of <G>, result
        sgs,        # strong generating set of <G>
        q,          # power of <p>
        mov,deg,trf, # degree, moved points, transfer
        i;          # loop variable

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

    mov:=MovedPoints(G);
    deg:=Length(mov);
    trf:=MappingPermListList([1..deg],mov);
    # make the strong generating set
    sgs := [];
    for i  in [1..deg]  do
        q := p;
        while i mod q = 0  do
            Add( sgs, PermList( Concatenation(
                        [1..i-q], [i-q+1+q/p..i], [i-q+1..i-q+q/p] ) )^trf );
            q := q * p;
        od;
    od;

    # make the Sylow subgroup
    S := SubgroupNC(  G , sgs );
    SetSize(S,p^Length(sgs));


    if Size( S ) > 1 then
        SetIsPGroup( S, true );
        SetPrimePGroup( S, p );
        SetHallSubgroup(G, [p], S);
    fi;

    # return the Sylow subgroup
    return S;
end);

InstallMethod( ConjugacyClasses,
    "symmetric",
    true,
    [ IsNaturalSymmetricGroup ], 0,
function ( G )
    local   classes,    # conjugacy classes of <G>, result
            prt,        # partition of <G>
            sum,        # partial sum of the entries in <prt>
            rep,        # representative of a conjugacy class of <G>
            mov,deg,trf, # degree, moved points, transfer
            i;          # loop variable

    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;

    mov:=MovedPoints(G);
    deg:=Length(mov);
    trf:=MappingPermListList([1..deg],mov);
    # loop over the partitions
    classes := [];
    for prt  in Partitions( deg )  do

      # compute the representative of the conjugacy class
      rep := [2..deg];
      sum := 1;
      for i  in prt  do
          rep[sum+i-1] := sum;
          sum := sum + i;
      od;
      rep := PermList( rep )^trf;

      # add the new class to the list of classes
      Add( classes, ConjugacyClass( G, rep ) );

    od;

    # return the classes
    return classes;
end);

InstallMethod( IsomorphismFpGroup, "symmetric group, supply name", true,
    [ IsSymmetricGroup ],
    30, # override `IsNatural...' method
function(G)
  return IsomorphismFpGroup(G,
           Concatenation("S_",String(SymmetricDegree(G)),".") );
end);

InstallOtherMethod( IsomorphismFpGroup, "symmetric perm group,name", true,
    [ IsSymmetricGroup and IsPermGroup,IsString ], 0,
function ( G,nam )
local   F,      # free group
        gens,   #generators of F
        imgs,
        premap, # map to apply first
        hom,    # bijection
        mov,deg,
        relators,
        i, k;       # loop variables

    if IsTrivial(G) then
      return GroupHomomorphismByFunction(G, TRIVIAL_FP_GROUP,
                                         x->One(TRIVIAL_FP_GROUP),
                                         x->One(G):noassert);
    fi;
    # test for internal rep
    if HasGeneratorsOfGroup(G) and
      not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
      TryNextMethod();
    fi;


    #are we natural?
    if not IsNaturalSymmetricGroup(G) then
      F:=G;
      G:=SymmetricGroup(SymmetricDegree(G));
      premap:=CheapIsomSymAlt(F,G);
    else
      premap:=fail;
    fi;

    mov:=MovedPoints(G);
    deg:=Length(mov);

    # create the finitely presented group with <G>.degree-1 generators
    F := FreeGroup( deg-1, nam );
    gens:=GeneratorsOfGroup(F);

    # add the relations according to the Coxeter presentation $a-b-c-...-d$
    relators := [];
    for i  in [1..deg-1]  do
        Add( relators, gens[i]^2 );
    od;
    for i  in [1..deg-2]  do
        Add( relators, (gens[i] * gens[i+1])^3 );
        for k  in [i+2..deg-1]  do
            Add( relators, (gens[i] * gens[k])^2 );
        od;
    od;

    F:=F/relators;

    SetSize(F,Size(G));
    UseIsomorphismRelation( G, F );

    # compute the bijection
    imgs:=[];
    for i in [2..deg] do
      Add(imgs,(mov[i-1],mov[i]));
    od;

    # return the isomorphism to the finitely presented group
    hom:= GroupHomomorphismByImagesNC(G,F,imgs,GeneratorsOfGroup(F));
    if premap<>fail then hom:=premap*hom;fi;
    SetIsBijective( hom, true );
    ProcessEpimorphismToNewFpGroup(hom);
    return hom;
end);


# use this presentation also for rewriting
InstallMethod(IsomorphismFpGroupForRewriting,"symmetric",
  [IsNaturalSymmetricGroup],0,
  IsomorphismFpGroup);


#############################################################################
##
#M  ViewObj( <nat-sym-grp> )
##
InstallMethod( ViewString,
    "for natural alternating group",
    true,
    [ IsNaturalAlternatingGroup ], 0,
function(alt)
    alt:=MovedPoints(alt);
    if Length(alt)=0 then TryNextMethod();fi;
    IsRange(alt);
    return Concatenation( "Alt( ", String(alt), " )" );
end );

InstallMethod( ViewString,
    "for natural symmetric group",
    true,
    [ IsNaturalSymmetricGroup ], 0,
function(sym)
    sym:=MovedPoints(sym);
    if Length(sym)=0 then TryNextMethod();fi;
    IsRange(sym);
    return Concatenation( "Sym( ",String(sym), " )" );
end );

InstallMethod( ViewObj,
    "for natural alternating group",
    true,
    [ IsNaturalAlternatingGroup ], 0,
function(alt)
    Print(ViewString(alt));
end );

InstallMethod( ViewObj,
    "for natural symmetric group",
    true,
    [ IsNaturalSymmetricGroup ], 0,
function(sym)
    Print(ViewString(sym));
end );

#############################################################################
##
#M  PrintObj( <nat-sym-grp> )
##
InstallMethod( String,
    "for natural symmetric group",
    true,
    [ IsNaturalSymmetricGroup ], 0,
function(sym)
    sym:=MovedPoints(sym);
    if Length(sym)=0 then TryNextMethod();fi;
    IsRange(sym);
    return Concatenation( "SymmetricGroup( ",String(sym), " )" );
end );

InstallMethod( String,
    "for natural alternating group",
    true,
    [ IsNaturalAlternatingGroup ], 0,
function(alt)
    alt:=MovedPoints(alt);
    if Length(alt)=0 then TryNextMethod();fi;
    IsRange(alt);
    return Concatenation( "AlternatingGroup( ",String(alt), " )" );
end );

InstallMethod( PrintObj,
    "for natural alternating group",
    true,
    [ IsNaturalAlternatingGroup ], 0,
function(alt)
    Print(String(alt));
end );

InstallMethod( PrintObj,
    "for natural symmetric group",
    true,
    [ IsNaturalSymmetricGroup ], 0,
function(sym)
    Print(String(sym));
end );

#############################################################################
##
#M  SymmetricParentGroup( <grp> )
##
InstallMethod( SymmetricParentGroup,
    "symm(moved pts)",
    true,
    [ IsPermGroup ], 0,
    G -> SymmetricGroup( MovedPoints( G ) ) );

InstallMethod( SymmetricParentGroup,
    "natural symmetric group",
    true,
    [ IsNaturalSymmetricGroup ], 0,
    IdFunc );


#############################################################################
##
#M  OrbitStabilizingParentGroup( <grp> )
##
InstallMethod( OrbitStabilizingParentGroup, "direct product of S_n's",
    true, [ IsPermGroup ], 0,
function(G)
local o,d,i,j,l,s;
  o:=ShallowCopy(OrbitsDomain(G,MovedPoints(G)));
  SortBy(o, Length);
  d:=false;
  i:=1;
  while i<=Length(o) do
    l:=Length(o[i]);
    j:=i+1;
    while j<=Length(o) and Length(o[j])=l do
      j:=j+1;
    od;
    s:=SymmetricGroup(l);
    if j-1>i then
      s:=WreathProduct(s,SymmetricGroup(j-i));
    fi;
    if d=false then
      d:=s;
    else
      d:=DirectProduct(d,s);
    fi;
    Assert(1,HasSize(d));
    i:=j;
  od;
  d:=ConjugateGroup(d,MappingPermListList(Set(MovedPoints(d)),
                                          Concatenation(o)));
  Assert(1,IsSubset(d,G));
  return d;
end);

InstallOtherMethod( StabChainOp, "symmetric group", true,
    [ IsNaturalSymmetricGroup,IsRecord ], 0,
function(G,r)
local dom, l, sgs, nondupbase;

  # test for internal rep
  if HasGeneratorsOfGroup(G) and
    not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
    TryNextMethod();
  fi;

  if IsBound(r.reduced) and r.reduced=false then
    TryNextMethod();
  fi;
  dom:=Set(MovedPoints(G));
  l:=Length(dom);
  if IsBound(r.base) then
    nondupbase:=DuplicateFreeList(r.base);
    dom:=Concatenation(Filtered(nondupbase,i->i in dom),Difference(dom,nondupbase));
  fi;
  sgs:=List([1..l-1],i->(dom[i],dom[l]));
  return StabChainBaseStrongGenerators(dom{[1..Length(dom)-1]},sgs,());
end);

InstallOtherMethod( StabChainOp, "alternating group", true,
    [ IsNaturalAlternatingGroup,IsRecord ], 0,
function(G,r)
local dom, l, sgs, nondupbase;

  # test for internal rep
  if HasGeneratorsOfGroup(G) and
    not ForAll(GeneratorsOfGroup(G),IsInternalRep) then
    TryNextMethod();
  fi;

  if IsBound(r.reduced) and r.reduced=false then
    TryNextMethod();
  fi;
  dom:=Set(MovedPoints(G));
  l:=Length(dom);

  if IsBound(r.base) then
      nondupbase:=DuplicateFreeList(r.base);
      dom:=Concatenation(Filtered(nondupbase,i->i in dom),Difference(dom,nondupbase));
  fi;

  sgs:=List([1..l-2],i->(dom[i],dom[l-1],dom[l]));
  return StabChainBaseStrongGenerators(dom{[1..Length(dom)-2]},sgs,());
end);

#############################################################################
##
#M  AlternatingSubgroup( <grp> )
##
InstallMethod(AlternatingSubgroup,"for perm groups",true,[IsPermGroup],0,
function(G)
local a,b,x,i;
  if SignPermGroup(G)=1 then
    return G;
  fi;
  # otherwise construct
  # this is faster than intersecting with A_n, because no stabchain for A_n
  # needs to be built
  a:=[];
  b:=[];
  for i in GeneratorsOfGroup(G) do
    if SignPerm(i)=1 then
      Add(a,i);
    else
      Add(b,i);
      if Order(i)>2 then
        Add(a,i^2);
      fi;
      if Length(b)>1 then
        Add(a,b[1]/i);
      fi;
    fi;
  od;
  a:=SubgroupNC(G,a);
  StabChainOptions(a).limit:=Size(G)/2;
  while Size(a)<Size(G)/2 do
    repeat
      #Print("close\n");
      x:=Random(GeneratorsOfGroup(a))^Random(b);
    until not x in a;
    a:=ClosureSubgroupNC(a,x);
  od;
  return a;

end);

# maximal subgroups routine.
# precomputed data up to degree 50 (so it will be quick is most cases).
# (As there is no independent check for the primitive groups of degree >50,
# we rather do not refer to them, but only use them in a calculation.)
BindGlobal("SNMAXPRIMS", MakeImmutable([[],[],[],[],[],[2],[],[5],[],[7],[],[4],
[],[2],[],[],[],[2],[],[2],[1,3,7],[2],[],[3],[],[5],[],[12],[],[2],[],[5],[],
[],[],[12],[],[2],[],[4,6],[],[2],[],[2],[5],[],[],[2],[],[7],[],[],[],[2],[6],
[7,5],[],[],[],[7],[],[2],[2],[],[2],[],[],[3,5],[],[],[],[2],[],[2],[],[],[],
[2,4],[],[2],[],[8],[],[2,4],[4],[],[],[],[],[2],[8],[],[],[],[],[],[],[2],[],
[4,2],[],[3],[],[2],[7,9],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],[10],[],
[5],[],[],[],[2,17,11],[],[5],[],[5],[],[2],[],[],[],[12],[],[2],[],[2],[],[],
[],[],[],[],[],[],[],[2],[],[2],[],[],[],[7],[],[2],[],[],[],[5],[],[2],[2],
[],[],[7],[],[5],[4,2],[],[],[2],[2],[],[],[],[],[2],[],[2],[],[],[],[],[],[],
[],[],[],[2],[],[2],[],[],[],[2],[],[2],[],[],[],[],[],[],[],[],[],[4],[],[2],
[],[],[],[],[],[],[],[3],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[4],[],[],
[],[],[],[2],[],[2],[],[4],[],[],[],[],[],[],[],[2],[7,2],[],[],[],[],[2],[],
[],[],[],[],[2],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[2,20,22],[],
[2],[],[2],[],[2],[],[],[],[5],[],[],[],[2],[],[],[2],[],[],[9,5,7],[],[],[],[],
[],[],[],[2],[],[],[],[2],[],[2],[3],[],[],[2],[],[],[],[],[],[],[5],[],[],[],
[],[],[],[2],[],[],[],[],[],[2],[],[],[2],[],[],[6],[],[],[],[2],[],[2],
[9,4,6],[],[],[2],[],[],[5],[],[],[18],[],[5],[],[9,4],[],[],[],[2],[3],[],[],
[],[],[2],[],[],[],[],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],
[],[],[2],[],[6],[],[2],[],[],[],[4,2],[],[],[],[2],[],[],[],[],[],[],[],[],
[],[2],[],[2],[],[],[1],[],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[],
[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],[6],[],[2],[5,2,3],
[],[],[2],[],[],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],
[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],[6],[],[],[],[],[],[2],[],[],[],
[],[],[],[],[],[],[7],[],[2],[],[2],[6],[],[],[7],[],[5],[],[],[],[],[],[],[],
[],[],[8],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],[4],[],
[],[],[2],[],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],
[],[],[2],[],[],[],[],[],[2],[2],[],[],[],[],[2],[],[2],[],[],[],[],[],[2],[],
[],[],[],[],[2],[],[],[],[2],[],[3],[],[],[],[],[],[8],[],[],[],[],[],[2],[],
[],[],[],[],[],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],
[],[],[7],[],[2],[],[],[],[4,2],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],
[],[],[],[2],[],[],[],[],[],[],[],[2],[4],[],[],[],[],[],[],[],[],[2],[],[],
[],[],[],[],[],[2],[],[],[],[],[2],[],[],[],[],[2],[],[],[],[],[],[],[],[2],
[],[13,3],[],[],[],[2],[],[],[],[],[],[2],[2],[],[],[2],[],[],[],[],[],[1],[],
[2],[],[],[],[],[],[2],[],[],[],[2],[],[],[2],[],[],[],[],[2],[],[],[],[2],[1],
[],[],[],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],
[],[],[],[],[],[],[8],[],[],[],[2],[],[2],[],[],[],[],[],[],[4],[11,2,19],[],
[2],[],[2],[],[],[],[2],[],[2],[],[],[],[],[],[],[],[],[],[6],[],[5],[],[],[],
[],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],
[],[],[],[],[],[],[],[],[2],[],[],[],[2],[],[2],[],[],[],[2],[],[],[],[],[],
[],[],[],[],[],[],[],[],[],[4,2],[],[],[],[],[2],[],[3],[],[2],[],[],[],[],[],
[],[],[2],[],[],[],[],[],[],[],[],[],[2],[],[],[],[],[],[],[],[2],[],[],[],
[2],[],[],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[],[],[5],[],[],[],
[],[],[2],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],[2],[],[],[],[],[],
[2],[],[2],[],[],[],[],[],[2],[]]));

BindGlobal("ANMAXPRIMS", MakeImmutable([[],[],[],[],[],[1],[5],[],[9],[6],[6],
[2],[7],[1],[4],[],[8],[1],[],[1],[2,6],[1],[5],[1],[],[3],[13],[6,11],[],[1],
[9,10],[4],[2],[],[2],[10,11],[],[1],[],[3,5],[],[1],[],[1],[4,7],[],[],[1],[],
[2,6],[],[1],[],[1],[5],[4,6],[1,3],[],[],
[6],[],[1],[1,4,6],[],[1,5,7,11],[5],[],
[2,4],[],[],[],[1],[14],[1],[],[],[2],[1,3],[],[1],[],[7],[],[1,3],[3],[],[],
[],[],[1],[6,7],[],[],[],[],[],[],[1],[],[1,3],[],[1,2],[],[1],[6,8],[],[],[1],
[],[1],[],[8],[],[1],[],[],[1,3],[],[2],
[5,9,14,15,17,21],[49],[4],[],[],[],[1,6,8,16],
[13],[4],[2],[3],[],[1],[1],[],[3],[6,11],
[],[1],[],[1],[],[],[],[2,4,5],[],[],[],[],[],[1],[],[1],[4],[],[1],[6],[],[1],
[],[],[],[2],[],[1],[1,5],[],[],[6],[],
[3],[1,3],[],[],[1],[1,4],[2,4],[],[],[],[1],[],[1],[2],[],[],[1],[],[],[],[4],
[],[1],[],[1],[],[],[],[1],[],[1],[],[],[1],[],[],[],[],[3],[],[2,3],[],[1],[],
[],[],[],[],[],[],[2],[],[],[],[1],[],[],[],[1],[],[1],[4],[],[],[2,3],[],[],
[],[],[],[1],[],[1],[],[3],[],[],[],[1],[],[],[],[1],[1,3,6],[],[2],[],[4],[1],
[],[],[],[],[],[1],[],[1],[],[],[],[1],[],[1],[6],[],[2],[3,6],[],[1],[],
[1,17,21],[],[1],[],[1],[1],[1],[],[],[],
[3],[],[],[],[1],[],[],[1],[],[],[2,6,8],
[],[],[],[],[],[],[1],[1],[],[],[],[1],[],[1],[1,2],[],[],[1],[],[],[],[],[],
[],[2,4,12],[],[],[],[],[2,4],[],[1],[],
[],[],[6,7],[],[1],[],[],[1],[],[],[2,5],
[],[],[],[1],[],[1],[3,5,8],[],[],[1],[],
[],[4],[],[],[17],[],[4],[],[3,7,8],[],
[],[],[1],[2],[],[],[],[],[1],[],[],[],[6,9],[],[1],[2],[],[],[1],[],[],[],[],
[],[1],[],[],[],[],[],[2],[],[1],[],[5],
[],[1],[],[],[],[1,3],[],[],[],[1],[],[],[],[],[],[4],[],[],[],[1],[],[1],[],
[],[],[],[],[],[],[],[],[1],[],[1],[4],
[],[],[],[],[1],[],[],[],[1],[],[],[],[],[],[1],[],[],[],[],[2],[2],[],[1],[],
[],[],[2,5],[],[1],[1,4],[],[],[1],[],[],[],[],[],[],[],[],[],[],[],[1],[],[],
[],[],[],[],[],[1],[],[],[],[1],[],[],[2],[3,7,10],[],[],[],[1],[],[],[],[5],
[],[1],[],[],[],[1],[1],[],[9,12],[],[],
[],[],[],[],[4,5],[],[1],[],[1],[4,5],[],[2],[3,6],[],[4],[],[],[],[],[],[],[],
[],[],[7],[],[1],[],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],[1],[],[2,3],
[2],[],[],[1],[],[],[5],[],[],[1],[],[1],[],[],[],[],[],[1],[],[],[],[],[],
[],[4],[],[],[1],[],[],[],[],[],[1],[1],[],[],[],[],[1],[],[1],[],[],[],[],[],
[1],[],[],[],[],[],[1],[],[2],[],[1],[],[1,2],[],[],[],[],[],[6],[],[],[],[2],
[],[1],[],[],[],[],[],[],[],[],[],[1],[],[1],[],[],[],[1],[],[],[1,5],[],[],
[1],[],[],[2],[],[],[6],[],[1],[],[],[],[1,3],[],[],[],[],[2],[4],[],[1],[],[],
[],[1],[],[1],[],[],[],[1],[],[],[],[],[],[],[],[1],[3],[],[],[],[],[],[],[],
[],[1],[4],[],[],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],[1],[],[],[],[],
[],[],[],[1],[],[2,12],[],[],[],[1],[],[],[],[],[],[1],[1],[],[],[1],[],[],[],
[],[],[],[],[1],[],[],[],[5],[2],[1],[1],[],[],[1],[],[],[1],[],[],[],[],[1],
[],[],[],[1],[],[],[],[],[],[2],[1],[],[],[],[],[],[],[1],[],[],[],[2],[],[],
[],[],[],[1],[],[],[],[],[],[],[],[2],[],[],[],[1],[],[1],[],[],[],[2],[],[],
[3,6],[1,10,16],[],[1],[],[1],[],[],[],[1],[],[1],[],[],[],[],[],[],[],[],[],
[2,4,5],[],[3],[],[],[],[],[],[],[],[],[],[],[],[1],[],[],[],[1],[],[1],[4],[],
[],[1],[],[],[],[],[],[],[1],[],[],[],[],[],[],[1],[],[1],[],[1],[],[1],[],[],
[],[1],[],[],[4],[],[],[],[],[],[],[],[],[],[],[],[1,3],[],[],[],[],[1],[],
[1],[],[1],[],[],[],[],[],[],[],[1],[],[],[],[],[],[],[],[],[],[1],[],[],[],
[],[],[],[],[1],[],[],[],[1],[],[],[2],[4],[],[1],[],[],[],[],[],[1],[],[],[],
[],[],[5,8],[],[4],[],[],[],[],[],[1],[2],[],[],[1],[],[],[],[],[],[1],[],[2],
[],[],[],[1],[],[],[],[],[],[1],[],[1],[2],[],[],[],[],[1],[]]));


# This function returns a list of all nontrivial decompositions of the
# integer <A>n</A> as a power of integers.
BindGlobal("PowerDecompositions",function(n)
local d,i,r;
  i:=2;
  d:=[];
  repeat
    r:=RootInt(n,i);
    if n=r^i then
      Add(d,[r,i]);
    fi;
    i:=i+1;
  until r<2;
  return d;
end);

InstallGlobalFunction(MaximalSubgroupsSymmAlt,function(arg)
local G,max,dom,n,A,S,issn,p,i,j,m,k,powdec,pd,gps,v,invol,sel,mf,l,prim;
  G:=arg[1];
  if Length(arg)>1 then
    prim:=arg[2];
  else
    prim:=false;
  fi;
  dom:=Set(MovedPoints(G));
  n:=Length(dom);
  if  ValueOption(NO_PRECOMPUTED_DATA_OPTION)=true or
   not PrimitiveGroupsAvailable(n) then
    return fail;
  fi;

  A:=AlternatingGroup(n);
  issn:=Size(A)<>Size(G);

  if n<3 then
    if n<=2 and not issn then
      return [];
    else
      return [TrivialSubgroup(G)];
    fi;
  fi;
  invol:=(1,2);

  if not issn then
    S:=SymmetricGroup(n);
  else
    S:=G;
  fi;
  max:=[];
  if issn then
    Add(max,A);
  fi;

  # types according to Liebeck,Praeger,Saxl paper:

  if not prim then
    # type (a): Intransitive
    # A_n is highly transitive, so we always get only one class

    # all partitions in 2 not equal parts
    p:=Filtered(Partitions(n,2),i->i[1]<>i[2]);
    for i in p do
      if issn then
        m:=DirectProduct(SymmetricGroup(i[1]),SymmetricGroup(i[2]));
      else
        if i[2]<2 then
          m:=AlternatingGroup(i[1]);
        else
          m:=DirectProduct(AlternatingGroup(i[1]),AlternatingGroup(i[2]));
          # add a double transposition
          m:=ClosureGroupAddElm(m,(1,2)(n-1,n));
          SetSize(m,Factorial(i[1])*Factorial(i[2])/2);
        fi;
      fi;
      Add(max,m);
    od;

    # type (b): Imprimitive
    # A_n is highly transitive, so we always get only one class

    # all possible block system sizes
    p:=Difference(DivisorsInt(n),[1,n]);
    for i in p do
      # exception: Table I, 1
      if n<>8 or i<>2 or issn then
        v:=Group(SmallGeneratingSet(SymmetricGroup(i)));
        SetSize(v,Factorial(i));
        k:=Group(SmallGeneratingSet(SymmetricGroup(n/i)));
        SetSize(k,Factorial(n/i));
        m:=WreathProduct(v,k);
        if not issn then
          m:=AlternatingSubgroup(m);
        fi;
        Add(max,m);
      fi;
    od;
  fi;

  # type (c): Affine
  p:=Factors(n);
  if Length(Set(p))=1 then
    k:=Length(p);
    p:=p[1];
    m:=GL(k,p);
    v:=AsSSortedList(GF(p)^k);
    m:=Action(m,v,OnRight);
    k:=First(v,i->not IsZero(i));
    m:=ClosureGroup(m,PermList(List(v,i->Position(v,i+k))));
    if Size(m)<Size(S) then
      if SignPermGroup(m)=1 then
        # it's a subgroup of A_n, but there are two classes
        # (the normalizer in S_n cannot increase)
        if not issn then
          Add(max,m);
          Add(max,m^invol);
        fi;
      else
        # the (intersection with A_n) is a maximal subgroup
        if issn then
          Add(max,m);
        else
          # exceptions: table I and Aff(3)=A3.
          if not n in [3,7,11,17,23] then
            m:=AlternatingSubgroup(m);
            Add(max,m);
          fi;
        fi;
      fi;
    fi;
  fi;

  # type (d): Diagonal

  powdec:=PowerDecompositions(n);
  gps:=IsomorphismTypeInfoFiniteSimpleGroup(n);
  if gps<>fail then
    pd:=Concatenation([[n,1]],powdec);
    for i in pd do
      if IsBound(gps.series) then
        if gps.series="A" then
          gps:=[AlternatingGroup(gps.parameter)];
        elif gps.series="L" then
          gps:=[PSL(gps.parameter[1],gps.parameter[2])];
        elif gps.series="Z" then
          gps:=[];
        fi;
      fi;
      if not IsList(gps) then
        Error("code for creation of simple groups not yet implemented");
      else
        # did we construct with some automorphisms?
        for j in [1..Length(gps)] do
          while Size(gps[j])>n do
            gps[j]:=DerivedSubgroup(gps[j]);
          od;
        od;
        gps:=List(gps,i->Image(SmallerDegreePermutationRepresentation(i:cheap)));
      fi;
      for j in gps do
        m:=DiagonalSocleAction(j,i[2]+1);
        m:=Normalizer(S,m);
        if issn then
          if SignPermGroup(m)=-1 then
            Add(max,m);
          fi;
        else
          if SignPermGroup(m)=-1 then
            Add(max,AlternatingSubgroup(m));
          else
            Add(max,m);
            Add(max,m^invol);
          fi;
        fi;
      od;
    od;
  fi;

  # type (e): Product type
  for i in powdec do
    if i[1]>4 then # up to s_4 we get a solvable normal subgroup
      m:=WreathProductProductAction(SymmetricGroup(i[1]),SymmetricGroup(i[2]));
      if issn then
        # add if not contained in A_n
        if SignPermGroup(m)=-1 then
          Add(max,m);
        fi;
      else
        if SignPermGroup(m)=1 then
          Add(max,m);
          # the wreath product is alternating, so the normalizer cannot grow
          # and there must be a second class
          Add(max,m^invol);
        else
          # the group is larger, so we have to intersect with A_n
          m:=AlternatingSubgroup(m);
          # but it might become imprimitive, use remark 2:
          if i[2]<>2 or 2<>(i[1] mod 4) or IsPrimitive(m,[1..n]) then
            Add(max,m);
          fi;
        fi;
      fi;
    fi;
  od;

  Info(InfoPerformance,2,"Using Primitive Groups Library");

  # type (f): Almost simple
  if not PrimitiveGroupsAvailable(n) then
    Error("tables missing");
  elif n>999 then
    # all type 2 nonalt groups of right parity
    k:=Factorial(n)/2;
    l:=CallFuncList(ValueGlobal("AllPrimitiveGroups"),
              [DegreeOperation,n,
                          i->Size(i)<k and IsNonabelianSimpleGroup(Socle(i))
                          and not IsAbelian(Socle(i)),true,
                          SignPermGroup,SignPermGroup(G)]);

    # remove obvious subgroups
    SortBy(l, Size);
    sel:=[];
    for i in [1..Length(l)] do
      if not ForAny([i+1..Length(l)],j->IsSubgroup(l[j],l[i])) then
        Add(sel,i);
      fi;
    od;
    l:=l{sel};

    # remove the LPS exceptions
    if n=8 then
      l:=Filtered(l,i->PrimitiveIdentification(i)<>4);
    elif n=36 then
      l:=Filtered(l,i->PrimitiveIdentification(i)<>5);
    elif n=144 then
      Error("144 exception");
    # this is the smallest 1/2q^4(q^2-1)^2. Its unlikely anyone will ever
    # try degrees that big.
    elif n>=28800 then
      Error("Possible Sp4(q) exception");
    fi;

    # go through all and test explicitly
    sel:=[1..Length(l)];
    mf:=[];
    for i in [Length(l),Length(l)-1..1] do
      if i in sel then
        Add(mf,l[i]);
        for j in [1..i] do
          #is there a permisomorphic primitive subgroup?
          k:=IsomorphicSubgroups(l[i],l[j]);
          k:=List(k,Image);
          if ForAny(k,x->IsTransitive(x,[1..n]) and IsPrimitive(x,[1..n]) and
                      PrimitiveIdentification(x)=PrimitiveIdentification(l[j]))
                      then
            RemoveSet(sel,j);
          fi;
        od;
      fi;
    od;
  else
    # use tables -- quicker
    if issn then
      mf:=List(SNMAXPRIMS[n],i->PrimitiveGroup(n,i));
    else
      mf:=List(ANMAXPRIMS[n],i->PrimitiveGroup(n,i));

    fi;
  fi;
  Append(max,mf);

  #An-split
  if not issn then
    for m in mf do
      # does the class split? If not, the normalizer gets bigger, i.e. there
      # is a larger primitive group in S_n
      k:=CallFuncList(ValueGlobal("AllPrimitiveGroups"),
       [NrMovedPoints,n,SocleTypePrimitiveGroup,
          SocleTypePrimitiveGroup(m),SignPermGroup,-1]);
      k:=List(k,AlternatingSubgroup);
      if ForAll(k,j->not IsTransitive(j,[1..n]) or not IsPrimitive(j,[1..n])
              or PrimitiveIdentification(j)<>PrimitiveIdentification(m)) then
        Add(max,m^invol);
      fi;
    od;
  fi;

  if dom<>[1..n] then
    # map on other points
    m:=MappingPermListList([1..n],dom);
    max:=List(max,i->i^m);
  fi;

  return max;
end);

InstallMethod( CalcMaximalSubgroupClassReps, "symmetric", true,
    [ IsNaturalSymmetricGroup and IsFinite], OVERRIDENICE,
function ( G )
local m;
  m:=MaximalSubgroupsSymmAlt(G,false);
  if m=fail then
    TryNextMethod();
  else
    return m;
  fi;
end);

InstallMethod( CalcMaximalSubgroupClassReps, "alternating", true,
    [ IsNaturalAlternatingGroup and IsFinite], OVERRIDENICE,
function ( G )
local m;
  m:=MaximalSubgroupsSymmAlt(G,false);
  if m=fail then
    TryNextMethod();
  else
    return m;
  fi;
end);

BindGlobal( "RadicalSymmAlt", function(G)
  if NrMovedPoints(G)<=4 then
    return G;
  else
    return TrivialSubgroup(G);
  fi;
end );

InstallMethod( SolvableRadical, "symmetric", true,
    [ IsNaturalSymmetricGroup and IsFinite], 0,RadicalSymmAlt);

InstallMethod( SolvableRadical, "alternating", true,
    [ IsNaturalAlternatingGroup and IsFinite], 0,RadicalSymmAlt);

InstallMethod(NormalSubgroups,
"for a symmetric group",
[IsSymmetricGroup],
{} -> RankFilter(IsPermGroup),
function(S)
  if SymmetricDegree(S) <= 4 then
    # S is soluble, so this includes the trivial group (and Klein 4)
    return DerivedSeriesOfGroup(S);
  fi;
  # DerivedSubgroup is the alternating group
  return [S, DerivedSubgroup(S), TrivialSubgroup(S)];
end);

InstallMethod(NormalSubgroups,
"for an alternating group",
[IsAlternatingGroup],
{} -> RankFilter(IsPermGroup),
function(A)
  if AlternatingDegree(A) <= 4 then
    # S is soluble, so this includes the trivial group (and Klein 4)
    return DerivedSeriesOfGroup(A);
  fi;
  return [A, TrivialSubgroup(A)];
end);
