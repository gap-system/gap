#############################################################################
##
#W  grppc.gi                    GAP Library                      Frank Celler
#W                                                             & Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for groups with a polycyclic collector.
##
Revision.grppc_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  CanonicalPcgsWrtFamilyPcgs( <grp> )
##
InstallMethod( CanonicalPcgsWrtFamilyPcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,

function( grp )
    local   cgs;

    cgs := CanonicalPcgs( InducedPcgsWrtFamilyPcgs(grp) );
    if cgs = FamilyPcgs(grp)  then
        SetIsWholeFamily( grp, true );
    fi;
    return cgs;
end );


#############################################################################
##
#M  CanonicalPcgsWrtHomePcgs( <grp> )
##
InstallMethod( CanonicalPcgsWrtHomePcgs,
    true,
    [ IsGroup and HasHomePcgs ],
    0,

function( grp )
    return CanonicalPcgs( InducedPcgsWrtHomePcgs(grp) );
end );


#############################################################################
##
#M  InducedPcgsWrtFamilyPcgs( <grp> )
##
InstallMethod( InducedPcgsWrtFamilyPcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,

function( grp )
    local   pa,  igs;

    pa := FamilyPcgs(grp);
    if HasPcgs(grp) and IsInducedPcgs(Pcgs(grp))  then
        if pa = ParentPcgs(Pcgs(grp))  then
            return Pcgs(grp);
        fi;
    fi;
    igs := InducedPcgsByGenerators( pa, GeneratorsOfGroup(grp) );
    if igs = pa  then
        SetIsWholeFamily( grp, true );
    fi;
    return igs;
end );


#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <grp> )
##
InstallMethod( InducedPcgsWrtHomePcgs, "default method",
    true,
    [ IsGroup and HasHomePcgs ],
    0,

function( grp )
    if HasPcgs(grp) and IsInducedPcgs(Pcgs(grp))  then
        if HomePcgs(grp) = ParentPcgs(Pcgs(grp))  then
            return Pcgs(grp);
        fi;
    fi;
    return InducedPcgsByGenerators( HomePcgs(grp), GeneratorsOfGroup(grp) );
end );


#############################################################################
##
#M  Pcgs( <pcgrp> )
##
InstallMethod( Pcgs,
    true,
    [ IsGroup and HasFamilyPcgs ],
    0,
    InducedPcgsWrtFamilyPcgs );


InstallMethod( Pcgs,
    true,
    [ IsGroup and HasHomePcgs ],
    1,
    InducedPcgsWrtHomePcgs );


#############################################################################
##
#M  Pcgs( <whole-family-grp> )
##
InstallMethod( Pcgs,
    true,
    [ IsGroup and HasFamilyPcgs and IsWholeFamily ],
    0,

function( grp )
    return FamilyPcgs(grp);
end );


#############################################################################
##
#M  Subgroup Methods
##
InstallSubgroupMethod(
    HasHomePcgs,
    IsObject,

function( G, S )
    SetHomePcgs( S, HomePcgs(G) );
    SetIsPcgsComputable( S, true );
end );


InstallSubgroupMethod(
    HasFamilyPcgs,
    IsObject,

function( G, S )
    SetFamilyPcgs( S, FamilyPcgs(G) );
    SetIsPcgsComputable( S, true );
end );


#############################################################################
##
#M  GroupByRws Methods
##
InstallGroupByRwsMethod(
    IsPolycyclicCollector,
    IsObject,

function( rws, grp )
    SetFamilyPcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
    SetHomePcgs( grp, DefiningPcgs( ElementsFamily(FamilyObj(grp)) ) );
end );


#############################################################################
##
#M  Group Methods
##
InstallGroupMethod(
    IsList,
    IsPcGroup,

function( coll, grp )
    SetFamilyPcgs( grp, DefiningPcgs( FamilyObj( One(grp) ) ) );
    SetHomePcgs( grp, DefiningPcgs( FamilyObj( One(grp) ) ) );
end );


#############################################################################
##

#M  <elm> in <pcgrp>
##
InstallMethod( \in,
    "for pcgs computable groups",
    IsElmsColls,
    [ IsMultiplicativeElementWithInverse,
      IsGroup and HasFamilyPcgs and IsPcgsComputable
    ],
    0,

function( elm, grp )
    return SiftedPcElement(InducedPcgsWrtFamilyPcgs(grp),elm) = One(grp);
end );


#############################################################################
##
#M  <pcgrp1> = <pcgrp2>
##
InstallMethod( \=,
    "pcgs computable groups using home pcgs",
    IsIdentical,
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( left, right )
    if HomePcgs(left) <> HomePcgs(right)  then
        TryNextMethod();
    fi;
    return CanonicalPcgsWrtHomePcgs(left) = CanonicalPcgsWrtHomePcgs(right);
end );


#############################################################################
##
#M  <pcgrp1> = <pcgrp2>
##
InstallMethod( \=,
    "pcgs computable groups using family pcgs",
    IsIdentical,
    [ IsGroup and HasFamilyPcgs,
      IsGroup and HasFamilyPcgs ],
    0,

function( left, right )
    if FamilyPcgs(left) <> FamilyPcgs(right)  then
        TryNextMethod();
    fi;
    return CanonicalPcgsWrtFamilyPcgs(left)
         = CanonicalPcgsWrtFamilyPcgs(right);
end );


#############################################################################
##
#M  IsSubgroup( <pcgrp>, <pcsub> )
##
InstallMethod( IsSubgroup,
    "pcgs computable groups",
    IsIdentical,
    [ IsGroup and HasFamilyPcgs and IsPcgsComputable,
      IsGroup ],
    0,

function( grp, sub )
    local   pcgs,  id,  g;

    pcgs := InducedPcgsWrtFamilyPcgs(grp);
    id   := One(grp);
    for g  in GeneratorsOfGroup(sub)  do
        if SiftedPcElement( pcgs, g ) <> id  then
            return false;
        fi;
    od;
    return true;

end );


#############################################################################
##

#F  VectorSpaceByPcgsOfElementaryAbelianGroup( <pcgs>, <f> )
##
VectorSpaceByPcgsOfElementaryAbelianGroup := function( arg )
    local   pcgs,  dim,  field;

    pcgs := arg[1];
    dim  := Length( pcgs );
    if IsBound( arg[2] ) then
        field := arg[2];
    elif dim > 0 then 
        field := GF( RelativeOrderOfPcElement( pcgs, pcgs[1] ) );
    else
        Error("trivial vectorspace, need field \n");
    fi;
    return VectorSpace( field, IdentityMat( dim, field ) );
end;


#############################################################################
##
#F  LinearOperationLayer( <G>, <pcgs>  )
##
LinearOperationLayer := function( G, pcgs )
    local V, field, linear;

    V := VectorSpaceByPcgsOfElementaryAbelianGroup( pcgs );
    field := LeftActingDomain( V );
    linear := function( x, g ) 
              return ExponentsOfPcElement( pcgs,
                     PcElementByExponents( pcgs, x )^g ) * One(field);
              end;
    return LinearOperation( G, V, linear );
end;

    
#############################################################################
##
#F  AffineOperationLayer( <G>, <pcgs>, <transl> )
##
AffineOperationLayer := function( G, pcgs, transl )
    local V, field, linear;

    if Length( pcgs ) = 0 then 
        Error("layer is trivial . . . field is not defined \n");
    fi;
    V := VectorSpaceByPcgsOfElementaryAbelianGroup( pcgs );
    field := LeftActingDomain( V );
    linear := function( x, g ) 
              return ExponentsOfPcElement( pcgs, 
                     PcElementByExponents( pcgs, x )^g ) * One(field);
              end;
    return AffineOperation( G, V, linear, transl );
end;


#############################################################################
##

#M  AffineOperation( <G>, <V>, <linear>, <transl> )
##
InstallMethod( AffineOperation,
    true, 
    [ IsGroup,
      IsVectorSpace,
      IsFunction,
      IsFunction ],
    0,

function( G, V, linear, transl )
    local mats, gens, field, g, mat, i, vec;

    mats := [];
    gens := BasisVectors( Basis( V ) );
    field := LeftActingDomain(V);
    for g  in GeneratorsOfGroup(G)  do
        mat := List( gens, x -> linear( x, g ) );
        vec := transl(g);
        for i  in [ 1 .. Length(mat) ]  do
            Add( mat[i], Zero(field) );
        od;
        Add( vec, One(field) );
        Add( mat, vec );
        Add( mats, mat );
    od;
    return mats;

end );

#############################################################################
##
#M  ClosureGroup( <U>, <H> )
##
##  use home pcgs
##
InstallMethod( ClosureGroup,
    "groups with home pcgs",
    IsIdentical, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( U, H )
    local   home,  pcgsU,  pcgsH,  new,  N;

    home := HomePcgs( U );
    if home <> HomePcgs( H ) then
        TryNextMethod();
    fi;
    pcgsU := InducedPcgsWrtHomePcgs(U);
    pcgsH := InducedPcgsWrtHomePcgs(H);
    if Length( pcgsU ) < Length( pcgsH )  then
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsH, 
               GeneratorsOfGroup( U ) );
    else
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsU,
               GeneratorsOfGroup( H ) );
    fi;
    N := Subgroup( GroupOfPcgs( home ), new );
    SetHomePcgs( N, home );
    SetInducedPcgsWrtHomePcgs( N, new );
    return N;

end );


#############################################################################
##
#M  ClosureGroup( <U>, <g> )
##
##  use home pcgs
##
InstallMethod( ClosureGroup,
    "groups with home pcgs",
    IsCollsElms,
    [ IsGroup and HasHomePcgs,
      IsMultiplicativeElementWithInverse ],
    0,

function( U, g )
    local   home,  pcgsU,  new,  N;

    home  := HomePcgs( U );
    pcgsU := InducedPcgsWrtHomePcgs( U );
    if not g in GroupOfPcgs( home ) then
        TryNextMethod();
    fi;
    if g in U  then
        return U;
    else
        new := InducedPcgsByPcSequenceAndGenerators( home, pcgsU, [g] );
        N   := Subgroup( GroupOfPcgs(home), new );
        SetHomePcgs( N, home );
        SetInducedPcgsWrtHomePcgs( N, new );
        return N;
    fi;

end );


#############################################################################
##
#M  CommutatorSubgroup( <U>, <V> )
##
InstallMethod( CommutatorSubgroup,
    "groups with home pcgs",
    true, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( U, V )
    local   pcgsU,  pcgsV,  home,  C,  u,  v,  tmp;

    # check 
    home := HomePcgs(U);
    if home <> HomePcgs( V ) then
        TryNextMethod();
    fi;
    pcgsU := InducedPcgsWrtHomePcgs(U);
    pcgsV := InducedPcgsWrtHomePcgs(V);

    # catch trivial cases
    if Length(pcgsU) = 0 or Length(pcgsV) = 0  then
        return TrivialSubgroup( GroupOfPcgs(home) );
    fi;
    if U = V  then
        return DerivedSubgroup(U);
    fi;

    # compute commutators
    C := [];
    for u  in pcgsU  do
        for v  in pcgsV  do
            AddSet( C, Comm( v, u ) );
        od;
    od;
    C := Subgroup( GroupOfPcgs( home ), C );
    C := NormalClosure( ClosureGroup(U,V), C );

    # that's it
    return C;

end );


#############################################################################
##
#M  ConjugateSubgroup( <U>, <g> )
##
InstallMethod( ConjugateSubgroup, 
    "groups with home pcgs",
    IsCollsElms,
    [ IsGroup and HasHomePcgs,
      IsMultiplicativeElementWithInverse ],
    0,

function( U, g )
    local   pcgs,  id,  a,  pag,  home,  h,  d,  N;

    # shift <a> through <U>
    pcgs := InducedPcgsWrtHomePcgs( U );
    id   := Identity( U );
    a    := SiftedPcElement( pcgs, g );

    # catch trivial case
    if IsEmpty(pcgs) or a = id then
        return U;
    fi;

    # <g> must lie in the home
    home := HomePcgs( U );
    if not g in GroupOfPcgs(home)  then
        TryNextMethod();
    fi;

    # conjugate generators
    pag := [];
    for h  in Reversed( pcgs ) do
        h := h ^ a;
        d := DepthOfPcElement( home, h );
        while h <> id and IsBound( pag[d] )  do
            h := ReducedPcElement( home, h, pag[d] );
            d := DepthOfPcElement( home, h );
        od;
        if h <> id  then
            pag[d] := h;
        fi;
    od;

    # <pag> is an induced system
    pag := Compacted( pag );
    N   := Subgroup( GroupOfPcgs(home), pag );
    SetHomePcgs( N, home );
    pag := InducedPcgsByPcSequenceNC( home, pag );
    SetInducedPcgsWrtHomePcgs( N, pag );

    # maintain useful information
    RunIsomorphismImplications( U, N );

    return N;

end );


#############################################################################
##
#M  ConjugateSubgroups( <G>, <U> )
##
InstallMethod( ConjugateSubgroups, 
    "groups with home pcgs",
    IsIdentical, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( G, U )
    local pcgs, home, f, orb, i, L, res;

    # check the home pcgs are compatible
    home := HomePcgs(U);
    if home <> HomePcgs(G) then
        TryNextMethod();
    fi;

    # get a canonical pcgs for <U>
    pcgs := CanonicalPcgsWrtHomePcgs(U);

    # <G> operates on this <pcgs> via conjugation
    f := function( c, g )
        return CanonicalPcgs( HomomorphicInducedPcgs( home, c, g ) );
    end;

    # compute the orbit of <G> on <pcgs>
    orb := Orbit( G, pcgs, f );
    res := List( orb, x -> false );
    for i in [1..Length(orb)] do
        L := Subgroup( G, orb[i] );
        SetHomePcgs( L, home );
        SetInducedPcgsWrtHomePcgs( L, orb[i] );
        res[i] := L;
    od;
    return res;

end );


#############################################################################
##
#M  Core( <U>, <V> )
##
InstallMethod( Core,
    "pcgs computable groups",
    true, 
    [ IsGroup and IsPcgsComputable,
      IsGroup ],
    0,

function( V, U )
    local pcgsV, C, v, C, N;

    # catch trivial cases
    pcgsV := Pcgs(V);
    if IsSubgroup( U, V ) or IsTrivial(U) or IsTrivial(V)  then
        return U;
    fi;

    # start with <U>.
    C := U;

    # now  compute  intersection with all conjugate subgroups, conjugate with
    # all generators of V and its powers

    for v  in Reversed(pcgsV)  do
        repeat
            N := ConjugateSubgroup( C, v );
            if C <> N  then
                C := Intersection( C, N );
            fi;
        until C = N;
        if IsTrivial(C)  then
            return C;
        fi;
    od;
    return C;

end );


#############################################################################
##
#M  EulerianFunction( <G>, <n> )
##
InstallMethod( EulerianFunction,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable,
      IsPosRat and IsInt ],
    0,

function( G, n )
    local   spec,  first,  weights,  m,  i,  phi,  start,  
            next,  p,  d,  r,  j,  pcgsS,  pcgsN,  pcgsL,  mats,  
            modu,  max,  series,  comps,  sub,  new,  index,  order;

    spec := SpecialPcgs( G );
    if Length( spec ) = 0 then
        return 1;
    fi;
    first := LGFirst( spec );
    weights := LGWeights( spec );
    m := Length( spec );

    # the first head
    i := 1;
    phi := 1;
    while weights[first[i]][1] = 1 and weights[first[i]][2] = 1 do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        d     := next - start;
        r     := Length( Filtered( weights, x -> x[1] = 1 and x[3] = p ) );
        phi   := phi * p^( n * ( r - d ) ); 
        for j in [0..d-1] do
            phi := phi * (p^n - p^j);
        od;
        if phi = 0 then return 0; fi;
        i := i + 1;
    od;

    # the rest
    while i <= Length( first ) - 1 do
        start := first[i];
        next  := first[i+1];
        p := weights[start][3];
        d := next - start;
        if weights[start][2] = 1 then
            pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            pcgsL := pcgsS mod pcgsN;
            mats  := LinearOperationLayer( G, pcgsL );
            modu  := GModuleByMats( mats,  GF(p) );
            max   := MTX.BasesMaximalSubmodules( modu );
            
            # compute series
            series := [IdentityMat(d, GF(p))];
            comps  := [];
            sub    := series[1];
            while Length( max ) > 0 do
                sub := SumIntersectionMat( sub, max[1] )[2];
                if Length( sub ) = 0 then
                    new := max;
                else
                    new := Filtered( max, x -> 
                                  RankMat( Concatenation( x, sub ) ) < d );
                fi;
                Add( comps, Sum( List( new, x -> p^(d - Length(x)) ) ) ); 
                Add( series, sub );
                max := Difference( max, new );
            od;

            # run down series
            for j in [1..Length( series )-1] do
                index := Length( series[j] ) - Length( series[j+1] );
                order := p^index;
                phi   := phi * ( order^n - comps[j] );
                if phi = 0 then return phi; fi;
            od;

            # only the radical is missing now
            index := Length( series[Length(series)] );
            order := p^index;
            phi := phi * (order^n);
            if phi = 0 then return 0; fi;
        else
            order := p^d;
            phi := phi * ( order^n );
            if phi = 0 then return 0; fi;
        fi;
        i := i + 1;
    od;
    return phi;

end );


#############################################################################
##
#M  LinearOperation( <G>, <V>, <linear>  )
##
InstallMethod( LinearOperation,
    true, 
    [ IsGroup,
      IsVectorSpace,
      IsFunction ],
    0,

function( G, V, linear )
    local  gens, base, mats;

    # catch trivial cases
    if IsTrivial(G)  then
        return true;
    fi;
    gens := GeneratorsOfGroup( G );

    # compute matrices
    base := BasisVectors( Basis( V ) );
    mats := List( gens, x -> List( base, y -> linear( y, x ) ) );
    return mats;

end );


#############################################################################
##
#M  NormalClosure( <G>, <U> )
##
InstallMethod( NormalClosure,
    "groups with home pcgs",
    true, 
    [ IsGroup and HasHomePcgs,
      IsGroup and HasHomePcgs ],
    0,

function( G, U )
    local   pcgs,  home,  gens,  subg,  id,  K,  M,  g,  u,  tmp;

    # catch trivial case
    pcgs := InducedPcgsWrtHomePcgs(U);
    if Length(pcgs) = 0 then
        return U;
    fi;
    home := HomePcgs(U);
    if home <> HomePcgs(G) then 
        TryNextMethod();
    fi;

    # get operating elements
    gens := GeneratorsOfGroup( G );
    gens := Set( List( gens, x -> SiftedPcElement( pcgs, x ) ) );

    subg := GeneratorsOfGroup( U );
    id   := Identity( G );
    K    := ShallowCopy( pcgs );
    repeat
        M := [];
        for g  in gens  do
            for u  in subg  do
                tmp := Comm( g, u );
                if tmp <> id  then
                    AddSet( M, tmp );
                fi;
            od;
        od;
        tmp  := InducedPcgsByPcSequenceAndGenerators( home, K, M );
        tmp  := CanonicalPcgs( tmp );
        subg := Filtered( tmp, x -> not x in K );
        K    := tmp;
    until 0 = Length(subg);

    K := Subgroup( GroupOfPcgs(home), tmp );
    SetHomePcgs( K, home );
    SetInducedPcgsWrtHomePcgs( K, tmp );
    return K;

end );


#############################################################################
##
#M  Random( <pcgrp> )
##
InstallMethod( Random,
    "pcgs computable groups",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function(grp)
    local   p;

    p := Pcgs(grp);
    return Product( p, x -> x^Random(1,RelativeOrderOfPcElement(p,x)) );
end );


#############################################################################
##
#M  Centralizer( <G>, <g> ) . . . . . . . . . . . . . .  using affine methods
##
InstallMethod( Centralizer,
    "pcgs computable groups",
    IsCollsElms,
    [ IsGroup and IsPcgsComputable and IsFinite,
      IsMultiplicativeElementWithInverse ],
    0,  # in solvable permutation groups, backtrack seems preferable
        
    function( G, g )
    return ClassesSolvableGroup( G, G, true, 0, g );
end );

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, OnPoints )   using affine methods
##
InstallOtherMethod( RepresentativeOperationOp,
    "element conjugacy in pcgs computable groups",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsFunction ],
    0,

function( G, d, e, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    fi;
    return ClassesSolvableGroup( G, G, true, 4, [ d, e ] );
end );

#############################################################################
##
#M  \<(G,H) . . . . . . . . . . . . . . . . .  comparison of pc groups by CGS
##
InstallMethod(\<,"cgs comparison",IsIdentical,[IsPcGroup,IsPcGroup],0,
function( G, H )
  return Reversed( CanonicalPcgsWrtFamilyPcgs(G) ) 
       < Reversed( CanonicalPcgsWrtFamilyPcgs(H) );
end);

#############################################################################
##
#F  GapInputPcGroup( <U>, <name> )  . . . . . . . . . . . .  gap input string
##
##  Compute  the  pc-presentation for a finite polycyclic group as gap input.
##  Return  this  input  as  string.  The group  will  be  named  <name>,the
##  generators "g<i>".
##
GapInputPcGroup:=function(U,name)

    local   gens,
            word,
            wordString,
            newLines,
            lines,
	    ne,
            i,j;


    # <lines>  will  hold  the  various  lines of the input for gap,they are
    # concatenated later.
    lines:=[];

    # Get the generators for the group <U>.
    gens:=InducedPcgsWrtHomePcgs(U);

    # Initialize the group and the generators.
    Add(lines,name);
    Add(lines,":=function()\nlocal ");
    for i in [1 .. Length(gens)]  do
        Add(lines,"g");
        Add(lines,String(i));
        Add(lines,",");
    od;
    Add(lines,"r,f,g,rws,x;\n");
    Add(lines,"f:=FreeGroup(");
    Add(lines,String(Length(gens)));
    Add(lines,");\ng:=GeneratorsOfGroup(f);\n");

    for i  in [1 .. Length(gens)]  do
        Add(lines,"g"          );
        Add(lines,String(i)  );
        Add(lines,":=g[");
        Add(lines,String(i)  );
        Add(lines,"];\n"    );
    od;

    Add(lines,"rws:=SingleCollector(f,");
    Add(lines,String(List(gens,i->RelativeOrderOfPcElement(gens,i))));
    Add(lines,");\n");

    Add(lines,"r:=[\n");
    # A function will yield the string for a word.
    wordString:=function(a)
        local k,l,list,str,count;
        list:=ExponentsOfPcElement(gens,a);
        k:=1;
        while k <= Length(list) and list[k] = 0  do k:=k + 1;  od;
        if k > Length(list)  then return "IdWord";  fi;
        if list[k] <> 1  then
            str:=Concatenation("g",String(k),"^",
                String(list[k]));
        else
            str:=Concatenation("g",String(k));
        fi;
        count:=Length(str) + 15;
        for l  in [k + 1 .. Length(list)]  do
            if count > 60  then
                str  :=Concatenation(str,"\n    ");
                count:=4;
            fi;
            count:=count - Length(str);
            if list[l] > 1  then
                str:=Concatenation(str,"*g",String(l),"^",
                    String(list[l]));
            elif list[l] = 1  then
                str:=Concatenation(str,"*g",String(l));
            fi;
            count:=count + Length(str);
        od;
        return str;
    end;

    # Add the power presentation part.
    for i  in [1 .. Length(gens)]  do
      ne:=gens[i]^RelativeOrderOfPcElement(gens,gens[i]);
      if ne<>One(U) then
        Add(lines,Concatenation("[",String(i),",",
            wordString(ne),"]"));
	if i<Length(gens) then
	  Add(lines,",\n");
	else
	  Add(lines,"\n");
	fi;
      fi;
    od;
    Add(lines,"];\nfor x in r do SetPower(rws,x[1],x[2]);od;\n");

    Add(lines,"r:=[\n");

    # Add the commutator presentation part.
    for i  in [1 .. Length(gens) - 1]  do
        for j  in [i + 1 .. Length(gens)]  do
	  ne:=Comm(gens[j],gens[i]);
	  if ne<>One(U) then
            if i <> Length(gens) - 1 or j <> i + 1  then
                Add(lines,Concatenation("[",String(j),",",String(i),",",
                    wordString(ne),"],\n"));
            else
                Add(lines,Concatenation("[",String(j),",",String(i),",",
                    wordString(ne),"]\n"));
            fi;
         fi;
       od;
    od;
    Add(lines,"];\nfor x in r do SetCommutator(rws,x[1],x[2],x[3]);od;\n");
    Add(lines,"return GroupByRwsNC(rws);\n");
    Add(lines,"end;\n");
    Add(lines,name);
    Add(lines,":=");
    Add(lines,name);
    Add(lines,"();\n");
    Add(lines,"Print(\"A group of order \",Size(");
    Add(lines,name);
    Add(lines,"),\" has been defined.\\n\");\n");
    Add(lines,"Print(\"It is called ");
    Add(lines,name);
    Add(lines,"\\n\");\n");

    # Concatenate all lines and return.
    while Length(lines) > 1  do
        if Length(lines) mod 2 = 1  then
            Add(lines,"");
        fi;
        newLines:=[];
        for i  in [1 .. Length(lines) / 2]  do
            newLines[i]:=Concatenation(lines[2*i-1],lines[2*i]);
        od;
        lines:=newLines;
    od;
    IsString(lines[1]);
    return lines[1];

end;

#############################################################################
##
#M  Enumerator( <G> ) . . . . . . . . . . . . . . . . . .  enumerator by pcgs
##
InstallMethod( Enumerator, true,
        [ IsGroup and IsPcgsComputable and IsFinite ], 0,
    G -> EnumeratorByPcgs( Pcgs( G ), [ 1 .. Length( Pcgs( G ) ) ] ) );

#############################################################################
##

#E  grppc.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
