#############################################################################
##
#W  risotest.gi                GrpConst                    Hans Ulrich Besche
#W                                                               Bettina Eick
##
Revision.("grpconst/gap/risotest_gi") :=
    "@(#)$Id: risotest.gi,v 1.13 1999/10/15 17:32:49 gap Exp $";

#############################################################################
##
#F  AddRandomTestInfosFEM( Finfo )
##
##  To the record Finfo, containing the frattinifree group Finfo.F, a number
##  of fields are added which are used to run the random isomorphism test 
##  of groups with the frattini-factor Finfo.F
##
InstallGlobalFunction( AddRandomTestInfosFEM, function( arg )
    local F, elms, orb, orbs, orbss, ord, typ, typs, ntyps, i, j, pos, poses,
          nposes, qual, size, spos, pcgs, Finfo, alter;

    Finfo := arg[ 1 ];
    if Length( arg ) > 1 then
        alter := arg[ 2 ];
    else
        alter := 1;
    fi;
    F := Finfo.F;
    size := Size( F );
    pcgs := Pcgs( F );
    Finfo.lmin := Length( MinimalGeneratingSet( F ) );
    Finfo.lgen := Length( pcgs );
    elms := AttributeValueNotSet( AsList, F );
    orbs := Orbits( F, elms );

    # the orbs will be classified according to the typ-information in typs
    # all elements of one typ are collected in one list in orbss
    typs := [];
    orbss := [];
    for orb in orbs do
        ord := Order( orb[ 1 ] );
        typ := [ ord, Length( orb ) ];
        i := 1;
        repeat
            Add( typ, orb[ 1 ] ^ Primes[ i ] in orb );
            i := i + 1;
        until Primes[ i ] > ord or i > 20;
        i := Position( typs, typ );
        if i = fail then
            Add( typs, typ );
            Add( orbss, ShallowCopy( orb ) );
        else
            Append( orbss[ i ], orb );
        fi;
    od;

    # create all sensible strategies for generator selection
    ntyps := Length( typs );
    poses := List( [ 2 .. ntyps ], x -> [ x ] );
    for i in [ 2 .. Finfo.lmin ] do
        nposes := [];
        for pos in poses do
            Append(nposes,List([pos[i-1]..ntyps],x->Concatenation(pos,[x])));
        od;
        poses := nposes;
    od;

    # sort the strategies acording to the number of generating sets
    typs := List( orbss, Length );
    qual := List( poses, x-> Product( typs{ x } ) );
    SortParallel( qual, poses );

    # look up the first strategie which will generate the group
    for pos in poses do
        for i in [ 1 .. 16 ] do
            if size = Size( Group( List( pos, x-> Random( orbss[ x ])))) then
                if alter = 1 then
                    spos := Set( pos );
                    Finfo.geninds := List( spos, x->Number( pos, y->y=x ) );
                    for j in [ 1 .. Length( spos ) ] do
                        Finfo.(j) := List( orbss[ spos[ j ] ], x ->
                                     ExponentsOfPcElement( pcgs, x ) );
                    od;
                    Info( InfoGrpCon, 4, "  F-strategy: ", Finfo.lmin, 
                          " generators with ", Product( List( pos ),
                          x -> Length( orbss[ x ] ) ), " combinations" );
                    return;
                elif IsInt( alter ) then
                    alter := alter - 1 / 2;
                fi;
            fi;
        od;
        alter := Int( alter );
    od;

    Info( InfoWarning, 1, "AddRandomTestInfos called recursive" );
    AddRandomTestInfosFEM( Finfo );
end);

#############################################################################
##
#F  PermGensGensFEM( famPcgs, specialPcgs, gens1, gens2 ) . . . . . . . local
##
InstallGlobalFunction( PermGensGensFEM, function( fam, spcgs, gens1, gens2 )
    local i, j, perm, l1, l2, elem1, elem2, indices, rel, g;

    if Size( Group( spcgs ) ) <> Size( Group( fam ) ) then
        Error( "PermGensGensFEM: spcgs should generate family group" );
    fi;
    gens1 := CodeGenerators( gens1, spcgs ).pcgs;
    gens2 := CodeGenerators( gens2, spcgs ).pcgs;
    l1 := [ gens1[ 1 ] ^ Order( gens1[ 1 ] ) ];
    l2 := [ l1[ 1 ] ];
    rel := RelativeOrders( gens1 );
    for i in Reversed( [ 1 .. Length( gens1 ) ] ) do
        elem1 := ShallowCopy( l1 );
        elem2 := ShallowCopy( l2 );
        for j in [ 1 .. rel[ i ] - 1 ] do
            Append( elem1, gens1[ i ] ^ j * l1 );
            Append( elem2, gens2[ i ] ^ j * l2 );
        od;
        l1 := elem1;
        l2 := elem2;
    od;
    rel := RelativeOrders( fam );
    indices := [];
    indices[ Length( rel ) ] := 1;
    for i in Reversed( [  2 .. Length( rel ) ] ) do
        indices[ i - 1 ] := indices[ i ] * rel[ i ];
    od;

    l1 := [ ]; l2 := [ ];
    for i in [ 1 .. Length( elem1 ) ] do
        Add( l1, ExponentsOfPcElement( fam, elem1[ i ] ) * indices  + 1 );
        Add( l2, ExponentsOfPcElement( fam, elem2[ i ] ) * indices  + 1 );
    od;

    perm := [];
    for i in [ 1 .. Length( l1 ) ] do
        perm[ l1[ i ] ] := l2[ i ];
    od;

    return PermList( perm );
end);

#############################################################################
##
#F  RandomIsomorphismTestFEM( list, Finfo )
##
##  test groups generated by the frattini extension method on isomorphism
##
InstallGlobalFunction( RandomIsomorphismTestFEM, function( list, Finfo )
    local i, j, k, l, gi, ek, n, p,
          size, grps, spcgs, lgws, g, fams,
          elms, t, ord, orb, orbs, orbss, tnorbss, norbss, fsize, exts,
          pos, poses, genpos, typ, typs, ttyps, inds, 
          gensys, typscache, ngensets, misses, stmp,
          rem, mhits, hasAutos, disting, found, r, gens, code, perm, ident;

    size  := list[ 1 ].order;
    grps  := List( list, PcGroupCodeRec );
    fams  := List( grps, FamilyPcgs );
    spcgs := List( grps, SpecialPcgs );
    lgws  := List( spcgs, LGWeights );
    misses := List( list, x -> 0 );

    # return if LGWeights are different
    t := Set( lgws );
    if Length( t ) > 1 then
        Info( InfoGrpCon, 3, " split ", Length( list ),
              " groups with LGWeights in ", Length( t ), " sublists" );
        return rec( subl := List( t,
                x->list{ Filtered( [1..Length(list)], y -> x=lgws[y] ) } ) );
    fi;

    # derive generator-system of the grps from Finfo
    exts := List( [ Finfo.lgen + 1 .. Length( fams[ 1 ] ) ],
                  x -> RelativeOrderOfPcElement( fams[1], fams[1][x] ) );
    exts := Cartesian( List( exts, x-> [ 0 .. x - 1 ] ) );
    fsize := Length( exts );
    gensys := List( list, x-> [] );
    typscache := List( list, x-> [] );
    n := Length( list );
    for gi in [ 1 .. n ]  do
        g := grps[ gi ];
        for i in [ 1 .. Length( Finfo.geninds ) ] do
            # investigation of the i-th generator type of g/phi(g) for the
            # gi-th group

            # properties of the conjugacy classes
            t := List( Finfo.(i), x-> List( exts, y ->
                  PcElementByExponentsNC( fams[gi], Concatenation( x, y ))));
            orbs := Orbits( g, Concatenation( t ) );
            typs := [];
            orbss := [];
            for orb in orbs do
                ord := Order( orb[ 1 ] );
                typ := [ ord, Length( orb ) ];
                j := 1;
                repeat
                    Add( typ, orb[ 1 ] ^ Primes[ j ] in orb );
                    j := j + 1;
                until Primes[ j ] > ord or j > 20;
                j := Position( typs, typ );
                if j = fail then
                    Add( typs, typ );
                    Add( orbss, [ orb ] );
                else
                    Add( orbss[ j ], orb );
                fi;
            od;
            SortParallel( typs, orbss );
            Add( typscache[ gi ], typs );

            # the fusion of the typs of conjugacy classes into elements
            # of g/phi(g)
            orbs := List( orbss, Concatenation );
            inds := Concatenation( List( [ 1 .. Length( orbs ) ],
                                x-> x + 0 * [ 1 .. Length( orbs[ x ] ) ] ) );
            elms := Concatenation( orbs );
            ttyps :=List(t,x->Collected(List(x,y->inds[ Position(elms,y)])));
            Add( typscache[ gi ], Collected( ttyps ) );

            # classify the conjugacy classes according to the fusion
            norbss := [];
            elms := Concatenation( t );
            for orbs in orbss do
                typs := [];
                tnorbss := [];
                for orb in orbs do
                    # all elements in the conjugacy class orb of g[gi] will
                    # fuse into the same conjugacy class of g/phi(g)
                    typ := ttyps[ 1+Int((Position(elms, orb[1])-1)/fsize) ];
                    p := Position( typs, typ );
                    if p = fail then 
                        Add( typs, typ );
                        Add( tnorbss, ShallowCopy( orb ) );
                    else
                        Append( tnorbss[ p ], orb );
                    fi;
                od;
                SortParallel( typs, tnorbss );
                Add( typscache[ gi ], typs );
                Append( norbss, tnorbss );
            od;
            inds := List( norbss, Length );
            Add( typscache[ gi ], inds );
            SortParallel( inds, norbss );

            # the images of the i-th generator type of g/phi(g) for the
            # gi-th group sorted according to their priority
            gensys[ gi ][ i ] := norbss;
        od;
    od;

    # look if the information collected in 'typscache' was identicall
    t := Set( typscache );
    if Length( t ) > 1 then
        Info( InfoGrpCon, 3, " split ", n,
              " groups with typscache in ", Length( t ), " sublists" );
        return rec( subl := List( t,
            x -> list{ Filtered( [1..Length(list)], y->x=typscache[y] ) } ));
    fi;

    # find a selection from the priorisation which will produce generating
    # sets for all groups
    genpos := Concatenation( List( [ 1 .. Length( Finfo.geninds ) ], 
                                x -> x + 0 * [ 1 .. Finfo.geninds[ x ] ] ) );
    poses := Cartesian( List( genpos, x -> [ 1..Length(gensys[1][x]) ] ) );
    inds  := List( poses, x -> Product( List( [ 1 .. Finfo.lmin ],
                   y -> Length( gensys[ 1 ][ genpos[ y ] ][ x[ y ] ] ) ) ) );
    SortParallel( inds, poses );

    # test them
    i := 0;
    repeat
        i := i + 1;
        pos := poses[ i ];
        gi := 0;
        repeat
            gi := gi + 1;
            j := 1;
            repeat
                if Size( Group( List( [ 1..Finfo.lmin ], x -> Random(
                        gensys[gi][genpos[x]][ pos[x] ] ) ) ) ) = size then
                    j := -1;
                else
                    j := j + 1;
                fi;
            until j > 12 or j < 0;
        until j > 12 or gi = n;
    until j < 0 or i = Length( poses );

    if j < 0 then 
        # remove all generators which are not from the chosen strategy
        gensys := List( gensys, x -> List( [ 1 .. Finfo.lmin ],
                                       y -> x[ genpos[ y ] ][ pos[ y ] ] ) );
    else
        Info( InfoGrpCon, 1, "   no common generator strategy" );
        pos := List( pos, x -> 1 );
        gensys := List( gensys, x -> List( [ 1 .. Finfo.lmin ],
                                  y -> Concatenation( x[ genpos[ y ] ] ) ) );
    fi;

    ngensets := Product( List( gensys[ 1 ], Length ) );

    # start finding presentations
    r := List( list, x -> rec(
             hits := 0,
             codes := [] ) );
    mhits := 0;
    rem := n;
    hasAutos := false;
    disting := [ ];

    repeat
      for i in [ 1 .. n ] do
        if IsBound( r[ i ] ) then
          repeat
            gens := List( gensys[ i ], Random );
            stmp := Size( Group( gens ) );
            if stmp <> size then
              misses[ i ] := 1;
            fi;
          until stmp = size;
          code := CodeGenerators( gens, spcgs[ i ] );
          found := false;
          j := 0;
          repeat
            j := j + 1;
            if IsBound( r[ j ] ) then
              ek := Length( r[ j ].codes );
              if ek > 0 then
                k := 0;
                repeat 
                  k := k + 1;
                  found := r[ j ].codes[ k ].code = code.code;
                until found or k = ek;
              fi;
            fi;
          until found or j = n; 
          if found then
            if i = j then
              r[ i ].hits := r[ i ].hits + 1;
              mhits := Minimum( List( Compacted( r ), x -> x.hits ) );
              if not IsBound( r[i].codes[k].gens ) then
                r[i].codes[k].gens := gens;
              elif hasAutos then
                perm := PermGensGensFEM( fams[ i ], spcgs[ i ], gens, 
                                      r[ i ].codes[ k ].gens );
                if not perm in r[ i ].autos then
                  r[ i ].autos := Group( Concatenation( [ perm ],
                    GeneratorsOfGroup( r[ i ].autos ) ) );
                  r[ i ].autsize := Size( r[ i ].autos );
                  Info( InfoGrpCon, 4, " autsize: ", r[ i ].autsize );
                fi;
              fi;
            else
              k := Minimum( i, j );
              l := Maximum( i, j );
              r[ k ].hits := 0;
              mhits := 0;
              Append( r[k].codes, List( r[l].codes, x->rec(code:=x.code) ) );
              Unbind( r[ l ] );
              rem := rem - 1;
            fi;
          else
            Add( r[ i ].codes, rec( code := code.code, gens := gens ) );
          fi;
        fi;
      od;

      if mhits >= 5 and not hasAutos then
        for i in [ 1 .. n ] do
          if IsBound( r[ i ] ) then
            r[ i ].autos := Group( () );
            r[ i ].autsize := 1;
          fi;
        od;
        hasAutos := true;
        Info( InfoGrpCon, 4, " ngensets: ", ngensets );
      fi;

      if hasAutos then
        for i in [ 1 .. n ] do
          if rem > 1 and IsBound( r[ i ] ) then
            if Length( r[ i ].codes ) * r[ i ].autsize > ngensets then
              Error( "fatal Error in RandomIsomorphismTestFEM" );
            fi;
            ident := true;
            for j in [ 1 .. n ] do
              if ident and i <> j and IsBound( r[ j ] ) and 
                 LcmInt( r[ i ].autsize, r[ j ].autsize ) *
                       ( Length( r[ i ].codes ) + Length( r[ j ].codes ) )
                   + misses[ i ] <= ngensets then
                ident := false;
              fi;
            od;
            if ident then
              Info( InfoGrpCon, 2,
                    " RandomIsomorphismTestFEM identifies group" );
              AddSet( disting, i );
              Unbind( r[ i ] );
              list[ i ].isUnique := true;
              rem := rem - 1;
            fi;
          fi;
        od;
        Info( InfoGrpCon, 4, " orbs ",
              List( Compacted( r ), x -> Length( x.codes ) ) );
      fi;
      Info( InfoGrpCon, 4, " ", List( Compacted( r ), x -> x.hits ) );
    until rem = 1 or mhits > 50;

    if rem > 1 then
        Info( InfoGrpCon, 1, " ", rem,
              " candidates not seperated by RandomIsomorphismTestFEM"); 
    fi;

    return rec( 
       rem := list{ Filtered( [ 1 .. n ], x-> IsBound( r[ x ] ) ) },
       unique := list{ disting } ); 
end);

#############################################################################
##
#F ReducedByIsomorphismsFEM( list, Finfo )
##
InstallGlobalFunction( ReducedByIsomorphismsFEM, function( list, Finfo )

   local i, tlist;

   # the trivial cases of isomorphism searching
   if Length( list ) = 0 then
      return list;
   fi;
   if Length( list ) = 1 then
      list[1].isUnique := true;
      return list; 
   fi;

   Info( InfoGrpCon, 2, "  reduce ", Length(list), " groups " );

   # split up in sublist
   list := SplitUpSublistsByFpFunc( list );
   if ForAll( list, IsRecord ) then 
      return list;
   fi;

   if not IsBound( Finfo.lmin ) then 
       AddRandomTestInfosFEM( Finfo );
   fi;

   # loop over all sublists
   i := 1;
   repeat 
      if IsRecord( list[ i ] ) then
         i := i + 1;
      elif Length( list[ i ] ) = 1 then
         list[ i ] := list[ i ][ 1 ];
         list[ i ].isUnique := true;
         i := i + 1;
      else
         Info( InfoGrpCon, 2, " randiso on ", Length( list[ i ] ),
               " groups of size ", list[ i ][ 1 ].order, ", block ", i, "/",
               Length( list ) );
         list[ i ] := RandomIsomorphismTestFEM( list[ i ], Finfo );
         if IsBound( list[ i ].subl ) then
             Append( list, list[ i ].subl{[ 2 .. Length( list[ i ].subl )]});
             list[ i ] := list[ i ].subl[ 1 ];
         else
             Append( list, list[ i ].unique );
             list[ i ] := list[ i ].rem;
             if Length( list[ i ] ) = 1 then
                 list[ i ] := list[ i ][ 1 ];
                 list[ i ].isUnique := true;
             fi;
             i := i + 1;
         fi;
      fi;
   until i > Length( list );

   tlist := Filtered( list, IsList );
   Sort( tlist, function( x, y ) return Length(x) < Length(y); end );

   return Concatenation( Filtered( list, IsRecord ), tlist );
end);

#############################################################################
##
#F ReducedByIsomorphismsFEMAnother( list, frec, level )
##
## The function `ReducedByIsomorphismsFEM' allways uses the first strategy
## for the elements of the frattinifactor choiced by `AddRandomTestInfosFEM'.
## If these (and `DistinguishGroups') have failed, this function can try
## alternative elements of the frattinifactor. The function is usefull e.g.
## for some groups of size 1728.
ReducedByIsomorphismsFEMAnother := function( list, frec, level )

   local i, tlist, Finfo;

   Finfo := rec( F := PcGroupCodeRec( frec ) );
   AddRandomTestInfosFEM( Finfo, level );

   # loop over all sublists
   i := 1;
   repeat 
      if IsRecord( list[ i ] ) then
         i := i + 1;
      elif Length( list[ i ] ) = 1 then
         list[ i ] := list[ i ][ 1 ];
         list[ i ].isUnique := true;
         i := i + 1;
      else
         Info( InfoGrpCon, 2, " another randiso on ", Length( list[ i ] ),
               " groups of size ", list[ i ][ 1 ].order, ", block ", i, "/",
               Length( list ) );
         list[ i ] := RandomIsomorphismTestFEM( list[ i ], Finfo );
         if IsBound( list[ i ].subl ) then
             Append( list, list[ i ].subl{[ 2 .. Length( list[ i ].subl )]});
             list[ i ] := list[ i ].subl[ 1 ];
         else
             Append( list, list[ i ].unique );
             list[ i ] := list[ i ].rem;
             if Length( list[ i ] ) = 1 then
                 list[ i ] := list[ i ][ 1 ];
                 list[ i ].isUnique := true;
             fi;
             i := i + 1;
         fi;
      fi;
   until i > Length( list );

   tlist := Filtered( list, IsList );
   Sort( tlist, function( x, y ) return Length(x) < Length(y); end );

   return Concatenation( Filtered( list, IsRecord ), tlist );
end;
