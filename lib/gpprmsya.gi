#############################################################################
##
#W  gpprmsya.gi                 GAP Library                    Heiko Theissen
#W                                                           Alexander Hulpke
#W                                                           Martin Schoenert
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for symmetric and alternating groups
##
Revision.gpprmsya_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  IsNaturalAlternatingGroup( <sym> )
##
InstallMethod( IsNaturalAlternatingGroup,
    "size comparison",
    true,
    [ IsPermGroup ],
    0,

function( alt )
    if 0 = NrMovedPoints(alt)  then
        return IsTrivial(alt);
    else
        return Size(alt) * 2 = Factorial( NrMovedPoints(alt) );
    fi;
end );


#############################################################################
##
#M  <perm> in <nat-alt-grp>
##
InstallMethod( \in,"alternating",
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
        return SmallestMovedPointPerm(g) >= m[1]
           and LargestMovedPointPerm(g)  <= m[l];
    else
        return IsSubset( m, MovedPointsPerms([g]) );
    fi;
end );

InstallMethod(Random,"alternating group: floyd's algorithm",
  true,[IsNaturalAlternatingGroup],0,
function ( G )
    local   rnd,        # random permutation, result
            sgn,        # sign of the permutation so far
            tmp,        # temporary variable for swapping
	    deg,
	    mov,
            i,  k;      # loop variables

    # use Floyd\'s algorithm
    mov:=MovedPoints(G);
    deg:=Length(mov);
    rnd := [1..deg];
    sgn := 1;
    for i  in [1..deg-2] do
        k := Random( [ i .. deg] );
        tmp := rnd[i];
        rnd[i] := rnd[k];
        rnd[k] := tmp;
        if i <> k  then
            sgn := -sgn;
        fi;
    od;

    # make the permutation even
    if sgn = -1  then
        tmp := rnd[deg-1];
        rnd[deg-1] := rnd[deg];
        rnd[deg] := tmp;
    fi;

    # return the permutation
    return PermList( rnd )^MappingPermListList([1..deg],mov);
end);

#T special StabChain method?

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, <opr> ). . for alternating groups
##
InstallOtherMethod(RepresentativeOperationOp,true,
  [IsNaturalAlternatingGroup,IsObject, IsObject, IsFunction ], 0,
function ( G, d, e, opr )
local dom,sortfun,max,cd,ce,rep;
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
      max:=Maximum(LargestMovedPointPerm(d),LargestMovedPointPerm(e));
      cd:=ShallowCopy(Cycles(d,[1..max]));
      ce:=ShallowCopy(Cycles(e,[1..max]));
      Sort(cd,sortfun);
      Sort(ce,sortfun);
      rep:=MappingPermListList(Concatenation(cd),Concatenation(ce));
      if SignPerm(rep)=-1 then
        dom:=Difference(dom,Union(Concatenation(cd),Concatenation(ce)));
	if Length(dom)>1 then
	  rep:=rep*(dom[1],dom[2]);
	else
	  cd:=Filtered(cd,i->IsSubset(dom,i));
	  d:=CycleStructurePerm(d);
	  e:=PositionProperty([1..Length(d)],i->IsBound(d[i]) and
	    # cycle structure is shifted, so this is even length
	    # we need either to swap a pair of even cycles or to 3-cycle
	    # odd cycles
	    ((IsInt(i+1/2) and d[i]>1) or
	    (IsInt(i/2) and d[i]>2)));
	  if e=fail then
	    rep:=fail;
	  elif IsInt(e+1/2) then
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
      return rep;
    fi;
  elif (opr=OnSets or opr=OnTuples) and (IsList(d) and IsList(e)) then
    if Length(d)<>Length(e) then
      return fail;
    fi;
    if IsSubset(dom,Set(d)) and IsSubset(dom,Set(e)) then
      rep:=MappingPermListList(d,e);
    fi;
    if SignPerm(rep)=-1 then
      cd:=Difference(dom,e);
      if Length(cd)>1 then
        rep:=rep*(cd[1],cd[2]);
      elif opr=OnSets then
        if Length(d)>1 then
	  rep:=(d[1],d[2])*rep;
        else
	  rep:=fail; # set Length <2, maximal 1 further point in dom,impossible
	fi;
      else # opr=OnTuples, not enough points left
        rep:=fail;
      fi;
    fi;
    return rep;
  fi;
  TryNextMethod(); 
end);


InstallMethod(SylowSubgroupOp,"alternating",true,
  [IsNaturalAlternatingGroup, IsPosRat and IsInt],0,
function ( G, p )
    local   S,          # <p>-Sylow subgroup of <G>, result
            sgs,        # strong generating set of <G>
            q,          # power of <p>
            i,          # loop variable
	    trf,
	    mov,
	    deg;

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

    # add the stabilizer chain
    #MakeStabChainStrongGenerators( S, Reversed([1..G.degree]), sgs );

    # return the Sylow subgroup
    return S;
end);


InstallMethod(ConjugacyClasses,"alternating",true,
              [IsNaturalAlternatingGroup],0,
function ( G )
    local   classes,    # conjugacy classes of <G>, result
            prt,        # partition of <G>
            sum,        # partial sum of the entries in <prt>
            rep,        # representative of a conjugacy class of <G>
	    mov,deg,trf, # degree, moved points, transfer
            i;          # loop variable

    mov:=MovedPoints(G);
    deg:=Length(mov);
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


#############################################################################
##
#M  IsNaturalSymmetricGroup( <sym> )
##
InstallMethod( IsNaturalSymmetricGroup,
    "size comparison",
    true,
    [ IsPermGroup ],
    0,

function( sym )
    return Size(sym) = Factorial( NrMovedPoints(sym) );
end );


#############################################################################
##
#M  <perm> in <nat-sym-grp>
##
InstallMethod( \in,
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
        return SmallestMovedPointPerm(g) >= m[1]
           and LargestMovedPointPerm(g)  <= m[l];
    else
        return IsSubset( m, MovedPointsPerms([g]) );
    fi;
end );


#############################################################################
##
#M  Size( <nat-sym-grp> )
##
InstallMethod( Size,
    true,
    [ IsNaturalSymmetricGroup ],
    0,
    sym -> Factorial( NrMovedPoints(sym) ) );


InstallMethod(Random,"symmetric group: floyd's algorithm",
  true,[IsNaturalSymmetricGroup],0,
function ( G )
    local   rnd,        # random permutation, result
            sgn,        # sign of the permutation so far
            tmp,        # temporary variable for swapping
	    deg,
	    mov,
            i,  k;      # loop variables

    # use Floyd\'s algorithm
    mov:=MovedPoints(G);
    deg:=Length(mov);
    rnd := [1..deg];
    sgn := 1;
    for i  in [1..deg-2] do
        k := Random( [ i .. deg] );
        tmp := rnd[i];
        rnd[i] := rnd[k];
        rnd[k] := tmp;
    od;

    # return the permutation
    return PermList( rnd )^MappingPermListList([1..deg],mov);
end);

#############################################################################
##
#M  StabilizerOp( <nat-sym-grp>, <int>, OnPoints )
##
InstallOtherMethod( StabilizerOp,
    true,
    [ IsNaturalSymmetricGroup, IsPosRat and IsInt, IsFunction ],
    0,

function( sym, p, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return AsSubgroup( sym,
           SymmetricGroup( Difference( MovedPoints( sym ), [ p ] ) ) );
end );

InstallMethod(CentralizerOp,"element in symmetric group",
  IsCollsElms,[IsNaturalSymmetricGroup,IsPerm],0,
function ( G, g )
    local   C,          # centralizer of <g> in <G>, result
            sgs,        # strong generating set of <C>
            gen,        # one generator in <sgs>
            cycles,     # cycles of <g>
            cycle,      # one cycle from <cycles>
            lasts,      # '<lasts>[<l>]' is the last cycle of length <l>
            last,       # one cycle from <lasts>
	    mov,
            i;          # loop variable

    if not g in G then
      TryNextMethod();
    fi;

    # handle special case
    mov:=MovedPoints(G);

    # start with the empty strong generating system
    sgs := [];

    # compute the cycles and find for each length the last one
    cycles := Cycles( g, mov );
    lasts := [];
    for cycle  in cycles  do
      lasts[Length(cycle)] := cycle;
    od;

    # loop over the cycles
    for cycle  in cycles  do

      # add that cycle itself to the strong generators
      if Length( cycle ) <> 1  then
	  gen := MappingPermListList(cycle,
	            Concatenation(cycle{[2..Length(cycle)]},[cycle[1]]));
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

  # make the centralizer
  C := Subgroup(  G , sgs );

  # return the centralizer
  return C;
end);

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, <opr> ) .  . for symmetric groups
##
InstallOtherMethod(RepresentativeOperationOp,true,
  [IsNaturalSymmetricGroup,IsObject, IsObject, IsFunction ], 0,
function ( G, d, e, opr )
local dom,sortfun,max,cd,ce;
  dom:=Set(MovedPoints(G));
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
      max:=Maximum(LargestMovedPointPerm(d),LargestMovedPointPerm(e));
      cd:=ShallowCopy(Cycles(d,[1..max]));
      ce:=ShallowCopy(Cycles(e,[1..max]));
      Sort(cd,sortfun);
      Sort(ce,sortfun);
      return MappingPermListList(Concatenation(cd),Concatenation(ce));
    fi;
  elif (opr=OnSets or opr=OnTuples) and (IsList(d) and IsList(e)) then
    if Length(d)<>Length(e) then
      return fail;
    fi;
    if IsSubset(dom,Set(d)) and IsSubset(dom,Set(e)) then
      return MappingPermListList(d,e);
    fi;
  fi;
  TryNextMethod(); 
end);

InstallMethod(SylowSubgroupOp,"symmetric",true,
  [IsNaturalSymmetricGroup, IsPosRat and IsInt],0,
function ( G, p )
local   S,          # <p>-Sylow subgroup of <G>, result
	sgs,        # strong generating set of <G>
	q,          # power of <p>
	mov,deg,trf, # degree, moved points, transfer
	i;          # loop variable

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
    S := Subgroup(  G , sgs );

    # return the Sylow subgroup
    return S;
end);

InstallMethod(ConjugacyClasses,"symmetric",true,
              [IsNaturalSymmetricGroup],0,
function ( G )
    local   classes,    # conjugacy classes of <G>, result
            prt,        # partition of <G>
            sum,        # partial sum of the entries in <prt>
            rep,        # representative of a conjugacy class of <G>
	    mov,deg,trf, # degree, moved points, transfer
            i;          # loop variable

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

InstallMethod(IsomorphismFpGroup,"symmetric group",true,
  [IsNaturalSymmetricGroup],0,
function ( G )
local   F,      # free group
	gens,	#generators of F
	imgs,
	hom,	# bijection
	mov,deg,
	relators,
	i, k;       # loop variables

    mov:=MovedPoints(G);
    deg:=Length(mov);

    # create the finitely presented group with <G>.degree-1 generators
    F := FreeGroup( deg-1, Concatenation("S_",String(deg),".") );
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

    # compute the bijection
    imgs:=[];
    for i in [2..deg] do
      Add(imgs,(mov[i-1],mov[i]));
    od;

    hom:=GroupHomomorphismByImages(G,F,imgs,GeneratorsOfGroup(F));

    # return the finitely presented group
    return hom;
end);

#############################################################################
##
#M  PrintObj( <nat-sym-grp> )
##
InstallMethod( PrintObj,
    true,
    [ IsNaturalSymmetricGroup ],
    0,

function(sym)
    Print( "Sym( ", MovedPoints(sym), " )" );
end );


#############################################################################
##
#E  gpprmsya.gd  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
