#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Bettina Eick.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains some functions to convert a pc group into an
##  fp group and vice versa.
##

#############################################################################
##
#F  PcGroupFpGroup( F )
#F  PcGroupFpGroupNC( F )
##
InstallGlobalFunction( PcGroupFpGroup, function( F )
    return PolycyclicFactorGroup(
        FreeGroupOfFpGroup( F ),
        RelatorsOfFpGroup( F ) );
end );

InstallGlobalFunction( PcGroupFpGroupNC, function( F )
    return PolycyclicFactorGroupNC(
        FreeGroupOfFpGroup( F ),
        RelatorsOfFpGroup( F ) );
end );

#############################################################################
##
#F  IsomorphismFpGroupByPcgs( pcgs, str )
##
InstallGlobalFunction( IsomorphismFpGroupByPcgs, function( pcgs, str )
    local n, F, gens, rels, i, pis, exp, t, h, rel, comm, j, H, phi;

    n:=Length(pcgs);
    if n=0 then
      phi:=GroupHomomorphismByImagesNC(GroupOfPcgs(pcgs),
              TRIVIAL_FP_GROUP,[],[]);
      SetIsBijective( phi, true );
      return phi;
    fi;
    F    := FreeGroup( n, str );
    gens := GeneratorsOfGroup( F );
    pis  := RelativeOrders( pcgs );
    rels := [ ];
    for i in [1..n] do

        # the power
        exp := ExponentsOfRelativePower( pcgs, i ){[i+1..n]};
        t   := One( F );
        for h in [i+1..n] do
            t := t * gens[h]^exp[h-i];
        od;
        rel := gens[i]^pis[i] / t;
        Add( rels, rel );

        # the commutators
        for j in [i+1..n] do
            comm := Comm( pcgs[j], pcgs[i] );
            exp := ExponentsOfPcElement( pcgs, comm ){[i+1..n]};
            t   := One( F );
            for h in [i+1..n] do
                t := t * gens[h]^exp[h-i];
            od;
            rel := Comm( gens[j], gens[i] ) / t;
            Add( rels, rel );
        od;
    od;
    H := F / rels;
    SetSize(H,Product(RelativeOrders(pcgs)));
    phi :=
      GroupHomomorphismByImagesNC( GroupOfPcgs(pcgs), H, AsList( pcgs ),
                                        GeneratorsOfGroup( H ) );

    SetIsBijective( phi, true );
    ProcessEpimorphismToNewFpGroup(phi);
    return phi;

end );

#############################################################################
##
#M  IsomorphismFpGroupByCompositionSeries( G, str )
##
InstallOtherMethod( IsomorphismFpGroupByCompositionSeries, "pc groups",
               true, [IsGroup and CanEasilyComputePcgs,IsString], 0,
function( G,nam )
  return IsomorphismFpGroupByPcgs( Pcgs(G), nam );
end);

#############################################################################
##
#O  IsomorphismFpGroup( G )
##
InstallOtherMethod( IsomorphismFpGroup, "pc groups",
               true, [IsGroup and CanEasilyComputePcgs,IsString], 0,
function( G,nam )
  return IsomorphismFpGroupByPcgs( Pcgs( G ), nam);
end );

#############################################################################
##
#O  IsomorphismFpGroupByGeneratorsNC( G )
##
InstallMethod(IsomorphismFpGroupByGeneratorsNC,"pcgs",
  IsFamFamX,[IsGroup,IsPcgs,IsString],0,
function( G,p,nam )
  # this test now is obsolete but extremely cheap.
  if Product(RelativeOrders(p))<Size(G) then
    Error("pcgs does not generate the group");
  fi;
  return IsomorphismFpGroupByPcgs( p, nam);
end );

#############################################################################
##
#F  InitEpimorphismSQ( F )
##
InstallGlobalFunction( InitEpimorphismSQ, function( F )
local g, gens, r, rels, ng, nr, pf, pn, pp, D, M, Q, I, A, G, min,
gensA, relsA, gensG, imgs, prei, i, j, k, l, norm, index, diag, n,genu;

  if IsFpGroup(F) then
    gens := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
    ng   := Length( gens );
    genu:=List(gens,i->GeneratorSyllable(i,1));
    genu:=List([1..Maximum(genu)],i->Position(genu,i));
    rels := RelatorsOfFpGroup( F );
    nr   := Length( rels );

    # build the relation matrix for the commutator  quotient  group
    M := [];
    for i in [ 1..Maximum( nr, ng ) ] do
      M[i] := List( [ 1..ng ], i->0 );
      if i <= nr then
        r := rels[i];
        for j in [1..NrSyllables(r)] do
          g := GeneratorSyllable(r,j);
          k:=genu[g];
          M[i][k] := M[i][k] + ExponentSyllable(r,j);
        od;
      fi;
    od;

    # compute normal form
    norm := NormalFormIntMat( M,15 );
    D := norm.normal;
    Q := norm.coltrans;
    I := Q^-1;
    min := Minimum( Length(D), Length(D[1]) );
    diag := List( [1..min], x -> D[x][x] );
    if ForAny( diag, x -> x = 0 ) then
        Info(InfoSQ,1,"solvable quotient is infinite");
        return false;
    fi;

    # compute pc presentation for the finite quotient
    n := Filtered( diag, x -> x <> 1 );
    n := Length( Flat( List( n, x -> Factors(Integers, x ) ) ) );
    A := FreeGroup(IsSyllableWordsFamily, n );
    gensA := GeneratorsOfGroup( A );

    index := [];
    relsA := [];
    g := 1;
    pf := [];
    for i in [ 1..ng ] do
      if D[i][i] <> 1 then
        index[i] := g;
        pf[i] := TransposedMat( Collected( Factors(Integers, D[i][i] ) ) );
        pf[i] := rec( factors := pf[i][1],
        powers  := pf[i][2] );
        for j in [ 1..Length( pf[i].factors ) ] do
          pn := pf[i].factors[j];
          pp := pf[i].powers [j];
          for k in [ 1..pp ] do
            relsA[g] := [];
            relsA[g][g] := gensA[g]^pn;
            for l in [ 1..g-1 ] do
              relsA[g][l] := gensA[g]^gensA[l]/gensA[g];
            od;
            if j <> 1 or k <> 1 then
              relsA[g-1][g-1] := relsA[g-1][g-1]/gensA[g];
            fi;
            g := g + 1;
          od;
        od;
      fi;
    od;

    relsA := Flat( relsA );
    A     := A / relsA;

    # compute corresponding pc group
    G := PcGroupFpGroup( A );
    gensG := Pcgs( G );

    # set up epimorphism F -> A -> G
    imgs  := [];
    for i in [ 1..ng ] do
      imgs[i] := One( G );
      for j in [ 1..ng ] do
        if Q[i][j] <> 0 and D[j][j] <> 1 then
          imgs[i] := imgs[i] * gensG[index[j]]^( Q[i][j] mod D[j][j] );
        fi;
      od;
    od;

    # compute preimages
    prei := [];
    for i in [ 1..ng ] do
      if D[i][i] <> 1 then
        r := One( FreeGroupOfFpGroup( F ) );
        for j in [ 1..ng ] do
          if imgs[j] <> One( G ) then
            r := r * gens[j] ^ ( I[i][j] mod Order( imgs[j] ) );
          fi;
        od;
        g := index[i];
        for j in [ 1..Length( pf[i].factors ) ] do
          pn := pf[i].factors[j];
          pp := pf[i].powers [j];
          for k in [ 1..pp ] do
            prei[g] := r;
            g := g + 1;
            r := r ^ pn;
          od;
        od;
      fi;
    od;

    return rec( source := F,
                image  := G,
                imgs   := imgs,
                prei   := prei );
  elif IsMapping(F) then
    if IsSurjective(F) and IsWholeFamily(Range(F)) then
      return rec(source:=Source(F),
                image:=Parent(Image(F)), # parent will replace full group
                                         # with other gens.
                imgs:=List(GeneratorsOfGroup(Source(F)),
                            i->Image(F,i)));
    else
      # ensure the image group is the whole family
      gensG:=Pcgs(Image(F));
      G:=GroupByPcgs(gensG);
      return rec(source:=Source(F),
                image:=G,
                imgs:=List(GeneratorsOfGroup(Source(F)),
                            i->PcElementByExponentsNC(FamilyPcgs(G),
                                 ExponentsOfPcElement(gensG,Image(F,i)))));
    fi;
  fi;
  Error("Syntax!");
end );

#############################################################################
##
#F  LiftEpimorphismSQ( epi, M, c )
##
InstallGlobalFunction( LiftEpimorphismSQ, function( epi, M, c )
    local F, G, pcgsG, n, H, pcgsH, d, gensf, pcgsN, htil, gtil, mtil,mtilinv,
          w, e, g, m, i, A, V, rel, l, v, mats, j, mat, k, elms, imgs,
          lift, null, vec, new, U, sol, sub, elm, r,tval,tvalp,
          ex,pos,i1,genid,rels,reln,stopi;

    F := epi.source;
    gensf := GeneratorsOfGroup( FreeGroupOfFpGroup( F ) );
    r := Length( gensf );

    genid:=[];
    for i in [1..r] do
      genid[GeneratorSyllable(gensf[i],1)]:=i;
    od;

    d := M.dimension;

    G := epi.image;
    pcgsG := Pcgs( G );
    n := Length( pcgsG );

    H := ExtensionNC( G, M, c );
    pcgsH := Pcgs( H );
    pcgsN := InducedPcgsByPcSequence( pcgsH, pcgsH{[n+1..n+d]} );


    htil := pcgsH{[1..n]};
    gtil := [];
    mtil := [];
    mtilinv:=[];
    for w in epi.imgs do
      e := ExponentsOfPcElement( pcgsG, w );
      g := PcElementByExponentsNC( pcgsH, htil, e );
      Add( gtil, g );
      m := ImmutableMatrix(M.field, IdentityMat( d, M.field ) );
      for i in [1..n] do
        m := m * M.generators[i]^e[i];
      od;
      Add( mtil,m);
      #Add( mtilinv, ImmutableMatrix(M.field,m^-1 ));
    od;
    mtilinv:=List(mtil,i->i^-1);

    # set up inhom eq
    A := List( [1..r*d], x -> [] );
    V := [];

    # for each relator of G add

    rels:=RelatorsOfFpGroup(F);

    stopi:=[4,8,15,30,200];
    AddSet(stopi,Length(rels));
    for reln in [1..Length(rels)] do
      if IsInt(reln/100) then
        Info(InfoSQ,2,reln);
      fi;

      rel:=rels[reln];
      l := NrSyllables( rel );

      # right hand side
      # was: v := MappedWord( rel, gensf, gtil );
      v:=One(gtil[1]);
      for i in [1..l] do
        j := genid[GeneratorSyllable(rel,i)];
        ex:=ExponentSyllable(rel,i);
        if ex<0 then
          v:=v/gtil[j]^(-ex);
        else
          v:=v*gtil[j]^ex;
        fi;
      od;

      v := ExponentsOfPcElement( pcgsN, v ) * One( M.field );
      Append( V, v );

      # left hand side
      mats := ListWithIdenticalEntries( r,
                  Immutable( NullMat( d, d, M.field ) ) );

      # ahulpke, 28-feb-00: it seems to be much more clever, to run
      # through this loop backwards. Then `MappedWord' can be replaced by
      # a multiplication
      # Similarly the iterated calls to `Subword' are very expensive - better
      # use the internal syllable indexing

      # tval is the product from position i on, tvalp the product from
      # position i+1 on (the tval of the last round)
      tval:=One(mats[1]);

      for i in [l,l-1..1] do
        j := genid[GeneratorSyllable(rel,i)];
        ex:=ExponentSyllable(rel,i);
        if ex<0 then
          pos:=false;
          ex:=-ex;
        else
          pos:=true;
        fi;
        for i1 in [1..ex] do
          tvalp:=tval;
          if pos then
            tval:=mtil[j]*tval;
            mat:=tvalp;
            mats[j] := mats[j] + mat;
          else
            tval:=mtilinv[j]*tval;
            mat := tval;
            mats[j] := mats[j] - mat;
          fi;
        od;
      od;

      for i in [1..r] do
          for j in [1..d] do
              k := d * (i-1) + j;
              Append( A[k], mats[i][j] );
          od;
      od;

      # do these tests several times earlier to speed up
      if reln in stopi then
        sol := SolutionMat( A, V );
        # if there is no solution, then there is no lift
        if sol=fail then
#T return value should be fail?
          if reln<Length(rels) then
            Info(InfoSQ,3,"early break:",reln);
          fi;
          return false;
        fi;
      fi;
    od;

    # create lift
    elms := [];
    for i in [1..r] do
        sub := - sol{[d*(i-1)+1..d*i]};
        elm := PcElementByExponentsNC( pcgsN, sub );
        Add( elms, elm );
    od;
    imgs := List( [1..r], x -> gtil[x] * elms[x] ) ;
    lift := rec( source := F,
                 image  := H,
                 imgs   := imgs );

    # in non-split case this is it
    if IsRowVector( c ) then return lift; fi;

    # otherwise check
    U    := Subgroup( H, imgs );
    if Size( U ) = Size( H )
     and c=0 then # c=0 is the ordinary case
      return lift;
    else
      lift:=false; # indicate the lift is no good
    fi;

    # this is not optimal - see Plesken
    null := NullspaceMat( A );
    Info(InfoSQ,2,"nullspace dimension:",Length(null));
    for vec in null do
        new  := vec + sol;
        elms := [];
        for i in [1..r] do
            sub := new{[d*(i-1)+1..d*i]};
            elm := PcElementByExponentsNC( pcgsN, sub );
            Add( elms, elm );
        od;
        imgs := List( [1..r], x -> gtil[x] * elms[x] );
        U    := Subgroup( H, imgs );
        if Size( U ) = Size( H ) then
          if lift<>false then
            Info(InfoSQ,2,"found one");
            lift:=SubdirProdPcGroups(H,imgs,
                                     lift.image,lift.imgs);
            H:=lift[1];
            imgs:=lift[2];
          fi;
          lift := rec( source := F,
                      image  := H,
                      imgs   := imgs );
          if c=0 then
            return lift;
          fi;
        fi;
    od;

    # give up
    return lift; # if c=0 this is automatically false
end );

#############################################################################
##
#F  BlowUpCocycleSQ( v, K, F )
##
InstallGlobalFunction( BlowUpCocycleSQ, function( v, K, F )
    local Q, B, vectors, hlp, i, k;

    if F = K then return v; fi;

    Q := AsField( K, F );
    B := Basis( Q );
    vectors:= BasisVectors( B );
    hlp := [];
    for i in [ 1..Length( v ) ] do
        for k in [ 1..Length( vectors ) ] do
            Add( hlp, Coefficients( B, v[i] * vectors[k] )[1] );
        od;
    od;
    return hlp;
end );

#############################################################################
##
#F  TryModuleSQ( epi, M )
##
InstallGlobalFunction( TryModuleSQ, function( epi, M )
    local  C, lift, co, cb, cc, r, q, ccpos, ccnum, l, v, qi, c;

    # first try a split extension
    lift := LiftEpimorphismSQ( epi, M, 0 );
    if not IsBool( lift ) then return lift; fi;

    # get collector
    C := CollectorSQ( epi.image, M.absolutelyIrreducible, true );

    # compute the two cocycles
    co := TwoCocyclesSQ( C, epi.image, M.absolutelyIrreducible );

    # if there is one non split extension,  try all mod coboundaries
    if 0 < Length(co) then
        cb := TwoCoboundariesSQ( C, epi.image, M.absolutelyIrreducible );

        # use only those coboundaries which lie in <co>
        if 0 < Length(C.avoid)  then
            cb := SumIntersectionMat( co, cb )[2];
        fi;

        # convert them into row spaces
        if 0 < Length(cb)  then
            cc  := BaseSteinitzVectors( co, cb ).factorspace;
        else
            cc := co;
        fi;

        # try all non split extensions
        if 0 < Length(cc)  then
            r  := PrimitiveRoot( M.absolutelyIrreducible.field );
            q  := Size( M.absolutelyIrreducible.field );

            # loop over all vectors of <cc>
            for ccpos in [ 1 .. Length(cc) ]  do
                for ccnum in [ 0 .. q^(Length(cc)-ccpos)-1 ]  do
                    v := cc[Length(cc)-ccpos+1];
                    for l in [ 1 .. Length(cc)-ccpos ]  do
                        qi := QuoInt( ccnum, q^(l-1) );
                        if qi mod q <> q-1  then
                            v := v + r^(qi mod q) * cc[l];
                        fi;
                    od;

                    # blow cocycle up
                    c := BlowUpCocycleSQ( v, M.field,
                         M.absolutelyIrreducible.field );

                    # try to lift epimorphism

                    lift := LiftEpimorphismSQ( epi, M, c);

                    # return if we have found a lift
                    if not IsBool( lift ) then return lift; fi;

                od;
            od;
        fi;
    fi;

    # give up
    return false;
end );

#############################################################################
##
#F  AllModulesSQ( epi, M )
##
InstallGlobalFunction( AllModulesSQ, function( epi, M,onlyact )
local  C, lift, co, cb, cc, r, q, ccpos, ccnum, l, v, qi,
       c,all,cnt,total,i,j,iter,sel,dim;

    iter:=onlyact<Length(Pcgs(epi.image)); # are we running in iteration?

    all:=epi;

    if not iter then
      # first try a split extension
      # the -1 indicates we want *all* sdps
      lift := LiftEpimorphismSQ( epi, M, -1 );
      if not IsBool( lift ) then
        all:=lift;
        Info(InfoSQ,2,"semidirect ",Size(all.image)/Size(epi.image)," found");
      fi;
    fi;

    # get collector
    dim:=M.absolutelyIrreducible.dimension;
    C := CollectorSQ( epi.image, M.absolutelyIrreducible, true );

    # compute the two cocycles
    co := TwoCocyclesSQ( C, epi.image, M.absolutelyIrreducible );

    # if there is one non split extension,  try all mod coboundaries
    if 0 < Length(co) then
        cb := TwoCoboundariesSQ( C, epi.image, M.absolutelyIrreducible );

        q:=false;
        if iter and Length(cb)>0 then
          # we only want those cocycles, which are trivial for the extra
          # generators
          # find those indices which can have nontrivial cocycles
          r:=Length(Pcgs(epi.image));
          v:=[1..dim];
          sel:=[];
          for i in [1..r] do
            for j in [1..Minimum(i,onlyact)] do
              UniteSet(sel,((i^2-i)/2+j-1)*dim+v);
            od;
          od;
          v:=IdentityMat(Length(co[1]),M.absolutelyIrreducible.field){sel};
          v:=ImmutableMatrix(M.absolutelyIrreducible.field,v);

          r:=SumIntersectionMat(v,co)[2];
          if Length(r)<Length(co) then
            Info(InfoSQ,1,"don't need all cocycles/reduced cohomology");
            co:=r;
            q:=true; # use as flag whether it got changed
          fi;
        fi;

        # use only those coboundaries which lie in <co>
        if 0 < Length(C.avoid) or q then
            cb := SumIntersectionMat( co, cb )[2];
        fi;

        # representatives for basis for the 2-cohomology
        if 0 < Length(cb)  then
            cc  := BaseSteinitzVectors( co, cb ).factorspace;
        else
            cc := co;
        fi;

        # try all non split extensions
        if 0 < Length(cc)  then

            r  := PrimitiveRoot( M.absolutelyIrreducible.field );
            q  := Size( M.absolutelyIrreducible.field );

            total:=Int(q^Length(cc)/(q-1)); # approximately
            cnt:=0;
            # loop over all vectors of <cc>
            for ccpos in [ 1 .. Length(cc) ]  do
                for ccnum in [ 0 .. q^(Length(cc)-ccpos)-1 ]  do
                  cnt:=cnt+1;
                  if cnt mod 10 =0 then
                    CompletionBar(InfoSQ,2,"cocycle loop: ",cnt/total);
                  fi;
                  v := cc[Length(cc)-ccpos+1];
                  for l in [ 1 .. Length(cc)-ccpos ]  do
                    qi := QuoInt( ccnum, q^(l-1) );
                    if qi mod q <> q-1  then
                      v := v + r^(qi mod q) * cc[l];
                    fi;
                  od;

                  # blow cocycle up
                  c := BlowUpCocycleSQ( v, M.field,
                        M.absolutelyIrreducible.field );

                  # try to lift epimorphism

                  lift := LiftEpimorphismSQ( epi, M, c);

                  # return if we have found a lift
                  if not IsBool( lift ) then
                    lift:=SubdirProdPcGroups(all.image,all.imgs,
                                              lift.image,lift.imgs);
                    all:=rec(source:=epi.source,
                              image:=lift[1],
                              imgs:=lift[2]);
                    Info(InfoSQ,2,"locally ",Size(all.image)/Size(epi.image),
                          " found");
                  fi;

                od;
            od;
        fi;
        CompletionBar(InfoSQ,2,"cocycle loop: ",false);
    fi;

    # return all lifts
    return all;
end );

#############################################################################
##
#F  TryLayerSQ( epi, layer )
##
InstallGlobalFunction( TryLayerSQ, function( epi, layer )
    local field, dim, reps, rep, lift;

    # compute modules for prime
    field := GF(layer[1]);
    dim   := layer[2];
    reps  := IrreducibleModules( epi.image, field, dim );
    reps:=reps[2]; # the actual modules

    # loop over the representations
    for rep in reps do
        lift := TryModuleSQ( epi, rep );
        if not IsBool( lift ) then
           if not layer[3] or rep.dimension = dim then
               return lift;
           fi;
        fi;
    od;

    # give up
    return false;
end );

#############################################################################
##
#F  EAPrimeLayerSQ( epi, prime )
##
InstallGlobalFunction( EAPrimeLayerSQ, function( epi, prime )
local field, dim, rep, lift,all,dims,allmo,mo,start,found,genum,genepi;

  # compute modules for prime
  field := GF(prime);
  start:=epi;
  dims:=List(CharacterDegrees(epi.image,prime),i->i[1]);

  genum:=Length(Pcgs(epi.image)); # number of generators of the starting
                                  # group. (We need to consider nontrivial
                                  # cocycles only for those elements, as we
                                  # only want to get one layer.)
  # build all modules
  allmo:=[];
  for dim in dims do
    rep  := IrreducibleModules( epi.image, field, dim );
    rep:=rep[2]; # the actual modules
    rep:=Filtered(rep,i->i.dimension=dim);
    Info(InfoSQ,1,"Dimension ",dim,", ",Length(rep)," modules");
    allmo[dim]:=rep;
  od;

  repeat # extend as long as possible
    all:=epi;
    genepi:=Length(Pcgs(epi.image));
    found:=false;
    for dim in dims do
      # loop over the representations
      for rep in [1..Length(allmo[dim])] do
        Info(InfoSQ,2,"Module representative ",dim," #",rep);
        mo:=allmo[dim][rep];

        # inflate to extra generators
        if genum<genepi then
          mo:=GModuleByMats(Concatenation(mo.generators,
             List([1..genepi-genum],
                  i->One(mo.generators[1]))),field);
          if allmo[dim][rep].absolutelyIrreducible=allmo[dim][rep] then
            mo.absolutelyIrreducible:=mo;
          else
            mo.absolutelyIrreducible:=GModuleByMats(
              Concatenation(allmo[dim][rep].absolutelyIrreducible.generators,
              List([1..genepi-genum],
                  i->One(allmo[dim][rep].absolutelyIrreducible.generators[1]))),
                  allmo[dim][rep].absolutelyIrreducible.field);
          fi;
        fi;

        lift := AllModulesSQ( epi, mo,genum);
        if Size(lift.image)>Size(epi.image) then
          found:=true;
          lift:=SubdirProdPcGroups(all.image,all.imgs,
                                    lift.image,lift.imgs);
          all:=rec(source:=epi.source,
                    image:=lift[1],
                    imgs:=lift[2]);
          Info(InfoSQ,1,"globally ",Size(all.image)/Size(start.image)," found");
        fi;
      od;

    od;
    epi:=all;
  until not found;

  return all;
end );

#############################################################################
##
#F  SQ( <F>, <...> ) / SolvableQuotient( <F>, <...> )
##
InstallGlobalFunction( SolvableQuotient, function ( F, primes )
local G, epi, tup, lift, i, found, fac, j, p, iso;

    # initialise epimorphism
    epi := InitEpimorphismSQ(F);
    if epi=false then
      if 0 in AbelianInvariants(F) then
        Error("Group has infinite abelian quotient");
      else
        Error("initialization failed");
      fi;
    fi;
    iso := IsomorphismSpecialPcGroup( epi.image );
    epi.image := Image( iso );
    epi.imgs := List( epi.imgs, x -> Image( iso, x ) );
    G   := epi.image;
    Info(InfoSQ,1,"init done, quotient has size ",Size(G));

    # if the commutator factor group is trivial return
    if Size( G ) = 1 then return epi; fi;

    # if <primes> is a list of tuples, it denotes a chief series
    if IsList( primes ) and IsList( primes[1] ) then

        Info(InfoSQ,2,"have chief series given");
        for tup in primes{[2..Length(primes)]} do
            Info(InfoSQ,1,"trying ", tup);
            tup[3] := true;
            lift := TryLayerSQ( epi, tup );
            if IsBool( lift ) then
                return epi;
            else
                epi := ShallowCopy( lift );
                iso := IsomorphismSpecialPcGroup( epi.image );
                epi.image := Image( iso );
                epi.imgs := List( epi.imgs, x -> Image( iso, x ) );
                G   := epi.image;
            fi;
            Info(InfoSQ,1,"found quotient of size ", Size(G));
        od;

    # if <primes> is a list of primes, we have to use try and error
    elif IsList( primes ) and IsInt( primes[1] ) then
        found := true;
        i     := 1;
        while found and i <= Length( primes ) do
            p := primes[i];
            tup := [p, 0, false];
            Info(InfoSQ,1,"trying ", tup);
            lift := TryLayerSQ( epi, tup );
            if not IsBool( lift ) then
                epi := ShallowCopy( lift );
                iso := IsomorphismSpecialPcGroup( epi.image );
                epi.image := Image( iso );
                epi.imgs := List( epi.imgs, x -> Image( iso, x ) );
                G := epi.image;
                found := true;
                i := 1;
            else
                i := i + 1;
            fi;
            Info(InfoSQ,1,"found quotient of size ", Size(G));
        od;

    # if <primes> is an integer it is size we want
    elif IsInt(primes)  then
        if not IsInt(primes/Size(G)) then
          i:=Lcm(primes,Size(G));
          Info(InfoWarning,1,"Added extra factor ",i/primes,
               " to allow for G/G'");
          primes:=i;
        fi;
        i := primes / Size( G );
        found := true;
        while i > 1 and found do
            fac := Collected( Factors(Integers, i ) );
            found := false;
            j := 1;
            while not found and j <= Length( fac ) do
                fac[j][3] := false;
                Info(InfoSQ,1,"trying ", fac[j]);
                lift := TryLayerSQ( epi, fac[j] );
                if not IsBool( lift ) then
                    epi := ShallowCopy( lift );
                    iso := IsomorphismSpecialPcGroup( epi.image );
                    epi.image := Image( iso );
                    epi.imgs := List( epi.imgs, x -> Image( iso, x ) );
                    G := epi.image;
                    found := true;
                    i := primes / Size( G );
                else
                    j := j + 1;
                fi;
                Info(InfoSQ,1,"found quotient of size ", Size(G));
            od;
        od;
    else
        Error("<primes> must be either an integer, a list of integers, or a list of integer lists");
    fi;

    # this is the result - should be G only with set epimorphism
    return epi;
end );

InstallGlobalFunction(EpimorphismSolvableQuotient,function(arg)
local g, sq, hom;
  g:=arg[1];
  sq:=CallFuncList(SQ,arg);
  hom:=GroupHomomorphismByImages(g,sq.image,GeneratorsOfGroup(g),sq.imgs);
  SetIsSurjective( hom, true );
  if HasSize(g) then
    SetIsInjective(hom, Size(g)=Size(sq.image));
  fi;
  return hom;
end);


