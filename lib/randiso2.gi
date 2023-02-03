#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Hans Ulrich Besche.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

#############################################################################
##
#F  EvalFpCoc( coc, desc ). . . . . . . . . . . . . . . . . . . . . . . local
##
BindGlobal( "EvalFpCoc", function( coc, desc )
    local powers, exp, targets, result, i, j, g1, g2, fcd4, pos, map;

    if desc[ 1 ] = 1 then
        # test, if g^i in cl(g)
        return List( coc[ desc[ 2 ] ],
                     function( x )
                     if x[ 1 ] ^ desc[ 3 ] in x then return 1; fi; return 0;
                     end );

    elif desc[ 1 ] = 2 then
        # test, if cl(g) is root of cl(h)
        exp := QuoInt( Order( coc[ desc[ 2 ] ][ 1 ][ 1 ] ),
                       Order( coc[ desc[ 3 ] ][ 1 ][ 1 ] ) );
        powers := Flat( coc[ desc[ 3 ] ] );
        return List( coc[ desc[ 2 ] ],
                     function(x)
                     if x[ 1 ] ^ exp in powers then return 1; fi; return 0;
                     end );

    elif desc[ 1 ] = 3 then
        # test, if cl(g) is power of cl(h)
        exp := QuoInt( Order( coc[ desc[ 3 ] ][ 1 ][ 1 ] ),
                       Order( coc[ desc[ 2 ] ][ 1 ][ 1 ] ) );
        # just one representative for each class of power-candidates
        powers := List( coc[ desc[ 2 ] ], x -> x[ 1 ] );
        result := List( powers, x -> 0 );
        for i in List( Flat( coc[ desc[ 3 ] ] ), x -> x ^ exp ) do
            for j in [ 1 .. Length( powers ) ] do
                if i = powers[ j ] then
                    result[ j ] := result[ j ] + 1;
                fi;
            od;
        od;
        return result;

    else
        # test how often the word [ a, b ] * a^2 is hit
        targets := List( coc[ desc[ 2 ] ], x -> x[ 1 ] );
        map := [ 1 .. Length( targets ) ];
        SortParallel( targets, map );
        result := List( targets, x -> 0 );
        fcd4 := Flat( coc[ desc[ 4 ] ] );
        for g1 in Flat( coc[ desc[ 3 ] ] ) do
            for g2 in fcd4 do
                if desc[ 1 ] = 4 then
                    pos := Position( targets, Comm( g1, g2 ) * g1 ^ 2 );
                else
                # desc[ 1 ] = 5
                    pos := Position( targets, Comm( g1, g2 ) * g1 ^ 3 );
                fi;
                if not IsBool( pos ) then
                    result[ map[ pos ] ] := result[ map[ pos ] ] + 1;
                fi;
            od;
        od;
        return result;
    fi;
end );

#############################################################################
##
#F CocGroup( G ). . . . . . . . . . . . . . . . . . . . . . . . . . . . local
##
BindGlobal( "CocGroup", function( g )

   local orbs, typs, styps, coc, i, j;

   # compute the conjugacy classes of G as lists of elements and
   # classify them according to representative order and length
   orbs  := OrbitsDomain( g, AsList( g ) );
   typs  := List( orbs, x -> [ Order( x[ 1 ] ), Length( x ) ] );
   styps := Set( typs );
   coc   := List( styps, x-> [ ] );
   for i in [ 1 .. Length( styps ) ] do
      for j in [ 1 .. Length( orbs ) ] do
         if styps[ i ] = typs[ j ] then
            Add( coc[ i ], orbs[ j ] );
         fi;
      od;
   od;
   return coc;
end );

#############################################################################
##
#F DiffCoc( coc, pos, finps ) . . . . . . . . . . . . . . . . . . . . . local
##
BindGlobal( "DiffCoc", function( coc, pos, finps )

   local tmp, sfinps, i, j;

   # split up the pos-th cluster of coc using the fingerprint-values finps
   sfinps := Set( finps );
   tmp := List( sfinps, x -> [ ] );
   for i in [ 1 .. Length( sfinps ) ] do
      for j in [ 1 .. Length( finps ) ] do
         if sfinps[ i ] = finps[ j ] then
            Add( tmp[ i ], coc[ pos ][ j ] );
         fi;
      od;
   od;
   return Concatenation( coc{[1..pos-1]}, tmp, coc{[pos+1..Length(coc)]} );
end );

#############################################################################
##
#F SplitUpSublistsByFpFunc( list ). . . . . . . . . . . . . . . . . . . local
##
BindGlobal( "SplitUpSublistsByFpFunc", function( list )

   local result, finp, finps, i, g, j;

   result := [ ];
   finps := [ ];
   for i in [ 1 .. Length( list ) ] do
      if list[ i ].isUnique then
         Add( result, [ list [ i ] ] );
         Add( finps, false );
      else
         g    := PcGroupCodeRec( list[i] );
         finp := FingerprintFF( g );
         j    := Position( finps, finp );
         if IsBool( j ) then
            Add( result, [ list[ i ] ] );
            Add( finps, finp );
            Info( InfoRandIso, 3, "split into ", Length( finps ),
                  " classes within ", i, " of ", Length( list ), " tests" );
         else
            Add( result[ j ], list[ i ] );
            if i mod 50 = 0 then
              Info( InfoRandIso, 3, "still ", Length( finps ),
                    " classes after ", i, " of ", Length( list ), " tests" );
            fi;
         fi;
      fi;
   od;
   for i in [ 1 .. Length( result ) ] do
      if Length( result[ i ] ) = 1 then
         result[ i ] := result[ i ][ 1 ];
         result[ i ].isUnique := true;
      fi;
   od;
   Info( InfoRandIso, 2, "   Iso: found ", Length(result)," classes incl. ",
          Number( result, IsRecord )," unique groups");
   return result;
end );

#############################################################################
##
#F CodeGenerators( gens, spcgs ). . . . . . . . . . . . . . . . . . . . local
##
BindGlobal( "CodeGenerators", function( gens, spcgs )

   local  layers, first, one, pcgs, sgrps, dep, lay,
          numf, pos, e, tpos, found, et, p;

   gens   := ShallowCopy( gens );
   layers := LGLayers( spcgs );
   first  := LGFirst( spcgs );
   one    := OneOfPcgs( spcgs );
   pcgs   := [ ];
   sgrps  := [ ];

   numf   := 0;
   pos    := 0;

   while numf < Length( spcgs ) do
      pos := pos + 1;
      e   := gens[ pos ];
      while e <> one do

         dep := DepthOfPcElement( spcgs, e );
         lay := layers[ dep ];
         tpos := first[ lay + 1 ];
         found := false;

         while tpos > first[ lay ] and not found and e <> one do
            tpos := tpos - 1;
            if not IsBound( pcgs[ tpos ] ) then
               pcgs[ tpos ] := e;
               sgrps[ tpos ] := GroupByGenerators( Concatenation( [ e ],
                                pcgs{[ tpos + 1 .. first[ lay + 1 ] - 1 ]},
                                spcgs{[ first[lay+1] .. Length(spcgs) ]} ) );
               for p in PrimeDivisors( Order( e ) ) do
                  et := e ^ p;
                  if et <> one and not et in gens then
                     Add( gens, et );
                  fi;
               od;
               for p in Compacted( pcgs ) do
                  et := Comm( e, p );
                  if et <> one and not et in gens then
                     Add( gens, et );
                  fi;
               od;
               e := one;
               numf := numf + 1;
            else
               if e in sgrps[ tpos ] then
                  found := true;
               fi;
            fi;
         od;
         if found then
            while tpos < first[ lay + 1 ] do
               if tpos + 1 = first[ lay + 1 ] then
                  while e <> one and
                        lay = layers[ DepthOfPcElement( spcgs, e ) ] do
                     e := pcgs[ tpos ] ^ -1 * e;
                  od;
               else
                  while not e in sgrps[ tpos + 1 ] do
                     e := pcgs[ tpos ] ^ -1 * e;
                  od;
               fi;
               tpos := tpos + 1;
            od;
         fi;
      od;
   od;
   pcgs := PcgsByPcSequenceNC( ElementsFamily( FamilyObj( spcgs ) ), pcgs );
   SetRelativeOrders( pcgs, RelativeOrders( spcgs ) );
   return rec( pcgs := pcgs, code := CodePcgs( pcgs ) );
end );

#############################################################################
##
#F IsomorphismSolvableSmallGroups( G, H  ). . . . . isomorphism from G onto H
##
BindGlobal( "IsomorphismSolvableSmallGroups", function( g, h )
   local size, coc1, coc2, lcoc, coclen, p, poses, nposes, i, qual, nqual,
         lmin, spcgs1, spcgs2, gens, code, gens1, gens2, codes1, codes2,
         G, H, iso, iso1, iso2;

   size := Size( g );
   if size <> Size( h ) then
      return fail;
   fi;
   if size = 1 then
     return GroupHomomorphismByImagesNC( g, h, [], [] );
   fi;
   if ID_AVAILABLE( size ) = fail or size > 2000 then
      Error( "IsomorphismSmallSolvableGroups: groups are not small" );
   fi;
   if IdGroup( g ) <> IdGroup( h ) then
      return fail;
   fi;
   if not IsSolvableGroup( g ) then
      Error( "IsomorphismSmallSolvableGroups: groups are not solvable" );
   fi;

   if IsPcGroup( g ) then
      G := g;
   else
      iso1 := IsomorphismPcGroup( g );
      G := Image( iso1 );
   fi;
   if IsPcGroup( h ) then
      H := h;
   else
      iso2 := IsomorphismPcGroup( h );
      H := Image( iso2 );
   fi;

   coc1 := CocGroup( G );
   coc1 := List( coc1{[ 2 .. Length( coc1 ) ]}, Concatenation );
   coc2 := CocGroup( H );
   coc2 := List( coc2{[ 2 .. Length( coc2 ) ]}, Concatenation );
   lcoc := Length( coc1 );
   coclen := List( coc1, Length );

   lmin := Length( MinimalGeneratingSet( G ) );
   qual := size ^ lmin;
   poses := fail;
   i := - Length( Factors(Integers, size ) ) * 5 - lcoc * 8 - lmin * 12;
   Info( InfoRandIso, 3, "testing ", -i, " generating strategies" );
   while poses = fail or i < 0 do
      i := i + 1;
      nposes := List( [ 1 .. lmin ], x -> Random( 1, lcoc ) );
      nqual := Product( coclen{ nposes } );
      if nqual < qual and
          Size( Group( List( coc1{ nposes }, Random ) ) ) = size then
         qual := nqual;
         poses := nposes;
      fi;
   od;
   Info( InfoRandIso, 2, "strategy with ",qual," generating set candidates");

   coc1 := coc1{ poses };
   coc2 := coc2{ poses };
   gens1 := [];
   gens2 := [];
   codes1 := [];
   codes2 := [];
   spcgs1 := SpecialPcgs( G );
   spcgs2 := SpecialPcgs( H );
   iso := fail;
   i := 0;

   while iso = fail do
      i := i + 1;
      if i mod 10 = 0 then
         Info( InfoRandIso, 3, i, " test on generating set candidates" );
      fi;
      if gens1 = [] then
         gens := ShallowCopy( GeneratorsOfGroup( G ) );
      else
         gens := List( coc1, Random );
      fi;
      if Size( Group( gens ) ) = size then
         code := CodeGenerators( gens, spcgs1 );
         p := Position( codes2, code.code );
         if p <> fail then
            iso := GroupHomomorphismByImagesNC( G, H, code.pcgs,
                                 CodeGenerators( gens2[ p ], spcgs2 ).pcgs );
         fi;
         if not code.code in codes1 then
            Add( codes1, code.code );
            Add( gens1, gens );
         fi;
      fi;
      if iso = fail then
         if gens2 = [] then
            gens := ShallowCopy( GeneratorsOfGroup( H ) );
         else
            gens := List( coc2, Random );
         fi;
         if Size( Group( gens ) ) = size then
            code := CodeGenerators( gens, spcgs2 );
            p := Position( codes1, code.code );
            if p <> fail then
               iso := GroupHomomorphismByImagesNC( G, H,
                       CodeGenerators( gens1[ p ], spcgs1 ).pcgs, code.pcgs);
            fi;
            if not code.code in codes2 then
               Add( codes2, code.code );
               Add( gens2, gens );
            fi;
         fi;
      fi;
   od;

   gens := GeneratorsOfGroup( g );
   if IsBound( iso1 ) then
      gens := List( gens, x -> Image( iso1, x ) );
   fi;
   gens := List( gens, x -> Image( iso, x ) );
   if IsBound( iso2 ) then
      gens := List( gens, x -> PreImage( iso2, x ) );
   fi;
   return GroupHomomorphismByImagesNC( g, h, GeneratorsOfGroup( g ), gens );
end );
