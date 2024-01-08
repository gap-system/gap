#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Ákos Seress, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#M  PreImagesSet( <map>, <elms> ) .  for s.p. gen. mapping resp. mult. & inv.
##
InstallMethod( PreImagesSet,
    "method for permgroup homs",
    CollFamRangeEqFamElms,
    [ IsPermGroupHomomorphism, IsGroup ],
function( map, elms )
local genpreimages,  pre,kg,sz,ol,orb,pos,dom,one;
  genpreimages:=GeneratorsOfMagmaWithInverses( elms );

  genpreimages:= List(genpreimages,
                    gen -> PreImagesRepresentative( map, gen ) );
  if fail in genpreimages then
    TryNextMethod();
  fi;

  if HasFittingFreeLiftSetup(Source(map)) and
    IsIdenticalObj(map,FittingFreeLiftSetup(Source(map)).factorhom) then
    dom:=FittingFreeLiftSetup(Source(map));
    pre:=SubgroupByFittingFreeData(Source(map),genpreimages,
      GeneratorsOfMagmaWithInverses(elms),dom.pcgs);
    return pre;
  fi;

  if Length(genpreimages)>0 and CanEasilyCompareElements(genpreimages[1]) then
    # remove identities
    genpreimages:=Filtered(genpreimages,i->i<>One(i));
  fi;

  one:=One(Source(map));
  if HasSize( elms ) then
    sz:=Size( KernelOfMultiplicativeGeneralMapping( map ) ) * Size( elms );
    kg:=GeneratorsOfGroup(KernelOfMultiplicativeGeneralMapping( map ) );
    ol:=Concatenation(genpreimages,kg);
    dom:=MovedPoints(ol);
    ol:=Length(Orbits(Group(ol,one),dom));
    pre:=SubgroupNC(Source(map),genpreimages);
    orb:=List(Orbits(pre,dom),Set);
    pos:=0;
    while Length(orb)>ol do
      repeat
        pos:=pos+1;
      until ForAny(orb,x->OnSets(x,kg[pos])<>x);
      Add(genpreimages,kg[pos]);
      pre:=SubgroupNC(Source(map),genpreimages);
      orb:=List(Orbits(pre,dom),Set);
    od;

    StabChainOptions(pre).limit:=sz;
    while Size(pre)<sz do
      pre:=ClosureSubgroupNC(pre,First(kg,i->not i in pre));
    od;
  else
    pre := SubgroupNC( Source( map ), Concatenation(
              GeneratorsOfMagmaWithInverses(
                  KernelOfMultiplicativeGeneralMapping( map ) ),
              genpreimages ) );

    if     HasSize( KernelOfMultiplicativeGeneralMapping( map ) )
      and HasSize( elms )  then
        SetSize( pre, Size( KernelOfMultiplicativeGeneralMapping( map ) )
                * Size( elms ) );
    fi;
  fi;
  return pre;
end );

#############################################################################
##
#F  AddGeneratorsGenimagesExtendSchreierTree( <S>, <newlabs>, <newlims> ) . .
##
InstallGlobalFunction( AddGeneratorsGenimagesExtendSchreierTree,
    function( S, newlabs, newlims )
    local   old,        # genlabels before extension
            len,        # initial length of the orbit of <S>
            img,        # image during orbit algorithm
            i,  j;      # loop variables

    # check duplicates

    # Put in the new labels and labelimages.
    old := ShallowCopy( S.genlabels );
    UniteSet( S.genlabels, Length( S.labels ) + [ 1 .. Length( newlabs ) ] );
    Append( S.labels,      newlabs );  Append( S.generators,  newlabs );
    Append( S.labelimages, newlims );  Append( S.genimages,   newlims );

    # Extend the orbit and the transversal with the new labels.
    len := Length( S.orbit );
    i := 1;
    while i <= Length( S.orbit )  do
      for j  in S.genlabels  do
        # Use new labels for old points, all labels for new points.
        if i > len  or  not j in old  then
          img := S.orbit[ i ] / S.labels[ j ];
          if not IsBound( S.translabels[ img ] )  then
            S.translabels[ img ] := j;
            Add( S.orbit, img );
            if not IsBound(S.transversal[img]) then
              S.transversal[ img ] := S.labels[ j ];
              S.transimages[ img ] := S.labelimages[ j ];
            fi;
          fi;
        fi;
      od;
      i := i + 1;
    od;
end );

#############################################################################
##
#F  ImageSiftedBaseImage( <S>, <bimg>, <h> )   sift base image and find image
##
InstallGlobalFunction( ImageSiftedBaseImage, function( S, bimg, img, opr )
    local   base;

    base := BaseStabChain( S );
    while bimg <> base  do
        while bimg[ 1 ] <> base[ 1 ]  do
            img  := opr     ( img,  S.transimages[ bimg[ 1 ] ] );
            bimg := OnTuples( bimg, S.transversal[ bimg[ 1 ] ] );
        od;
        S := S.stabilizer;
        base := base{ [ 2 .. Length( base ) ] };
        bimg := bimg{ [ 2 .. Length( bimg ) ] };
    od;
    return img;
end );


#############################################################################
##
#F  CoKernelGensIterator( <hom> ) . . . . . . . . . . . . .  make this animal
##
BindGlobal( "IsDoneIterator_CoKernelGens",
    iter -> IsEmpty( iter!.level.genlabels ) and IsEmpty(iter!.trivlist));

BindGlobal( "NextIterator_CoKernelGens", function( iter )
    local   gen,  stb,  bimg,  rep,  pnt,  img,  j,  k;

    # do we have to take care of a trivlist?
    if not IsEmpty(iter!.trivlist) then
      j:=Length(iter!.trivlist);
      gen:=iter!.trivlist[j];
      Unbind(iter!.trivlist[j]);
      return gen;
    fi;

    # Make the current cokernel generator.
    stb := iter!.level;
    k := stb.genlabels[ iter!.genlabelNo ];
    gen := ImageSiftedBaseImage( stb,
                   OnTuples( iter!.bimg, stb.labels[ k ] ),
                   iter!.img * stb.labelimages[ k ], OnRight );

    # Move on the iterator: Next generator.
    iter!.genlabelNo := iter!.genlabelNo + 1;
    if iter!.genlabelNo > Length( stb.genlabels )  then
        iter!.genlabelNo := 1;

        # Next basic orbit point.
        iter!.pointNo := iter!.pointNo + 1;

        if iter!.pointNo > Length( stb.orbit )  then
            iter!.pointNo := 1;

            # Next level of the stabilizer chain.
            iter!.levelNo := iter!.levelNo + 1;
            iter!.level := stb.stabilizer;
            stb := iter!.level;

            # Return prematurely if the iterator is done.
            if IsEmpty( stb.genlabels )  then
                return gen;
            fi;

        fi;
        pnt := stb.orbit[ iter!.pointNo ];
        rep := [  ];
        img := stb.idimage;
        while pnt <> stb.orbit[ 1 ]  do
            Add( rep, stb.transversal[ pnt ] );
            img := LeftQuotient( stb.transimages[ pnt ], img );
            pnt := pnt ^ stb.transversal[ pnt ];
        od;
        bimg := iter!.base{ [ iter!.levelNo .. Length( iter!.base ) ] };
        for k  in Reversed( [ 1 .. Length( rep ) ] )  do
            for j  in [ 1 .. Length( bimg ) ]  do
                bimg[ j ] := bimg[ j ] / rep[ k ];
            od;
        od;
        iter!.img  := img;
        iter!.bimg := bimg;

    fi;

    return gen;
end );

BindGlobal( "ShallowCopy_CoKernelGens", function( iter )
    iter:= rec( level      := StructuralCopy( iter!.level ),
                 pointNo    := iter!.pointNo,
                 genlabelNo := iter!.genlabelNo,
                 levelNo    := iter!.levelNo,
                 base       := ShallowCopy( iter!.base ),
                 img        := iter!.img );
    iter.bimg:= iter.base;
#T what is this good for??
    return iter;
    end );

InstallGlobalFunction( CoKernelGensIterator, function( hom )
local   S,  iter,mgi;

  S := StabChainMutable( hom );
  iter := rec(
              IsDoneIterator := IsDoneIterator_CoKernelGens,
              NextIterator   := NextIterator_CoKernelGens,
              ShallowCopy    := ShallowCopy_CoKernelGens,

              level := S,
              pointNo := 1,
              genlabelNo := 1,
              levelNo := 1,
              base := BaseStabChain( S ) );
  iter.img  := S.idimage;
  iter.bimg := iter.base;
  mgi:=MappingGeneratorsImages(hom);
  iter.trivlist:=mgi[2]{Filtered([1..Length(mgi[1])],i->IsOne(mgi[1][i]))};

  return IteratorByFunctions( iter );
end );


#############################################################################
##
#F  CoKernelGensPermHom( <hom> )  . . . . . . . . generators for the cokernel
##
InstallGlobalFunction( CoKernelGensPermHom, function( hom )
    local   C,  sch;

    C := [  ];
    for sch  in CoKernelGensIterator( hom )  do
      if not (sch=One(sch) or sch in C) then
        AddSet( C, sch );
      fi;
    od;
    return C;
end );


#############################################################################
##
#F  RelatorsPermGroupHom( <hom, gens> ) . .  relators for a permutation group
##
##  `RelatorsPermGroupHom' is an internal function which is called by the
##  operation `IsomorphismFpGroupByGeneratorsNC' in case of a permutation
##  group. It implements John Cannon's multi-stage relations-finding
##  algorithm as described in
##
##  Joachim Neubueser: An elementary introduction to coset table methods
##  in computational group theory, pp. 1-45 in "Groups-St.Andrews 1981,
##  Proceedings of a conference, St.Andrews 1981", edited by Colin M.
##  Campbell and Edmund F. Robertson, London Math. Soc. Lecture Note Series
##  71, Cambridge University Press, 1982.
##
##  Warning: The arguments are not checked for being consistent.
##
##  If option `chunk' is given, relators are treated in chunks once their
##  number gets bigger
##
InstallGlobalFunction( RelatorsPermGroupHom, function ( hom, gensG )

    local actcos, actgen, app, c, col, cosets, cont, defs1, defs2, F, fgensH,
          G, g, g1, gen0, geners, gens, gensF, gensF2, gensS, H, i, idword,
          index, inv0, iso, j, map, ndefs, next, ngens, ngens2, ni, orbit,
          order, P, perm, perms, range, regular, rel, rel2, rels, relsG,
          relsGen, relsH, relsP, S, sizeS, stabG, stabS, table, tail, tail1,
          tail2, tietze, tzword, undefined,w,
          wordsH,allnums,fam,NewRelators,newrels,chunk, one;

    chunk:=ValueOption("chunk");
    # get the involved groups
    G := PreImage( hom );
    F := Range( hom );
    gensF := GeneratorsOfGroup( F );
    ngens := Length( gensG );
    one:= One( G );

    fam:=FamilyObj(One(F));
    # are all generators as we would expect them?
    allnums:=List(gensF,i->GeneratorSyllable(i,1));
    allnums:=(allnums=[1..Length(allnums)])
              and ForAll(gensF,i->Length(i)=1 and ExponentSyllable(i,1)=1);

    # special case: G is the identity group
    if Size( G ) = 1 then
      return gensF;
    fi;

    # apply the two-stage relations finding algorithm to recursively
    # construct a presentation for each stabilizer in a stabilizer chain of
    # G (if G is not regular), and finally for G itself
    regular := IsRegular( G );
    if regular then
      orbit := Orbits( G,MovedPoints(G) )[1];
      sizeS := 1;
    else

      # get a stabilizer chain for hom
      stabG := StabChainMutable( hom );
      orbit := stabG.orbit;

      # get the first stabilizer S
      stabS := stabG.stabilizer;
      S := Subgroup( G, stabS.labels{ stabS.genlabels } );
      sizeS := Size( S );
    fi;

    # initialize some local variables
    index := Length( orbit );
    ngens2 := ngens * 2;
    table := [];
    range := [ 1 .. index ];
    idword := One( gensF[1] );
    gensF2 := [];
    undefined := 0;
    ndefs := 0;
    defs1 := ListWithIdenticalEntries( ngens * index, 0 );
    defs2 := ListWithIdenticalEntries( ngens * index, 0 );

    # initialize a presentation for G
    P := PresentationFpGroup( F / [ ], 0 );
    tietze := P!.tietze;
    TzOptions( P ).protected := ngens;

    if sizeS > 1 then
      # construct recursively a presentation for S and lift the relators
      # of S to relators of G
      gensS := GeneratorsOfGroup( S );
      iso := IsomorphismFpGroupByGeneratorsNC( S, gensS, "x" :
        infolevel := 2 );

      H := Image( iso );
      fgensH := FreeGeneratorsOfFpGroup( H );
      relsH := RelatorsOfFpGroup( H );
      wordsH := stabS.genimages;

      for rel in relsH do
        AddRelator( P, MappedWord( rel, fgensH, wordsH ) );
      od;
    fi;

    # make the permutations act on the points 1 to index
    map := MappingPermListList( orbit, range );
    perms := List( gensG, gen -> PermList( OnTuples( orbit, gen * map ) ) );

    # get a coset table from the permutations and introduce appropriate
    # order relators for the involutory generators
    for i in [ 1 .. ngens ] do
      Add( gensF2, gensF[i] );
      Add( gensF2, gensF[i]^-1 );
      perm := perms[i];
      col := -OnTuples( range, perm );
      undefined := undefined + index;
      Add( table, col );
      order := Order( gensG[i] );
      if order <= 2 then
        rel := gensF[i]^order;
        if sizeS > 1 then
          # lift the tail of the relator from S to G
          tail := MappedWord( rel, gensF, gensG );
          if tail <> one then
            tail1 := UnderlyingElement( tail^iso );
            tail2 := UnderlyingElement( (tail^-1)^iso );
            rel2 := rel * MappedWord( tail2, fgensH, wordsH );
            rel := rel * MappedWord( tail1, fgensH, wordsH )^-1;
            if Length( rel ) > Length( rel2 ) then
              rel := rel2;
            fi;
          fi;
        fi;
        AddRelator( P, rel );
      else
        col := -OnTuples( range, perm^-1 );
        undefined := undefined + index;
      fi;
      Add( table, col );
    od;
    tietze[TZ_MODIFIED] := true;
    while tietze[TZ_MODIFIED] and tietze[TZ_TOTAL] > 0 do
      TzSearch( P );
    od;

    # reconvert the Tietze relators to abstract words
    relsP := tietze[TZ_RELATORS];
    relsG := [ ];
    for tzword in relsP do
      if tzword <> [ ] then
        if allnums then
          Add( relsG, AssocWordByLetterRep(fam,tzword ));
        else
          Add( relsG, AbstractWordTietzeWord( tzword, gensF ) );
        fi;
      fi;
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( gensF, relsG, table, true );

    # make the structure that is passed to `MakeConsequencesPres'
    app := ListWithIdenticalEntries( 8, 0 );
    app[1] := table;
    app[2] := defs1;
    app[3] := defs2;

    # define an appropriate ordering of the cosets,
    # enter the coset definitions in the table,
    # and construct the Schreier vector,
    cosets := ListWithIdenticalEntries( index, 0 );
    actcos := ListWithIdenticalEntries( index, 0 );
    actgen := ListWithIdenticalEntries( index, 0 );
    cosets[1] := 1;
    actcos[1] := 1;
    j := 1;
    i := 0;
    while i < index do
      i := i + 1;
      c := cosets[i];
      g := 0;
      while g < ngens2 do
        g := g + 1;
        next := -table[g][c];
        if next > 0 and actcos[next] = 0 then
          g1 := g + 2*(g mod 2) - 1;
          table[g][c] := next;
          undefined := undefined - 1;
          if table[g1][next] < 0 then
            table[g1][next] := c;
            undefined := undefined - 1;
          fi;
          actcos[next] := c;
          actgen[next] := g;
          ndefs := ndefs + 1;
          defs1[ndefs] := c;
          defs2[ndefs] := g;
          j := j + 1;
          cosets[j] := next;
          if j = index then
            g := ngens2;
            i := index;
          fi;
        fi;
      od;
    od;

    NewRelators:=function(nrels)
    local rel;
      # add the new relator to the Tietze presentation and reduce it
      for rel in nrels do
        AddRelator( P, rel );
      od;
      if tietze[TZ_MODIFIED] then
        while tietze[TZ_MODIFIED] and tietze[TZ_TOTAL] > 0 do
          TzSearch( P );
        od;

        # reconvert the Tietze relators to abstract words
        rels := relsG;
        relsG := [ ];
        relsP := tietze[TZ_RELATORS];
        for tzword in relsP do
          if allnums then
            Add( relsG, AssocWordByLetterRep(fam,tzword ));
          else
            Add( relsG, AbstractWordTietzeWord( tzword, gensF ) );
          fi;
        od;

        # reconstruct the rows for the relators if necessary
        if relsG <> rels then
          relsGen := RelsSortedByStartGen( gensF, relsG, table, true );
        fi;
      fi;
    end;
    newrels:=[];

    # run through the coset table and find the next undefined entry
    ni := 0;
    while ni < index and undefined > 0 do
      CompletionBar(InfoFpGroup,2,"Index Loop: ",ni/index);
      ni := ni + 1;
      i := cosets[ni];
      j := 0;
      while j < ngens2 and undefined > 0 do
        j := j + 1;
        if table[j][i] <= 0 then

          # define the entry appropriately
          g := j + 2*(j mod 2) - 1;
          c := -table[j][i];
          table[j][i] := c;
          undefined := undefined - 1;
          if table[g][c] < 0 then
            table[g][c] := i;
            undefined := undefined - 1;
          fi;
          ndefs := ndefs + 1;
          defs1[ndefs] := i;
          defs2[ndefs] := j;

          # construct the associated relator
          rel := idword;
          while c <> 1 do
            g := actgen[c];
            rel := rel / gensF2[g];
            c := actcos[c];
          od;
          #rel := rel^-1 * gensF2[j]^-1;
          rel := (gensF2[j]*rel)^-1;
          c := i;
          while c <> 1 do
            g := actgen[c];
            rel := rel / gensF2[g];
            c := actcos[c];
          od;
          if sizeS > 1 then
            # lift the tail of the relator from S to G
            tail := MappedWord( rel, gensF, gensG );
            if tail <> one then
              tail1 := UnderlyingElement( tail^iso );
              tail2 := UnderlyingElement( (tail^-1)^iso );
              rel2 := rel * MappedWord( tail2, fgensH, wordsH );
              #rel := rel * MappedWord( tail1, fgensH, wordsH )^-1;
              rel := rel / MappedWord( tail1, fgensH, wordsH );
              if Length( rel ) > Length( rel2 ) then
                rel := rel2;
              fi;
            fi;
          fi;

          if Length( rel ) > 0 then
            if Length(relsG)<100 or chunk=fail then
              # few relators or no chunk option: process step by step
              NewRelators([rel]);
            else
              # if there are many relators add them in chunks.
              Add(newrels,rel);
              if Length(newrels)>QuoInt(Length(relsG),10) then
                NewRelators(newrels);
                newrels:=[];
              fi;
            fi;
          fi;

          # continue the enumeration and find all consequences
          if undefined > 0 then
            app[4] := undefined;
            app[5] := ndefs;
            app[6] := relsGen;
            undefined := MakeConsequencesPres( app );
          fi;
        fi;
      od;
    od;
    Info(InfoFpGroup,2,""); # finish bar
    if Length(newrels)>0 then
      NewRelators(newrels);
      newrels:=[];
    fi;

    # reduce the resulting presentation
    if ValueOption("cheap")<>true then
      TzGoGo( P );
    fi;

    # reconvert the reduced relators and return them
    relsP := tietze[TZ_RELATORS];
    relsG := [ ];
    for tzword in relsP do
      if tzword <> [ ] then
        if allnums then
          w:=AssocWordByLetterRep(fam,tzword);
        else
          w:=AbstractWordTietzeWord( tzword, gensF );
        fi;
        if not w in relsG and not w^-1 in relsG then
          Add( relsG, w);
        fi;
      fi;
    od;
    return relsG;

end );

BindGlobal( "DoShortwordBasepoint", function(shorb)
local dom, l, n, i, j,o,mp,lp,x;
  # do not take all elements but a sampler
  #if Length(shorb)>10000 then
  #  mp:=[1..Length(shorb)];
  #  shorb:=shorb{Set([1..5000],i->Random(mp))};
  #fi;
  if Length(shorb)>3000 then
    mp:=[1..Length(shorb)];
    l:=List([1..1000],i->shorb[Random(mp)][1]);
  else
    l:=List(shorb,i->i[1]);
  fi;
  dom:=MovedPointsPerms(l);
  o:=OrbitsPerms(l,dom);
  l:=[];
  if Length(dom)>Length(shorb)*2 then
    n:=ListWithIdenticalEntries(Maximum(dom),0);
    for j in shorb do
      x:=j[1];
      if LargestMovedPointPerm(x)>0 then
        mp:=[];
        lp:=1/(1+Length(j[2]));
        for i in dom do
          if i^x=i then
            n[i]:=n[i]+lp;
          fi;
        od;
      fi;
    od;
    for j in o do
      lp:=Length(j);
      for i in j do
        if n[i]>0 then
          Add(l,[n[i]*lp,i]);
        fi;
      od;
    od;
  else
    for i in dom do
      n:=0;
      for j in shorb do
        if i^j[1]=i then
          n:=n+1/(1+Length(j[2]));
        fi;
      od;
      j:=PositionProperty(o,k->i in k);
      n:=n*Length(o[j]);
      Add(l,[n,i]);
    od;
  fi;

  Sort(l);
  if Length(l)=0 then
    return fail;
  fi;
  return l[Length(l)][2];
end );

#############################################################################
##
#M  StabChainMutable( <hom> ) . . . . . . . . . . . . . . for perm group homs
##
BindGlobal("DoSCMPermGpHom",function(arg)
    local   S,
            rnd,        # list of random elements of '<hom>.source'
            rne,        # list of the images of the elements in <rnd>
            rni,        # index of the next random element to consider
            elm,        # one element in '<hom>.source'
            img,        # its image
            size,       # size of the stabilizer chain constructed so far
            stb,        # stabilizer in '<hom>.source'
            bpt,        # base point
            two,        # power of two
            trivgens,   # trivial generators and their images, must be
            trivimgs,   #   entered into every level of the chain
            mapi,
            i, T,  # loop variables
            orb,
            orbf,       # indicates with which generator the image was obtained
            dict,
            short,
            FillTransversalShort,
            ntran, # positions of non-identity generators
            BuildOrb,
            AddToStbO,
            maxstor,
            gsize,
            hom,
            opt,
            usebase,
            l;  # position

    hom:=arg[1];
    if Length(arg)>1 then
      opt:=arg[2];
    else
      opt:=rec();
    fi;
    if IsBound(opt.base) then
      usebase:=opt.base;
    else
      usebase:=fail;
    fi;

    # Add to short word orbit fct.
    AddToStbO:=function(o,dict,e,w)
    local i;
      #Print("add length ",Length(UnderlyingElement(w)),"\n");
      i:=LookupDictionary(dict,e);
      if i<>fail then
        if Length(o[i][2])>Length(w) then
          o[i]:=Immutable([e,w]);
          return 0;
        fi;
        return 1;
      else
        Add(o,Immutable([e,w]));
        AddDictionary(dict,e,Length(o));
        return 0;
      fi;

#      if l<>Fail then
#      for i in [1..Length(o)] do
#       if o[i][1]=e then
#         if Length(o[i][2])>Length(w) then
#           o[i]:=Immutable([e,w]);
#         fi;
#         return;
#       fi;
#      od;
#      Add(o,Immutable([e,w]));
    end;

    # build short words by an orbit algorithm on genimg
    BuildOrb:=function(genimg)
    local a,orb,dict,orbf,T,elm,img,i,n;
      if Length(genimg[1])>0 then
        a:=genimg[1][1];
      else
        a:=One(Source(hom));
      fi;
      dict:=NewDictionary(a,false);
      a:=One(Source(hom));
      AddDictionary(dict,a);
      orb:=[Immutable([a,One(Range(hom))])];
      orbf:=[0];
      i:=1;
      n:=Length(genimg[1]);
      while Length(orb)<maxstor and i<=Length(orb) do
        for T in [1..n] do
          if orbf[i]<>-T then
            elm:=orb[i][1]*genimg[1][T];
            if not KnowsDictionary(dict,elm) then
              # new rep found
              img:=orb[i][2]*genimg[2][T];
              AddDictionary(dict,elm);
              Add(orb,Immutable([elm,img]));
              Add(orbf,T);
            fi;
          fi;
          if orbf[i]<>T then
            elm:=orb[i][1]/genimg[1][T];
            if not KnowsDictionary(dict,elm) then
              # new rep found
              img:=orb[i][2]/genimg[2][T];
              AddDictionary(dict,elm);
              Add(orb,Immutable([elm,img]));
              Add(orbf,-T);
            fi;
          fi;
        od;
        i:=i+1;
      od;
      return orb;
    end;

    mapi:=MappingGeneratorsImages(hom);

    # do products build up? (Must we prefer short words?)
    short:=(IsFreeGroup(Range(hom)) or IsFpGroup(Range(hom)))
            and ValueOption("noshort")<>true;

    if short then
      # compute how many perms we permit to store?
      maxstor:=LargestMovedPoint(Source(hom))+1;
      if maxstor>65535 then
        maxstor:=maxstor*2; # perms need twice as much memory
      fi;
      maxstor:=Int(40*1024^2/maxstor); # allocate at most 40MB to the perms
      # but don't be crazy
      maxstor:=Minimum(maxstor,
                 Size(Source(hom))/10,
                 500*LogInt(Size(Source(hom)),2),
                 25000);

      # fill transversal with elements that are short words
      # This is similar to Minkwitz' approach and produces much shorter
      # words when decoding.
      FillTransversalShort:=function(stb,size)
      local l,i,bpt,elm,wrd,z,j,dict,fc,mfc;
        mfc:=Minimum(maxstor*10,gsize/size);
        bpt:=stb.orbit[1];
        stb.norbit:=ShallowCopy(stb.orbit);
        # fill transversal with short words
        for l in stb.orb do
          i:=bpt/l[1];
          if not i in stb.norbit then
            Add(stb.norbit,i);
            stb.transversal[i]:=l[1];
            stb.transimages[i]:=l[2];
          fi;
          i:=bpt^l[1];
          if not i in stb.norbit then
            Add(stb.norbit,i);
            stb.transversal[i]:=Inverse(l[1]);
            stb.transimages[i]:=Inverse(l[2]);
          fi;
        od;
        stb.stabilizer.orb:=Filtered(stb.orb,i->bpt^i[1]=bpt);
        dict:=NewDictionary(stb.stabilizer.orb[1][1],true);
        for l in [1..Length(stb.stabilizer.orb)] do
          AddDictionary(dict,stb.stabilizer.orb[l][1],l);
        od;
        l:=1;
        fc:=1;
        maxstor:=Minimum(maxstor,QuoInt(5*gsize,size));
        if maxstor<1000 then
          maxstor:=Maximum(maxstor,Minimum(QuoInt(gsize,size),1000));
        fi;
        #Print(maxstor," ",gsize/size,"<\n");
        while Length(stb.stabilizer.orb)*5<maxstor and l<=Length(stb.orb)
          and fc<mfc do
          # add schreier gens
          elm:=stb.orb[l][1];
          wrd:=stb.orb[l][2];
          for z in [1,2] do
            if z=2 then
              elm:=elm^-1;
              wrd:=wrd^-1;
            fi;
            i:=bpt^elm;
            for j in stb.orb do
              if bpt^j[1]=i then
                fc:=fc+AddToStbO(stb.stabilizer.orb,dict,elm/j[1],wrd/j[2]);
              elif i^j[1]=bpt then
                fc:=fc+AddToStbO(stb.stabilizer.orb,dict,elm*j[1],wrd*j[2]);
              fi;
            od;
          od;
          l:=l+1;
        od;

        Unbind(stb.orb);
        Unbind(stb.norbit);
        stb:=stb.stabilizer;
        #Print("|o|=",Length(stb.orb),"\n");
        # is there too little left? If yes, extend!
        if Length(stb.orb)*20<maxstor then
          stb.orb:=BuildOrb([List(stb.orb,i->i[1]),
                             List(stb.orb,i->i[2])]);
        fi;
#Print(bpt,":",Length(stb.orb),"\n");
      end;
    else
      FillTransversalShort:=Ignore;
    fi;

    # initialize the random generators
    two := 16;
    rnd := ShallowCopy( mapi[1] );
    for i  in [Length(rnd)..two]  do
        Add( rnd, One( Source( hom ) ) );
    od;
    rne := ShallowCopy( mapi[2] );
    for i  in [Length(rne)..two]  do
        Add( rne, One( Range( hom ) ) );
    od;
    rni := 1;

    S := EmptyStabChain( [  ], One( Source( hom ) ),
                         [  ], One( Range( hom ) ) );
    if short then
      S.orb:=BuildOrb(mapi);
    fi;

    # initialize the top level
    bpt:=fail;
    if short and usebase=fail then
      bpt:=DoShortwordBasepoint(S.orb);
    fi;
    if bpt=fail then;
      if usebase<>fail then
        bpt:=usebase[1];
      else
        bpt := SmallestMovedPoint( Source( hom ) );
      fi;
      if bpt = infinity  then
          bpt := 1;
      fi;
    fi;
    InsertTrivialStabilizer( S, bpt );
    # the short words usable on this level
    gsize:=Size(PreImagesRange(hom));
    FillTransversalShort(S,1);

    # Extend  orbit and transversal. Store  images of the  identity for other
    # levels.
    AddGeneratorsGenimagesExtendSchreierTree( S, mapi[1], mapi[2] );
    trivgens := [  ];  trivimgs := [  ];
    for i  in [ 1 .. Length( mapi[1] ) ]  do
        if mapi[1][ i ] = One( Source( hom ) )  then
            Add( trivgens, mapi[1][ i ] );
            Add( trivimgs, mapi[2][ i ] );
        fi;
    od;

    # get the size of the stabilizer chain
    size := Length( S.orbit );

    # create new elements until we have reached the size

    ntran:=Filtered([1..Length(mapi[1])],x->not IsOne(mapi[1][x]));
    # catch all trivial case
    if Length(ntran)=0 then ntran:=[1..Length(mapi[1])];fi;
    while size <> gsize  do

        # try random elements
        elm := rnd[rni];
        img := rne[rni];
        i := Random(ntran);
        rnd[rni] := rnd[rni] * mapi[1][i];
        rne[rni] := rne[rni] * mapi[2][i];
        rni := rni mod two + 1;

        # divide the element through the stabilizer chain
        stb := S;
        bpt := BasePoint( stb );
        while     bpt <> false
              and elm <> stb.identity
              and Length( stb.genlabels ) <> 0  do
            i := bpt ^ elm;
            if IsBound( stb.translabels[ i ] )  then
                while i <> bpt  do
                    img := img * stb.transimages[ i ];
                    elm := elm * stb.transversal[ i ];
                    i := bpt ^ elm;
                od;
                stb := stb.stabilizer;
                bpt := BasePoint( stb );
            else
                bpt := false;
            fi;
        od;

        # if the element was not in the stabilizer chain
        if elm <> stb.identity  then

          # if this stabilizer is trivial add an new level
          if not IsBound( stb.stabilizer )  then
            l:=fail;
            if short and IsBound(stb.orb) then
              l:=DoShortwordBasepoint(stb.orb);
            fi;
            if l=fail then
              if usebase<>fail then
                l:=First(usebase,x->x^elm<>x);
              else
                l:=SmallestMovedPoint(elm);
              fi;
            fi;
            InsertTrivialStabilizer( stb, l );
            AddGeneratorsGenimagesExtendSchreierTree( stb,
                    trivgens, trivimgs );
            # the short words usable on this level
            FillTransversalShort(stb,size);
          fi;

#         if short then
#           l:=LookupDictionary(dict,elm);
#           if l<>fail then
#             img:=l;
#           fi;
#         fi;

          # extend the Schreier trees above level `stb'
          T := S;
          repeat
            T := T.stabilizer;
            size := size / Length( T.orbit );
            AddGeneratorsGenimagesExtendSchreierTree( T, [elm], [img] );
            size := size * Length( T.orbit );
          until T.orbit[ 1 ] = stb.orbit[ 1 ];

        fi;

    od;

    return S;
end );

InstallOtherMethod( StabChainMutable, "perm mapping by images",  true,
        [ IsPermGroupGeneralMappingByImages ], 0, DoSCMPermGpHom);

InstallOtherMethod( StabChainMutable, "perm mapping by images,options",  true,
        [ IsPermGroupGeneralMappingByImages,IsRecord ], 0, DoSCMPermGpHom);

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping( <hom> ) . . . for perm group homs
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping,
    true, [ IsPermGroupGeneralMappingByImages ], 0,
function( hom )
local is;
  # As ImagesSource might call ImagesSet which would require the co-kernel
  # again, one has to be a careful a bit.
  # However, the default ImagesSource method for IsGroupGeneralMappingByImages
  # does not use ImagesSet, and these days there should be no reason to use
  # ImagesSet in any ImagesSource method due to the existence of
  # MappingGeneratorsImages.
  is:=ImagesSource(hom);

  return NormalClosure( is, SubgroupNC
                   ( Range( hom ), CoKernelGensPermHom( hom ) ) );
end );

#############################################################################
##
#M  IsSingleValued( <hom> ) . . . . . . . . . . . . . . . for perm group homs
##
InstallMethod( IsSingleValued, true,
        [ IsPermGroupGeneralMappingByImages ], 0,
    function( hom )
    local   sch;

  # force stabilizer chain -- might get CoKernel for free
  if not HasStabChainMutable(hom) then
    StabChainMutable(hom);
  fi;

  if IsBound(hom!.CoKernelOfMultiplicativeGeneralMapping) then
    return IsTrivial(CoKernelOfMultiplicativeGeneralMapping(hom));
  fi;

    for sch in CoKernelGensIterator( hom )  do
        if sch <> One( sch )  then
            return false;
        fi;
    od;
    return true;
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . for perm group homs
##
InstallMethod( ImagesRepresentative, "perm group hom",FamSourceEqFamElm,
        [ IsPermGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ],
function( hom, elm )
local   S,img,img2;
  if not ( HasIsTotal( hom ) and IsTotal( hom ) )
      and not elm in PreImagesRange( hom )  then
      return fail;
  else
    S := StabChainMutable( hom );
    img := ImageSiftedBaseImage( S, OnTuples( BaseStabChain( S ), elm ),
                    S.idimage, OnRight );

    if IsPerm( img ) then
      if IsInternalRep( img ) then
        TRIM_PERM( img, LargestMovedPoint( Range( hom ) ) );
      else
        img:=RestrictedPermNC(img,[1..LargestMovedPoint(Range(hom))]);
      fi;
    elif IsAssocWord(img) or IsElementOfFpGroup(img) then
      # try the inverse as well -- it might be better
      img2:= ImageSiftedBaseImage( S, List(BaseStabChain(S),i->i/elm),
                    S.idimage, OnRight );
      if Length(UnderlyingElement(img2))<Length(UnderlyingElement(img)) then
        return img2;
      fi;
    fi;
    return img^-1;
  fi;
end );

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) . . . . . . . . for perm group homs
##
InstallMethod( CompositionMapping2, "group hom. with perm group hom.",
  FamSource1EqFamRange2, [ IsGroupHomomorphism,
          IsPermGroupGeneralMappingByImages and IsGroupHomomorphism ], 0,
    function( hom1, hom2 )
    local   prd,  stb,  levs,  S,t,i,oli;

    Size(Source(hom2));
    Size(Range(hom2));
    stb := StructuralCopy( StabChainMutable( hom2 ) );
    levs := [  ];
    S := stb;
    while IsBound( S.stabilizer )  do
        S.idimage := One( Range( hom1 ) );
        oli:=S.labelimages;
        if not ForAny( levs, lev -> IsIdenticalObj( lev, S.labelimages ) )  then
            Add( levs, S );
            S.labelimages := List( S.labelimages, g ->
                                   ImagesRepresentative( hom1, g ) );
        fi;
        S.generators  := S.labels     { S.genlabels };
        S.genimages   := S.labelimages{ S.genlabels };
        t:=S.translabels{ S.orbit };
        # are transimages actually given by translabels?
        if ForAll([1..Length(S.orbit)],
          x->IsIdenticalObj(S.transimages[S.orbit[x]],oli[t[x]])) then
          S.transimages := [  ];
          S.transimages{ S.orbit } := S.labelimages{ S.translabels{ S.orbit } };
        else
          for i in S.orbit do
            S.transimages[i]:=Image(hom1,S.transimages[i]);
          od;
        fi;
        S := S.stabilizer;
    od;
    S.idimage := One( Range( hom1 ) );
    prd := GroupHomomorphismByImagesNC( Source( hom2 ), Range( hom1 ),
                   stb.generators, stb.genimages );
    SetStabChainMutable( prd, stb );
    return prd;
end );

# this method is better if hom2 maps to an fp group -- otherwise for
# computing preimages we need to do an MTC.
InstallMethod( CompositionMapping2, "fp hom. with perm group hom.",
  FamSource1EqFamRange2,
  [ IsGroupHomomorphism and IsToFpGroupGeneralMappingByImages and IsSurjective,
          IsPermGroupGeneralMappingByImages and IsGroupHomomorphism ], 0,
function( hom1, hom2 )
local r, fgens, gens, kg;
  r:=Range(hom1);
  if (not KnowsHowToDecompose(Source(hom2))) or not IsWholeFamily(r) then
    TryNextMethod();
  fi;
  fgens:=ShallowCopy(GeneratorsOfGroup(r));
  gens:=List(fgens,
             i->PreImagesRepresentative(hom2,PreImagesRepresentative(hom1,i)));
  kg:=GeneratorsOfGroup(KernelOfMultiplicativeGeneralMapping(hom2));
  Append(gens,kg);
  Append(fgens,List(kg,i->One(r)));
  return GroupHomomorphismByImagesNC(Source(hom2),r,gens,fgens);
end);


#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . .  for perm group range
##
InstallMethod( PreImagesRepresentative, FamRangeEqFamElm,
        [ IsToPermGroupGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    return ImagesRepresentative( RestrictedInverseGeneralMapping( hom ), elm );
end );

#############################################################################
##
#F  StabChainPermGroupToPermGroupGeneralMappingByImages( <hom> )  . . . local
##
InstallGlobalFunction( StabChainPermGroupToPermGroupGeneralMappingByImages,
    function( hom )
    local   options,    # options record for stabilizer construction
            n,
            k,
            i,
            a,b,
            longgens,
            longgroup,
            conperm,
            conperminv,
            mapi,
            op;

    if IsTrivial( Source( hom ) )
       then n := 0;
       else n := LargestMovedPoint( Source( hom ) );  fi;
    if IsTrivial( Range( hom ) )
       then k := 0;
       else k := LargestMovedPoint( Range( hom ) );  fi;

    # force stab chain for source
    Size(Source(hom));

    # collect info for options
    options := rec();

    # random or deterministic
    if   IsBound( StabChainOptions( Parent( Source( hom ) ) ).random )  then
        options.randomSource :=
          StabChainOptions( Parent( Source( hom ) ) ).random;
    elif IsBound( StabChainOptions( Source( hom ) ).random )  then
        options.randomSource := StabChainOptions( Source( hom ) ).random;
    elif IsBound( StabChainOptions( PreImagesRange( hom ) ).random )  then
        options.randomSource := StabChainOptions( PreImagesRange( hom ) ).random;
    else
        options.randomSource := DefaultStabChainOptions.random;
    fi;
    if   IsBound( StabChainOptions( Parent( Range( hom ) ) ).random )  then
        options.randomRange :=
          StabChainOptions( Parent( Range( hom ) ) ).random;
    elif IsBound( StabChainOptions( Range( hom ) ).random )  then
        options.randomRange := StabChainOptions( Range( hom ) ).random;
    elif HasImagesSource(hom)
      and IsBound( StabChainOptions( ImagesSource( hom ) ).random )  then
        options.randomRange := StabChainOptions( ImagesSource( hom ) ).random;
    else
        options.randomRange := DefaultStabChainOptions.random;
    fi;
    options.random := Minimum(options.randomSource,options.randomRange);

    # if IsMapping, try to extract info from source
    if Tester( IsMapping )( hom )  and  IsMapping( hom )  then
        if   HasSize( Source( hom ) )  then
            options.size := Size( Source( hom ) );
        elif HasSize( PreImagesRange( hom ) )  then
            options.size := Size( PreImagesRange( hom ) );
        fi;
        if not IsBound( options.size )
           and HasSize( Parent( Source( hom ) ) )  then
            options.limit := Size( Parent( Source( hom ) ) );
        fi;
        if   IsBound( StabChainOptions( Source( hom ) ).knownBase )  then
            options.knownBase := StabChainOptions( Source( hom ) ).knownBase;
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )
          then
            options.knownBase := StabChainOptions( PreImagesRange( hom ) ).
                                 knownBase;
        elif HasBaseOfGroup( Source( hom ) )  then
            options.knownBase := BaseOfGroup( Source( hom ) );
        elif HasBaseOfGroup( PreImagesRange( hom ) )  then
            options.knownBase := BaseOfGroup( PreImagesRange( hom ) );
        elif IsBound( StabChainOptions( Parent( Source( hom ) ) ).knownBase )
          then
            options.knownBase :=
              StabChainOptions( Parent( Source( hom ) ) ).knownBase;
        elif HasBaseOfGroup( Parent( Source( hom ) ) )  then
            options.knownBase := BaseOfGroup( Parent( Source( hom ) ) );
        fi;

    # if it is the inverse of a mapping, transfer the same size info from
    # the range
    elif  HasInverseGeneralMapping(hom) and
      HasIsMapping(InverseGeneralMapping(hom)) and
      IsMapping(InverseGeneralMapping(hom)) and HasSize(Range(hom)) then
            options.size := Size( Range( hom ) );

    # if not IsMapping, settle for less
    else
        if   HasSize( Source( hom ) )  then
            options.limitSource := Size( Source( hom ) );
        elif HasSize( PreImagesRange( hom ) )  then
            options.limitSource := Size( PreImagesRange( hom ) );
        elif HasSize( Parent( Source( hom ) ) )  then
            options.limitSource := Size( Parent( Source( hom ) ) );
        fi;
        if   IsBound( StabChainOptions( Source( hom ) ).knownBase )  then
            options.knownBaseSource :=
              StabChainOptions( Source( hom ) ).knownBase;
        elif IsBound( StabChainOptions( PreImagesRange( hom ) ).knownBase )
          then
            options.knownBaseSource :=
              StabChainOptions( PreImagesRange( hom ) ).knownBase;
        elif IsBound( StabChainOptions( Parent( Source( hom ) ) ).knownBase )
          then
            options.knownBaseSource :=
                StabChainOptions( Parent( Source( hom ) ) ).knownBase;
        fi;

        # if we have info about source, try to collect info about range
        if IsBound( options.limitSource ) then
            if   HasSize( Range( hom ) )  then
                options.limitRange := Size( Range( hom ) );
            elif HasImagesSource(hom) and HasSize( ImagesSource( hom ) )  then
                options.limitRange := Size( ImagesSource( hom ) );
            elif HasSize( Parent( Range( hom ) ) )  then
                options.limitRange := Size( Parent( Range( hom ) ) );
            fi;
            if IsBound( options.limitRange ) then
                options.limit := options.limitSource * options.limitRange;
            fi;
        fi;
        if IsBound( options.knownBaseRange ) then
            if   IsBound( StabChainOptions( Range( hom ) ).knownBase )  then
                options.knownBaseRange :=
                  StabChainOptions( Range( hom ) ).knownBase;
            elif IsBound( StabChainOptions( PreImagesRange( hom ) ).
                    knownBase )  then
                options.knownBaseRange :=
                  StabChainOptions( PreImagesRange( hom ) ).knownBase;
            elif IsBound( StabChainOptions( Parent( Range( hom ) ) )
                    .knownBase )
              then
                options.knownBaseRange :=
                    StabChainOptions( Parent( Range( hom ) ) ).knownBase;
            fi;
            if IsBound( options.knownBaseRange ) then
                options.knownBase := Union( options.knownBaseSource,
                                            options.knownBaseRange + n );
            fi;
        fi;

    fi; # if IsMapping

    options.base := [1..n];

    # create concatenation of perms in hom.generators, hom.genimages
    longgens := [];
    conperm := MappingPermListList([1..k],[n+1..n+k]);
    conperminv := conperm^(-1);
    mapi:=MappingGeneratorsImages(hom);
    for i in [1..Length(mapi[1])] do
      # this is necessary to remove spurious points if the permutations are
      # not internal
      a:=mapi[1][i];
      b:=mapi[2][i];
      if not IsInternalRep(a) then
        a:=RestrictedPermNC(a,[1..n]);
      fi;
      if not IsInternalRep(b) then
        b:=RestrictedPermNC(b,[1..k]);
      fi;
      longgens[i] := a * (b ^ conperm);
    od;
    longgroup :=  GroupByGenerators( longgens, One( Source( hom ) ) );
    for op  in [ PreImagesRange, ImagesSource ]  do
        if      Tester(op)(hom) and HasIsSolvableGroup( op( hom ) )
           and not IsSolvableGroup( op( hom ) )  then
            SetIsSolvableGroup( longgroup, false );
            break;
        fi;
    od;

    MakeStabChainLong( hom, StabChainOp( longgroup, options ),
           [ 1 .. n ], One( Source( hom ) ), conperminv, hom,
           CoKernelOfMultiplicativeGeneralMapping );

    if  NrMovedPoints(longgroup)<=10000 and
       (not HasRestrictedInverseGeneralMapping( hom )
       or not HasStabChainMutable( RestrictedInverseGeneralMapping( hom ) )
       or not HasKernelOfMultiplicativeGeneralMapping( hom )
       ) then
        MakeStabChainLong( RestrictedInverseGeneralMapping( hom ),
                StabChainOp( longgroup, [ n + 1 .. n + k ] ),
                [ n + 1 .. n + k ], conperminv, One( Source( hom ) ), hom,
                KernelOfMultiplicativeGeneralMapping );
    fi;

    return StabChainMutable( hom );
end );

#############################################################################
##
#F  MakeStabChainLong( ... )  . . . . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( MakeStabChainLong,
    function( hom, stb, ran, c1, c2, cohom, cokername )
    local   newlevs,  S,  idimage, i,  len,  rest,  trans;

    # Construct the stabilizer chain for <hom>.
    S := CopyStabChain( stb );
    SetStabChainMutable( hom, S );
    newlevs := [  ];
    idimage:= One( Range( hom ) );

    repeat
        len := Length( S.labels );
        if len = 0  or  IsPerm( S.labels[ len ] )  then
            Add( S.labels, rec( labels := [  ], labelimages := [  ] ) );
            len := len + 1;
            for i  in [ 1 .. len - 1 ]  do
                rest := RestrictedPermNC( S.labels[ i ], ran );
#T !!
                Add( S.labels[ len ].labels, rest ^ c1 );
                Add( S.labels[ len ].labelimages,
                     LeftQuotient( rest, S.labels[ i ] ) ^ c2 );
            od;
            Add( newlevs, S.labels );
        fi;
        S.labels{ [ 1 .. len - 1 ] } := S.labels[ len ].labels;
        S.labelimages := S.labels[ len ].labelimages;
        S.generators  := S.labels{ S.genlabels };
        S.genimages   := S.labelimages{ S.genlabels };
        S.idimage     := idimage;
        if BasePoint( S ) in ran  then
            trans := S.translabels{ S.orbit };
            S.orbit := S.orbit - ran[ 1 ] + 1;
            S.translabels := [  ];
            S.translabels{ S.orbit } := trans;
            S.transversal := [  ];
            S.transversal{ S.orbit } := S.labels{ trans };
            S.transimages := [  ];
            S.transimages{ S.orbit } := S.labelimages{ trans };
            S := S.stabilizer;
            stb := stb.stabilizer;
        else
            RemoveStabChain( S );
            S.genimages:=[];
            S.labelimages := [  ];
            S := false;
        fi;
    until S = false;
    for S  in newlevs  do
        Remove( S );
    od;

    # Construct the cokernel.
    if not IsEmpty( stb.genlabels )  then
        if not Tester( cokername )( cohom )  then
            S := EmptyStabChain( [  ], idimage );
            ConjugateStabChain( stb, S, c2, c2 );
            TrimStabChain(S,LargestMovedPoint(Range(hom)));
            Setter( cokername )
              ( cohom, GroupStabChain( Range( hom ), S, true ) );
        fi;
    else
        Setter( cokername )( cohom, TrivialSubgroup( Range( hom ) ) );
    fi;

end );

#############################################################################
##
#M  StabChainMutable( <hom> ) . . . . . . . . . . for perm to perm group homs
##
InstallMethod( StabChainMutable, "perm to perm mapping by images",true,
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
        StabChainPermGroupToPermGroupGeneralMappingByImages );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping(<hom>) . for perm to perm group homs
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
        "for perm to perm group homs, compute stab chain, try again",
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
function( hom )
local ker;
  if HasStabChainMutable( hom ) then TryNextMethod(); fi;
  StabChainPermGroupToPermGroupGeneralMappingByImages( hom );
  ker:=KernelOfMultiplicativeGeneralMapping( hom );
  if Size(ker)=1 then
    SetIsInjective(hom,true);
  fi;
  return ker;
end );

#############################################################################
##
#M  CoKernelOfMultiplicativeGeneralMapping(<hom>) for perm to perm group homs
##
InstallMethod( CoKernelOfMultiplicativeGeneralMapping, true,
        [ IsPermGroupGeneralMappingByImages and
          IsToPermGroupGeneralMappingByImages ], 0,
    function( hom )
    Size(Source(hom)); Size(Range(hom)); # force sizes for RSS
    StabChainPermGroupToPermGroupGeneralMappingByImages( hom );
    return CoKernelOfMultiplicativeGeneralMapping( hom );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . . . for const hom
##
InstallMethod( ImagesRepresentative,"Constituent homomorphism",
  FamSourceEqFamElm,
        [ IsConstituentHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D;

    D := Enumerator( UnderlyingExternalSet( hom ) );
    if Length( D ) = 0  then
        return ();
    else
        return PermList( OnTuples( [ 1 .. Length( D ) ],
                       elm ^ hom!.conperm ) );
    fi;
#T problem if the image consists of wrapped permutations!
end );

#############################################################################
##
#M  ImagesSet( <hom>, <H> ) . . . . . . . . . . . . . . . . . . for const hom
##
InstallMethod( ImagesSet,"constituent homomorphism", CollFamSourceEqFamElms,
        # this method should *not* be applied if the group to be mapped has
        # no stabilizer chain (for example because it is very big).
        [ IsConstituentHomomorphism, IsPermGroup and HasStabChainMutable], 0,
function( hom, H )
local   D,  I,G;

  D := Enumerator( UnderlyingExternalSet( hom ) );
  I := EmptyStabChain( [  ], One(Range(hom)) );
  RemoveStabChain( ConjugateStabChain( StabChainOp( H, D ), I,
          hom, hom!.conperm,
          S -> BasePoint( S ) <> false
            and BasePoint( S ) in D ) );
  #GroupStabChain might give too many generators
  if Length(I.generators)<10 then
    return GroupStabChain( Range( hom ), I, true );
  else
    G:=SubgroupNC(Range(hom),
      List(GeneratorsOfGroup(H),i->Permutation(i,D)));
    SetStabChainMutable(G,I);
    return G;
  fi;
end );

#############################################################################
##
#M  Range( <hom>, <H> ) . . . . . . . . . . . . . . . . . . for const hom
##
BindGlobal( "RanImgSrcSurjTraho", function(hom)
local   D,H,I,G;
  H:=Source(hom);
  # only worth if the source has a stab chain to utilize
  if not HasStabChainMutable(H) then
    TryNextMethod();
  fi;
  D := Enumerator( UnderlyingExternalSet( hom ) );
  I := EmptyStabChain( [  ], () );
  RemoveStabChain( ConjugateStabChain( StabChainOp( H, D ), I,
          hom, hom!.conperm,
          S -> BasePoint( S ) <> false
            and BasePoint( S ) in D ) );
  #GroupStabChain might give too many generators
  if Length(I.generators)<10 then
    return GroupStabChain( I );
  else
    G:=Group(List(GeneratorsOfGroup(H),i->Permutation(i,D)),());
    SetStabChainMutable(G,I);
    return G;
  fi;
end );

InstallMethod( Range,"surjective constituent homomorphism",true,
  [ IsConstituentHomomorphism and IsActionHomomorphism and IsSurjective ],0,
  RanImgSrcSurjTraho);

InstallMethod( ImagesSource,"constituent homomorphism",true,
  [ IsConstituentHomomorphism and IsActionHomomorphism ],0,
  RanImgSrcSurjTraho);

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> )
##
InstallMethod( PreImagesRepresentative,"constituent homomorphism",
  FamRangeEqFamElm,[IsConstituentHomomorphism,IsPerm], 0,
function( hom, elm )
local D,DP;
  if not HasStabChainMutable(Source(hom)) then
    # do not enforce a stabchain if not necessary -- it could be big
    TryNextMethod();
  fi;
  D:=Enumerator(UnderlyingExternalSet(hom));
  DP:=Permuted(D,elm^-1);
  return RepresentativeAction(Source(hom),D,DP,OnTuples);
end);

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . . . for const hom
##
InstallMethod( PreImagesSet, "constituent homomorphism",CollFamRangeEqFamElms,
        [ IsConstituentHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H,          # preimage of <I>, result
            K,          # kernel of <hom>
            S,  T,  name;

    # compute the kernel of <hom>
    K := KernelOfMultiplicativeGeneralMapping( hom );

    # create the preimage group
    H := EmptyStabChain( [  ], One( Source( hom ) ) );
    S := ConjugateStabChain( StabChainMutable( I ), H, x ->
                 PreImagesRepresentative( hom, x ), hom!.conperm ^ -1 );
    T := H;
    while IsBound( T.stabilizer )  do
        AddGeneratorsExtendSchreierTree( T, GeneratorsOfGroup( K ) );
        T := T.stabilizer;
    od;

    # append the kernel to the stabilizer chain of <H>
    K := StabChainMutable( K );
    for name  in RecNames( K )  do
        S.( name ) := K.( name );
    od;

    return GroupStabChain( Source( hom ), H, true );
end );

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . . . for const hom
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
    "for constituent homomorphism",
    true, [ IsConstituentHomomorphism ], 0,
function( hom )
  return Stabilizer( Source( hom ), Enumerator( UnderlyingExternalSet( hom ) ),
                  OnTuples );
end );

#############################################################################
##
#M  StabChainMutable( <hom> ) . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( StabChainMutable,
    "for blocks homomorphism",
    true, [ IsBlocksHomomorphism ], 0,
    function( hom )
    local   img;

    img := ImageKernelBlocksHomomorphism( hom, Source( hom ),false );
    if not HasImagesSource( hom )  then
        SetImagesSource( hom, img );
    fi;
    return StabChainMutable( hom );
end );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )  . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesRepresentative, "blocks homomorphism", FamSourceEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   img,  D,  i;

    D := Enumerator( UnderlyingExternalSet( hom ) );

    # make the image permutation as a list
    img := [  ];
    for i  in [ 1 .. Length( D ) ]  do
        img[ i ] := hom!.reps[ D[ i ][ 1 ] ^ elm ];
    od;

    # return the image as a permutation
    return PermList( img );
end );

#############################################################################
#
#F  ImageKernelBlocksHomomorphism( <hom>, <H> ) . . . . . .  image and kernel
##
InstallGlobalFunction( ImageKernelBlocksHomomorphism, function( hom, H,par )
    local   D,          # the block system
            I,          # image of <H>, result
            S,          # block stabilizer in <H>
            T,          # corresponding stabilizer in <I>
            full,       # flag: true if <H> is (identical to) the source
            B,          # current block
            rep,        # new elt
            img, p,orb,
            i,  j, k;      # loop variables

    D := Enumerator( UnderlyingExternalSet( hom ) );
    S := CopyStabChain( StabChainImmutable( H ) );
    full := IsIdenticalObj( H, Source( hom ) );
    if full  then
        SetStabChainMutable( hom, S );
    fi;
    if par<>false then
      I := EmptyStabChain( [  ], One(par) );
    else
      I := EmptyStabChain( [  ], () );
    fi;
    T := I;

    # loop over the blocks
    for i  in [ 1 .. Length( D ) ]  do
        B := D[ i ];

        # if <S> does not already stabilize this block
        if     IsBound( B[1] )
           and ForAny( S.generators, gen -> hom!.reps[ B[ 1 ] ^ gen ] <> i )
           then
            ChangeStabChain( S, [ B[ 1 ] ] );

            # Make the next level of <T> and go down to `<T>.stabilizer'.
            T := ConjugateStabChain( S, T, hom, hom!.reps,
                         S -> BasePoint( S ) = B[ 1 ] );

            # Make <S> the stabilizer of the block <B>.
            InsertTrivialStabilizer( S.stabilizer, B[ 1 ] );

            if Length(B)>Length(D)^2 then
              # if there are few, large blocks the search through all block
              # points is tedious. Rather use an orbit/stabilizer algorithm.
              orb:=[i];
              rep:=[One(H)];
              j:=1;
              while j<=Length(orb) do
                for k in S.generators do
                  img:=D[orb[j]][1]^k;
                  p:=hom!.reps[img];
                  if not p in orb then
                    Add(orb,p);
                    Add(rep,rep[j]*k);
                  else
                    k:=rep[j]*k/rep[Position(orb,p)]; # will fix block
                    if not IsOne(SiftedPermutation(S.stabilizer,k)) then
                      AddGeneratorsExtendSchreierTree( S.stabilizer,
                              [k] );
                    fi;

                  fi;
                od;
                j:=j+1;
              od;
            else
              j := 1;
              while                                j < Length( B )
                    and Length( S.stabilizer.orbit ) < Length( B )  do
                  j := j + 1;
                  if IsBound( S.translabels[ B[ j ] ] )  then
                      rep:=InverseRepresentative( S, B[ j ] );
                      if not IsOne(SiftedPermutation(S.stabilizer,rep)) then
                        AddGeneratorsExtendSchreierTree( S.stabilizer,
                                [rep] );
                      fi;
                  fi;
              od;
            fi;

            S := S.stabilizer;

        fi;
    od;

    # if <H> is the full group this also gives us the kernel
    if full  and  not HasKernelOfMultiplicativeGeneralMapping( hom )  then
        SetKernelOfMultiplicativeGeneralMapping( hom,
            GroupStabChain( Source( hom ), S, true ) );
    fi;

    if par<>false then
      return GroupStabChain( par, I, true );
    else
      return GroupStabChain(I);
    fi;

end );

#############################################################################
##
#M  ImagesSet( <hom>, <H> ) . . . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( ImagesSet, "for blocks homomorphism and perm. group",
    CollFamSourceEqFamElms, [ IsBlocksHomomorphism, IsPermGroup ], 0,
function(hom,U)
  return ImageKernelBlocksHomomorphism(hom,U,Range(hom));
end);

BindGlobal( "RanImgSrcSurjBloho", function(hom)
local gens,imgs,ran;
# using stabchain info will produce just too many generators
  if ValueOption("onlyimage")=fail and HasStabChainMutable(Source(hom))
    and NrMovedPoints(Source(hom))<20000 then
    # transfer stabchain information if not too expensive
    ran:=ImageKernelBlocksHomomorphism(hom,Source(hom),false);
  else
    gens:=GeneratorsOfGroup( Source( hom ) );
    imgs:=List(gens,gen->ImagesRepresentative( hom, gen ) );
    ran:=GroupByGenerators( imgs,
              ImagesRepresentative( hom, One( Source( hom ) ) ) );
    SetMappingGeneratorsImages(hom,[gens,imgs]);
  fi;
  return ran;
end );

InstallMethod( Range, "surjective blocks homomorphism",true,
  [ IsBlocksHomomorphism and IsSurjective ], 0,
  RanImgSrcSurjBloho);

InstallMethod( ImagesSource, "blocks homomorphism",true,
  [ IsBlocksHomomorphism ], 0,
  RanImgSrcSurjBloho);

#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> ) . . . . . .  for blocks hom
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,"blocks homomorphism",
    true,
    [ IsBlocksHomomorphism ], 0,
    function( hom )
    local   img;

    img := ImageKernelBlocksHomomorphism( hom, Source( hom ),false);
    if not HasImagesSource( hom )  then
        SetImagesSource( hom, img );
    fi;
    return KernelOfMultiplicativeGeneralMapping( hom );
end );

#############################################################################
##
#M  PreImagesRepresentative( <hom>, <elm> ) . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesRepresentative, "blocks homomorphism",
        FamRangeEqFamElm,
        [ IsBlocksHomomorphism, IsMultiplicativeElementWithInverse ], 0,
    function( hom, elm )
    local   D,          # the block system
            pre,        # preimage of <elm>, result
            S,          # stabilizer in chain of <hom>
            B,          # the image block <B>
            b,          # number of image block <B>
            pos;        # position of point hit by preimage

    D := Enumerator( UnderlyingExternalSet( hom ) );
    S := StabChainMutable( hom );
    pre := One( Source( hom ) );

    # loop over the blocks and their iterated set stabilizers
    while Length( S.genlabels ) <> 0  do

        # Find the image block <B> of the current block.

        # test if the point is in no block (transitive action)
        # if not we can simply skip this step in the stabilizer chain.
        if IsBound(hom!.reps[S.orbit[1]]) then
          b := hom!.reps[ S.orbit[ 1 ] ] ^ elm;
          if b > Length( D )  then
              return fail;
          fi;
          B := D[ b ];

          # Find a point in <B> that can be hit by the preimage.
          pos := PositionProperty( B, pnt ->
                         IsBound( S.translabels[ pnt/pre ] ) );
          if pos = fail  then
              return fail;
          else
              pre := LeftQuotient( InverseRepresentative( S, B[ pos ] / pre ),
                             pre );
          fi;

        fi;

        S := S.stabilizer;
    od;

    # return the preimage
    return pre;
end) ;

#############################################################################
##
#M  PreImagesSet( <hom>, <I> )  . . . . . . . . . . . . . . .  for blocks hom
##
InstallMethod( PreImagesSet, CollFamRangeEqFamElms,
        [ IsBlocksHomomorphism, IsPermGroup ], 0,
    function( hom, I )
    local   H;          # preimage of <I> under <hom>, result

    H := PreImageSetStabBlocksHomomorphism( hom, StabChainMutable( I ) );
    return GroupStabChain( Source( hom ), H, true );
end );

#############################################################################
##
#F  PreImageSetStabBlocksHomomorphism( <hom>, <I> ) . . .  recursive function
##
InstallGlobalFunction( PreImageSetStabBlocksHomomorphism, function( hom, I )
    local   H,          # preimage of <I> under <hom>, result
            pnt,        # rep. of the block that is the basepoint <I>
            gen,        # one generator of <I>
            pre;        # a representative of its preimages

    # if <I> is trivial then preimage is the kernel of <hom>
    if IsEmpty( I.genlabels )  then
        H := CopyStabChain( StabChainImmutable(
                 KernelOfMultiplicativeGeneralMapping( hom ) ) );

    # else begin with the preimage $H_{block[i]}$ of the stabilizer  $I_{i}$,
    # adding preimages of the generators of  $I$  to those of  $H_{block[i]}$
    # gives us generators for $H$. Because $H_{block[i][1]} \<= H_{block[i]}$
    # the stabilizer chain below $H_{block[i][1]}$ is already complete, so we
    # only have to care about the top level with the basepoint $block[i][1]$.
    else
        pnt := Enumerator( UnderlyingExternalSet( hom ) )[ I.orbit[ 1 ] ][1];
        H := PreImageSetStabBlocksHomomorphism( hom, I.stabilizer );
        ChangeStabChain( H, [ pnt ], false );
        for gen  in I.generators  do
            pre := PreImagesRepresentative( hom, gen );
            if not IsBound( H.translabels[ pnt ^ pre ] )  then
                AddGeneratorsExtendSchreierTree( H, [ pre ] );
            fi;
        od;
    fi;

    # return the preimage
    return H;
end );

DeclareRepresentation("IsBlocksOfActionHomomorphism",
  IsActionHomomorphismByBase,[]);

#############################################################################
##
#M  CompositionMapping2( <hom1>, <hom2> ) blocks of action
##
InstallMethod( CompositionMapping2,
    "for action homomorphism with blocks homomorphism",
    FamSource1EqFamRange2,
    [ IsGroupHomomorphism and IsBlocksHomomorphism,
      IsGroupHomomorphism and IsActionHomomorphism ], 0,
function(map2,map1)
local e1,e2,d1,d2,i,ac,act,hom,xset;
  e1:=UnderlyingExternalSet(map1);
  d1:=HomeEnumerator(e1);
  if not IsPlistRep(d1) then
    TryNextMethod();
  fi;
  #sort:=CanEasilySortElements(d1[1]);
  ac:=FunctionAction(e1);
  act:=function(set,g)
         set:=List(set,i->ac(i,g));
         Sort(set);
         return set;
       end;
  e2:=UnderlyingExternalSet(map2);
  d2:=HomeEnumerator(e2);
  d2:=List(d2,i->d1{i});
  for i in d2 do
    Sort(i);
    IsSSortedList(i);
  od;
  MakeImmutable(d2);
  IsSSortedList(d2);
  xset:=ExternalSet(Source(map1),d2,act);
  xset!.basePermImage:=BaseStabChain(StabChainMutable(ImagesSource(map2)));
  SetBaseOfGroup(xset,d2{xset!.basePermImage});

  if HasImagesSource(map1) and HasIsSurjective(map2)
     and ImagesSource(map1)=Source(map2) then
    hom:=ActionHomomorphismConstructor(xset,true,
           IsBlocksOfActionHomomorphism);
    SetRange(hom,Range(map2));
    SetImagesSource(hom,Range(map2));
  else
    hom:=ActionHomomorphismConstructor(xset,false,
           IsBlocksOfActionHomomorphism);
  fi;
  hom!.innerAct:=ac;
  if HasMappingGeneratorsImages(map1)
    and MappingGeneratorsImages(map1)[2]=MappingGeneratorsImages(map2)[1] then
    SetMappingGeneratorsImages(hom,[MappingGeneratorsImages(map1)[1],
                                    MappingGeneratorsImages(map2)[2]]);
  fi;
  return hom;
end);

# seems to be not worth doing
# #############################################################################
# ##
# #M  ImagesRepresentative( <hom>, <elm> )
# ##
# InstallMethod( ImagesRepresentative,
#   "action blocks, using `RepresentativeAction'",
#   FamSourceEqFamElm, [ IsBlocksOfActionHomomorphism and HasImagesSource,
#           IsMultiplicativeElementWithInverse ], 0,
# function( hom, elm )
# local   xset,  D,  imgs, i, a;
#
#   TryNextMethod();
#   xset := UnderlyingExternalSet( hom );
#   D := HomeEnumerator( xset );
#   imgs:=[];
#   for i in BaseOfGroup(xset) do
#     a:=hom!.innerAct(i[1],elm);
#     Add(imgs,PositionProperty(D,j->a in j));
#   od;
#   Error();
#
#   return RepresentativeActionOp( ImagesSource( hom ),
#                 xset!.basePermImage, imgs, OnTuples );
# end );



#############################################################################
##
#F  IsomorphismPermGroup( <G> )
##
InstallMethod( IsomorphismPermGroup,
    "perm groups",
    true,
    [ IsPermGroup ],
    SUM_FLAGS,
    IdentityMapping );


#############################################################################
##
#M  IsConjugatorIsomorphism( <hom> )
##
InstallOtherMethod( IsConjugatorIsomorphism,
    "perm group homomorphism",
    true,
    [ IsGroupGeneralMapping ],
  # There is no filter to test whether a homomorphism goes from a perm group
  # to a perm group. So we have to test explicitly and make this method
  # higher ranking than the default one in `ghom.gi'.
  1,
function( hom )
  local s, genss, rep,dom,insn,stb,E,bpt,fix,pnt,idom,sliced,
    o,oimgs,i,pi,sto,stbs,stbi, r, sym,doms,gn,mapi,pos,orb;

  s:= Source( hom );
  if not IsPermGroup( s ) then
    TryNextMethod();
  elif not ( IsGroupHomomorphism( hom ) and IsInjective( hom ) ) then
    return false;
  fi;
  # trivial group
  if Size(s)=1 then
    SetConjugatorOfConjugatorIsomorphism(hom,One(s));
    return true;
  fi;

  genss:= GeneratorsOfGroup( s );

  if IsEndoGeneralMapping( hom ) then

    # cheap test for cycle structures
    if Length(Set(MappingGeneratorsImages(hom),
      x->List(x,CycleStructurePerm)))>1
    then
      return false;
    fi;

    # test in transitive case whether we can realize in S_n
    # we do not yet compute the permutation here because we will still have to
    # test first whether it is in fact an inner automorphism:
    # ConjugatorAutomorphisms are guaranteed to conjugate with an inner
    # element if possible!
    insn:=false;
    dom:=MovedPoints(s);
    if IsTransitive(s,dom) then
      bpt := dom[ 1 ];
      stb:=Stabilizer(s,bpt);
      E:=Image(hom,stb);
      if Number(dom,i->ForAll(GeneratorsOfGroup(E),j->i^j=i))=
         Number(dom,i->ForAll(GeneratorsOfGroup(stb),j->i^j=i)) then
  #T why not with NrMovedPoints?
  #T why not compare orbit lengths of point stabilizer and its image?
        insn:=true;
      else
        # we cannot realize in S_n
        return false;
      fi;
    else
      # compute the orbits and their image orbits
      o:=OrbitsDomain(s,dom);
      oimgs:=[];
      stbs:=[];
      stbi:=[];
      i:=1;
      while i<=Length(o) do
        stb:=Stabilizer(s,o[i][1]);
        sto:=Collected(List(OrbitsDomain(stb,o[i]),Length)); # stb orbit lengths
        E:=Image(hom,stb);
        Add(stbs,stb);
        Add(stbi,E);
        pi:=Filtered(o,j->Length(j)=Length(o[i])); # possible images by length
        # possible images by stabilizer orbit lengths
        pi:=Filtered(pi,j->Collected(List(OrbitsDomain(E,j),Length))=sto);
        if Length(pi)=0 then
          return false; # image cannot be stabilizer
        elif Length(pi)=1 then
          Add(oimgs,pi[1]);
        else
          # orbit image not unique. We would have to backtrack. For the time
          # being, give up
  #T why not inspect other orbits, and hope for a cheap `false' answer?
          i:=Length(o)+10;
        fi;
        i:=i+1;
      od;
      if Length(oimgs)=Length(o) then
        insn:=2; # conjugation in S_n established on multiple orbits
      fi;
    fi;

    # try first to find an element in the group itself
    rep:=RepresentativeAction(s, genss,
           List( genss, i -> ImagesRepresentative( hom, i ) ), OnTuples );

    if rep<>fail then
      # we found the automorphism is in fact inner
      Assert( 1, ForAll( genss, i -> ImagesRepresentative( hom, i ) = i^rep ) );
      SetIsInnerAutomorphism(hom,true);
    else
      if insn=true then
        hom:=AsGroupGeneralMappingByImages(hom);
        fix := First( dom, p -> ForAll( GeneratorsOfGroup( E ),
                      gen -> p ^ gen = p ) );

        # The automorphism <aut> maps <d>_bpt to <e>_fix, so permutes the points.
        # Find an element in <G> with the same action.
        idom := [  ];
        for pnt  in dom  do
            sliced := [  ];
            while pnt <> bpt  do
                Add( sliced, StabChainMutable( hom ).transimages[ pnt ] );
                pnt := pnt ^ StabChainMutable( hom ).transversal[ pnt ];
            od;
            Add( idom, PreImageWord( fix, sliced ) );
        od;

        rep:=MappingPermListList( dom, idom );
      elif insn=2 then
        dom:=[];
        idom:=[];
        for i in [1..Length(o)] do
          # compute the images for orbit o[i]
          stb:=stbs[i]; # pnt stabilizer and its image
          E:=stbi[i];
          # base point and image
          bpt:=o[i][1];
          fix:=First(oimgs[i],p->ForAll(GeneratorsOfGroup(E),
                      gen -> p ^ gen = p ) );

          # parallel orbit algorithm
          mapi:=MappingGeneratorsImages(hom);
          Add(dom,bpt);
          Add(idom,fix);
          pos:=Length(dom);
          doms:=[bpt];
          while pos<=Length(dom) do
            for gn in [1..Length(mapi[1])] do
              bpt:=dom[pos]^mapi[1][gn];
              if not bpt in doms then
                Add(dom,bpt);
                AddSet(doms,bpt);
                Add(idom,idom[pos]^mapi[2][gn]);
              fi;
            od;
            pos:=pos+1;
          od;

          # # we could try to use stabilizer chains, but the homomorphism does
          # # not necessarily have one which acts in every orbit. So we use the
          # # time-homoured transversal
          # sliced:=RightTransversal(s,stb);
          # for pnt in sliced do
          #   Add(dom,bpt^pnt);
          #   Add(idom,fix^ImageElm(hom,pnt));
          # od;

        od;
        rep:=MappingPermListList( dom, idom );
      else
        # we got multiple orbits

        # does it matter? (can we do per orbit?)
        orb:=List(Orbits(s,dom),Set);
        rep:=[];
        i:=1;
        while i<=Length(orb) do
          sym:=ActionHomomorphism(s,orb[i],"surjective");
          pi:=InducedAutomorphism(sym,hom);
          if IsConjugatorIsomorphism(pi) then
            rep[i]:=ConjugatorOfConjugatorIsomorphism(pi);
          else
            rep:=fail;
            i:=Length(orb);
          fi;
          i:=i+1;
        od;
        if rep<>fail then
          pi:=List([1..Length(orb)],x->MappingPermListList(Permuted(orb[x],rep[x]),orb[x]));
          rep:=Product(pi);
          # must do final test, in case element maps to restricted perm
          if ForAll(genss,i->ImagesRepresentative(hom,i)=i^rep) then
            SetConjugatorOfConjugatorIsomorphism( hom, rep );
            return true;
          fi;
        fi;

        if ValueOption("cheap")=true then
          return false;
        fi;
        rep:=RepresentativeAction(OrbitStabilizingParentGroup(s),
              genss,
              List( genss, i -> ImagesRepresentative( hom, i ) ), OnTuples );
        if rep<>fail then
          Assert(1,ForAll(genss,i->ImagesRepresentative(hom,i)=i^rep));
        fi;
      fi;
    fi;

  else

    r:= Range( hom );
    if not IsPermGroup( r ) then
      return false;
    fi;
    sym:= SymmetricGroup( Union( MovedPoints( s ), MovedPoints( r ) ) );

    # Simply compute a conjugator in the enveloping symmetric group.
    # (Note that all checks whether source and range
    # can fit together under conjugation
    # should better be left to `RepresentativeAction'.)
    rep:= RepresentativeAction( sym, genss, List( genss,
                    i -> ImagesRepresentative( hom, i ) ), OnTuples );
    if rep<>fail then
      Assert(1,ForAll(genss,i->ImagesRepresentative(hom,i)=i^rep));
    fi;

  fi;

  # Return the result.
  if rep <> fail then
    SetConjugatorOfConjugatorIsomorphism( hom, rep );
    return true;
  else
    return false;
  fi;
end );
