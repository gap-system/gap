#############################################################################
##
#W  randiso2.gi               GAP library                  Hans Ulrich Besche
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.randiso2_gi :=
    "@(#)$Id$";

if not IsBound( MyFingerprintFF ) then
    MyFingerprintFF := false;
fi;

#############################################################################
##
#F FingerprintFF( G ) 
##
FingerprintFF := function( G ) 
    return Flat( Collected( List( Orbits( G , List( G ) ), 
       y -> [ Order ( y[ 1 ] ), Length( y ) , y[ 1 ] ^ 3 in y , 
       y[ 1 ] ^ 5 in y , y[ 1 ] ^ 7 in y ] ) ) );
end;

#############################################################################
##
#F Fingerprint2FF( G ) 
##
Fingerprint2FF := function( G ) 
    return rec( fpff := FingerprintFF ( G ),
                sid  := IdGroup( SylowSubgroup( G, 2 ) ) );
end;

#############################################################################
##
#F  EvalFpCoc( coc, desc ). . . . . . . . . . . . . . . . . . . . . . . local
##
EvalFpCoc := function( coc, desc )
    local powers, exp, targets, result, i, j, g1, g2, fcd4, pos;

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
                    result[ pos ] := result[ pos ] + 1;
                fi;
            od;
        od;
        return result;
    fi;
end;

#############################################################################
##
#F CocGroup( G ). . . . . . . . . . . . . . . . . . . . . . . . . . . . local
##
CocGroup := function( g )

   local orbs, typs, styps, coc, i, j;

   # compute the conjugacy classes of G as lists of elements and
   # classify them according to representative order and length
   orbs  := Orbits( g, AsList( g ) );
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
end;

#############################################################################
##
#F DiffCoc( coc, pos, finps ) . . . . . . . . . . . . . . . . . . . . . local
##
DiffCoc := function( coc, pos, finps )

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
   end;

#############################################################################
##
#F DiffCocList( <coclist>, <flagwordtest> ) . . . . . . . . . . . . . . local
##
DiffCocList := function( coclist, flagwordtest )

   # coclist is a list of CocGroup's of some groups. DiffCocList tries to
   # find, if necessary recursive, some "tests" which will differentiate
   # the groups, or at least, to differentiate the clusters of the
   # CocGroup's. If flagwordtest is true, then beside the investigation
   # of the powermaps, additionally some words will be evaluated on the
   # classes.

   local i, j, k, ii, jj, kk, pos, word, lencoc,
         fpcand, fpqual, orders, finps, sfinps,
         qual, mqual, qualfp, hits, phits, cphits, poses, leading;

   Info( InfoFrattExt, 4, "    DiffCocList starts" );

   # general informations
   orders := List( coclist[ 1 ], x -> Order( x[ 1 ][ 1 ] ) );
   lencoc := Length( coclist[ 1 ] );

   # create a list of usefull tests on the powermap
   fpcand := [ ];
   for i in [ 2 .. lencoc ] do
      for j in Filtered( [ 2..orders[i]-1 ], x -> Gcd( x, orders[i]) = 1 ) do
         # test, if classes in cluster i are invariant under galois-
         # conjugation to the j-th power
         Add( fpcand, [ 1, i, j ] );
      od;
   od;
   for i in [ 2 .. lencoc - 1 ] do
      for j in [ i + 1 .. lencoc ] do
         if orders[ j ] mod orders[ i ] = 0 then
            # 2, j, i: test if classes in cluster i are roots of classes in j
            # 3, i, j: ... powers
            Append( fpcand, [ [ 2, j, i ], [ 3, i, j ] ] );
         fi;
      od;
   od;

   # try the tests and register the number of groups / clusters they split
   fpqual := [ ];
   for i in [ 1 .. Length( fpcand) ] do
      finps := List( coclist, x -> Collected( EvalFpCoc( x, fpcand[i] ) ) );
      sfinps := Set( finps );
      if Length( sfinps ) = Length( coclist ) then
         # fpcand[ i ] will split into lists of length 1
         return [ fpcand[ i ] ];
         Info( InfoFrattExt, 4, "    DiffCocList split ", Length( coclist ),
                                " groups up" );
      fi;
      Add( fpqual, [ Length( sfinps ), Length( finps[ 1 ] ) ] );
   od;

   # find the test best spliting the list of groups
   pos := Position( fpqual, Maximum( fpqual ) );
   if fpqual[ pos ][ 1 ] > 1 then
      Info( InfoFrattExt, 4, "    DiffCocList split ", Length( coclist ),
                             " groups in ", fpqual[ pos ][ 1 ], " classes" );
      return [ fpcand[ pos ] ];
   fi;

   # find the test best spliting the clusters and call DiffCocList recursive
   if fpqual[ pos ][ 2 ] > 1 then 
      for j in [ 1 .. Length( coclist ) ] do
         coclist[ j ] := DiffCoc( coclist[ j ], fpcand[ pos ][ 2 ],
                                  EvalFpCoc( coclist[ j ], fpcand[ pos ] ) );
      od;
      # storage optimisation in recursive calls
      Unbind( fpqual );
      fpcand := fpcand[ pos ];
      return Concatenation( [fpcand], DiffCocList( coclist, flagwordtest ) );
   fi;

   # the tests concerning the powermap failed all
   if not flagwordtest then
      Info( InfoFrattExt, 4, "    DiffCocList failed without wordtest" );
      return [ fail ];
   fi;

   Info( InfoFrattExt, 4, "    DiffCocList starts wordtest" );
   mqual := [ 0, 0 ];
   qualfp := [ ];
   leading := List( coclist, x -> List( Concatenation( x ), y -> y [ 1 ] ) );
   poses := [ ];
   i := 0;
   for j in coclist[ 1 ] do
      Add( poses, [ i + 1 .. i + Length ( j ) ] );
      i := i + Length( j );
   od;

   # loop over the sugested words 
   # 4: Comm( g1, g2 ) * a ^ 2
   # 5: Comm( g1, g2 ) * a ^ 3
   for word in [ 4 .. 5 ] do
      for j in [ 2 .. lencoc ] do
         for k in [ 2 .. lencoc ] do

            # check up desc's [ 4, x, j, k ], count hits
            hits := List( coclist, x -> List( leading[ 1 ], x -> 0 ) );
            for i in [ 1 .. Length( coclist ) ] do
               for jj in Concatenation( coclist[ i ][ j ] ) do
                  for kk in Concatenation( coclist[ i ][ k ] ) do
                     if word = 4 then
                        pos := Position( leading[i], Comm( jj,kk) * jj ^ 2 );
                     elif word = 5 then
                        pos := Position( leading[i], Comm( jj,kk) * jj ^ 3 );
                     fi;
                     if pos <> fail then
                        hits[ i ][ pos ] := hits[ i ][ pos ] + 1;
                     fi;
                  od;
               od;
            od;

            # analyse hits
            for i in [ 1 .. Length( coclist[ 1 ] ) ] do
               phits := hits{[ 1 .. Length( coclist ) ]}{ poses[ i ] };
               cphits := List( phits, Collected );
               qual := [ Length( Set( cphits ) ), Length( cphits[ 1 ] ) ];
               if qual > mqual then

                  # note this test
                  qualfp := [ 4, i, j, k ];
                  if qual[ 1 ] = Length( coclist ) then 
                     Info( InfoFrattExt, 4, "    DiffCocList split ",
                                 Length( coclist ), " groups in ", qual[ 1 ],
                                 " classes" );
                     return [ qualfp ];
                  fi;
                  mqual := qual;
               fi;
            od;
         od;
      od;
   od;

   if mqual = [ 1, 1 ] then
      Info( InfoFrattExt, 4, "    DiffCocList failed after wordtest" );
      return  [ fail ];
   fi;

   if mqual[ 1 ] > 1 then
      Info( InfoFrattExt, 4, "    DiffCocList split ", Length( coclist ),
                             " groups in ", mqual[ 1 ], " classes" );
      return [ qualfp ];
   fi;

   # split up clusters
   for j in [ 1 .. Length( coclist ) ] do
      coclist[ j ] := DiffCoc( coclist[ j ], qualfp[ 2 ],
                                  EvalFpCoc( coclist[ j ], qualfp ) );
   od;
   Unbind( fpqual );
   Unbind( fpcand );
   return Concatenation( [ qualfp ], DiffCocList( coclist, true ) );

end;
               
#############################################################################
##
#F FetchPropertiesFrattiniFreeGroup( <ff> ) . . . . . . . . . . . . . . local
##
FetchPropertiesFrattiniFreeGroup := function( ff )

   local fftab, pos;

   # table of properties of the frattinifree groups
   fftab := [
      # S3x2
      [ [ 12, 4 ],     [ 3, 5 ],        [ , 12 ]           ], 
      # D10x2
      [ [ 20, 4 ],     [ 3, 5 ],        [ , 20 ]           ], 
      # S4
      # first the IdGroup
      [ [ 24, 12 ],
      # index of the clusters of conjugacy classes of the chosen generators
                       [ 4, 3 ],
      # size of the subgroup generated by the first generators
                                        [ , 24 ]           ],
      # A4x2
      [ [ 24, 13 ],    [ 4, 3 ],        [ , 24 ]           ],
      # S3x2^2
      [ [ 24, 14 ],    [ 5, 2, 3 ],     [ , 12, 24 ]       ],
      # D14x2
      [ [ 28, 3 ],     [ 3, 5 ],        [ , 28 ]           ], 
      # S3^2
      [ [ 36, 10 ],    [ 6, 3 ],        [ , 36 ]           ],
      # A4x3
      [ [ 36, 11 ],    [ 4, 5 ],        [ , 36 ]           ],
      # S3x6
      [ [ 36, 12 ],    [ 3, 7 ],        [ , 36 ]           ],
      # 2x3^2:2
      [ [ 36, 13 ],    [ 4, 5, 3 ],     [ , 18, 36 ]       ],
      # 2x5:4
      [ [ 40, 12 ],    [ 4, 6 ],        [ , 40 ]           ],
      # D10x2^2
      [ [ 40, 13 ],    [ 3, 5, 2 ],     [ , 20, 40 ]       ],
      # D22x2
      [ [ 44, 3 ],     [ 3, 5 ],        [ , 44 ]           ], 
      # S4x2
      [ [ 48, 48 ],    [ 4, 7 ],        [ , 48 ]           ],
      # S3x2^3
      [ [ 48, 51 ],    [ 3, 5, 2, 2 ],  [ , 12, 24, 48 ]   ],
      # D26x2
      [ [ 52, 4 ],     [ 3, 5 ],        [ , 52 ]           ], 
      # S3x3^2
      [ [ 54, 12 ],    [ 5, 4 ],        [ , 54 ]           ],
      # 3x3^2:2
      [ [ 54, 13 ],    [ 5, 2, 2 ],     [ , 18, 54 ]       ],
      # D14x2^2
      [ [ 56, 12 ],    [ 5, 2, 3 ],     [ , 28, 56 ]       ],
      # S3xD10
      [ [ 60, 8 ],     [ 8, 7 ],        [ , 60 ]           ], 
      # D10x6
      [ [ 60, 10 ],    [ 7, 8 ],        [ , 60 ]           ], 
      # S3x10
      [ [ 60, 11 ],    [ 10, 3 ],       [ , 60 ]           ], 
      # D60
      [ [ 60, 12 ],    [ 3, 9 ],        [ , 60 ]           ], 
      [ [ 72, 40 ],    [ 5, 2 ],        [ , 72 ]           ], 
      # 2x3^2:4
      [ [ 72, 45 ],    [ 5, 6 ],        [ , 72 ]           ], 
      # S3^2x2
      [ [ 72, 46 ],    [ 3, 8, 3 ],     [ , 36, 72 ]       ],
      # A4x6
      [ [ 72, 47 ],    [ 5, 7 ],        [ , 72 ]           ], 
      # S3x2x6
      [ [ 72, 48 ],    [ 3, 7, 2 ],     [ , 36, 72 ]       ],
      # 2^2x3^2:2
      [ [ 72, 49 ],    [ 5, 5, 3 ],     [ , 36, 72 ]       ],
      # 2^2x5:4
      [ [ 80, 50 ],    [ 4, 6, 2 ],     [ , 40, 80 ]       ],
      # D10x2^3
      [ [ 80, 51 ],    [ 5, 2, 2, 3 ],  [ , 20, 40, 80 ]   ],
      # S3xD14
      [ [ 84, 8 ],     [ 8, 6 ],        [ , 84 ]           ], 
      # D14x6
      [ [ 84, 12 ],    [ 6, 8 ],        [ , 84 ]           ], 
      # D84
      [ [ 84, 14 ],    [ 3, 9 ],        [ , 84 ]           ], 
      # D22x2^2
      [ [ 88, 11 ],    [ 5, 2, 3 ],     [ , 44, 88 ]       ],
      # S4x2^2
      [ [ 96, 226 ],   [ 7, 4, 2 ],     [ , 48, 96 ]       ],
      # S3x2^4
      [ [ 96, 230 ],   [ 3, 5, 2, 2, 2 ], [ , 12, 24, 48, 96 ] ],
      # S4+S4 
      [ [ 96, 227 ],   [ 6, 5 ],        [ , 96 ]           ],
      # D10^2 
      [ [ 100, 13 ],   [ 6, 3 ],        [ , 100 ]          ],
      # 2x5^2:2 
      [ [ 100, 15 ],   [ 4, 5, 3 ],     [ , 50, 100 ]      ],
      [ [ 104, 12 ],   [ 4, 6 ],        [ , 104 ]          ],
      [ [ 104, 13 ],   [ 3, 5, 2 ],     [ , 52, 104 ]      ],
      [ [ 108, 38 ],   [ 3, 8 ],        [ , 108 ]          ],
      [ [ 108, 39 ],   [ 7, 8, 3 ],     [ , 36, 108 ]      ],
      [ [ 108, 41 ],   [ 4, 5, 3 ],     [ , 36, 108 ]      ],
      [ [ 108, 42 ],   [ 8, 7 ],        [ , 108 ]          ],
      [ [ 108, 43 ],   [ 3, 7, 3 ],     [ , 36, 108 ]      ],
      # D14x2^3
      [ [ 112, 42 ],   [ 3, 5, 2, 2 ],  [ , 28, 56, 112 ]  ],
      [ [ 120, 36 ],   [ 7, 10 ],       [ , 120 ]          ],
      [ [ 120, 40 ],   [ 10, 9 ],       [ , 120 ]          ],
      [ [ 120, 41 ],   [ 5, 11 ],       [ , 120 ]          ],
      [ [ 120, 42 ],   [ 11, 8, 4 ],    [ , 60, 120 ]      ],
      [ [ 120, 44 ],   [ 10, 2, 3 ],    [ , 60, 120 ]      ],
      [ [ 120, 45 ],   [ 10, 2, 3 ],    [ , 60, 120 ]      ],
      [ [ 120, 46 ],   [ 9, 2, 3 ],     [ , 60, 120 ]      ],
      [ [ 136, 14 ],   [ 5, 2, 3 ],     [ , 68, 136 ]      ],
      [ [ 144, 183 ],  [ 5, 14 ],       [ , 144 ]          ],
      [ [ 144, 186 ],  [ 6, 7, 3 ],     [ , 72, 144 ]      ],
      [ [ 144, 187 ],  [ 5, 3, 5 ],     [ , 72, 144 ]      ],
      [ [ 144, 188 ],  [ 4, 11 ],       [ , 144 ]          ],
      [ [ 144, 190 ],  [ 4, 11 ],       [ , 144 ]          ],
      # (2x3^2:4)x2
      [ [ 144, 191 ],  [ 5, 6, 2 ],     [ , 72, 144 ]      ], 
      # S3^2x2^2
      [ [ 144, 192 ],  [ 3, 8, 3, 2 ],  [ , 36, 72, 144 ]  ],
      # S3x2^2x6
      [ [ 144, 195 ],  [ 3, 7, 2, 2 ],  [ , 36, 72, 144 ]  ],
      # (2^2x3^2:2)x2
      [ [ 144, 196 ],  [ 5, 5, 3, 2 ],  [ , 36, 72, 144 ]  ],
      [ [ 152, 11 ],   [ 3, 5, 2 ],     [ , 76, 152 ]      ],
      [ [ 168, 47 ],   [ 5, 3, 2 ],     [ , 84, 168 ]      ],
      # S3xD14x2
      [ [ 168, 50 ],   [ 11, 8, 2 ],    [ , 84, 168 ]      ], 
      # D14x6x2
      [ [ 168, 54 ],   [ 6, 8, 2 ],     [ , 84, 168 ]      ], 
      [ [ 168, 55 ],   [ 7, 5, 3 ],     [ , 84, 168 ]      ],
      # D84x2
      [ [ 168, 56 ],   [ 3, 9, 2 ],     [ , 84, 168 ]      ], 
      # D22x2^3
      [ [ 176, 41 ],   [ 5, 2, 3, 2 ],  [ , 44, 88, 176 ]  ],
      [ [ 184, 11 ],   [ 3, 5, 2 ],     [ , 92, 184 ]      ],
      # S4x2^3
      [ [ 192, 1537 ], [ 7, 4, 2, 2 ],  [ , 48, 96, 192 ]  ],
      # S3x2^5
      [ [ 192, 1542 ], [ 3, 5, 2, 2, 2, 2 ], [ , 12, 24, 48, 96, 192 ] ],
      # S4+S4x2
      [ [ 192, 1538 ], [ 7, 8 ],        [ , 192 ]          ],
      [ [ 200, 49 ],   [ 9, 4, 2 ],     [ , 100, 200 ]     ],
      [ [ 200, 50 ],   [ 3, 7, 2 ],     [ , 100, 200 ]     ],
      # (2x5^2:2 )x2
      [ [ 200, 51 ],   [ 3, 5, 5 ],     [ , 20, 200 ]      ],
      [ [ 208, 49 ],   [ 4, 6, 2 ],     [ , 104, 208 ]     ],
      [ [ 208, 50 ],   [ 3, 5, 2, 2 ],  [ , 52, 104, 208 ] ],
      [ [ 216, 162 ],  [ 8, 9, 2 ],     [ , 108, 216 ]     ],
      [ [ 216, 170 ],  [ 10, 11, 3 ],   [ , 108, 216 ]     ],
      [ [ 216, 171 ],  [ 10, 9, 4 ],    [ , 108, 216 ]     ],
      [ [ 216, 172 ],  [ 8, 8, 2 ],     [ , 108, 216 ]     ],
      [ [ 216, 174 ],  [ 8, 7, 2 ],     [ , 108, 216 ]     ],
      [ [ 216, 175 ],  [ 3, 3, 8 ],     [ , 12, 216 ]      ],
      [ [ 216, 176 ],  [ 5, 4, 3, 5 ],  [ , 18, 36, 216 ]  ],
      [ [ 232, 13 ],   [ 3, 5, 2 ],     [ , 116, 232 ]     ],
      [ [ 240, 194 ],  [ 6, 15 ],       [ , 240 ]          ],
      [ [ 240, 195 ],  [ 14, 12, 3 ],   [ , 120, 240 ]     ],
      [ [ 240, 197 ],  [ 4, 12 ],       [ , 240 ]          ],
      [ [ 240, 198 ],  [ 13, 5 ],       [ , 240 ]          ],
      [ [ 240, 200 ],  [ 10, 9, 2 ],    [ , 120, 240 ]     ],
      [ [ 240, 201 ],  [ 5, 11, 2 ],    [ , 120, 240 ]     ],
      [ [ 240, 202 ],  [ 11, 8, 4, 2 ], [ , 60, 120, 240 ] ],
      [ [ 240, 205 ],  [ 10, 2, 3, 2 ], [ , 60, 120, 240 ] ],
      [ [ 240, 206 ],  [ 10, 2, 3, 2 ], [ , 60, 120, 240 ] ],
      [ [ 240, 207 ],  [ 9, 2, 3, 2 ],  [ , 60, 120, 240 ] ],
      [ [ 248, 11 ],   [ 3, 5, 2 ],     [ , 124, 248 ]     ] ];

   if not IsInt( ff ) then
       if Size( ff ) > 1000 or Size( ff ) in [ 256, 512, 768 ] then
           return fail;
       fi;
       pos := PositionSorted( fftab{[ 1 .. Length( fftab ) ]}[ 1 ],
                              IdGroup( ff ) );
       if pos = fail then
           return fail;
       fi;
   else
       if ff > Length( fftab ) then
           return fail;
       fi;
       pos := ff;
   fi;
   return fftab[ pos ];
end;
       
#############################################################################
##
#F SplitUpSublistsByFpFunc( list ). . . . . . . . . . . . . . . . . . . local
##
SplitUpSublistsByFpFunc := function( list )

   local result, finp, finps, i, g, j, fpfunc;

   if IsFunction( MyFingerprintFF ) then
       fpfunc := MyFingerprintFF;
   else
       fpfunc := FingerprintFF;
   fi;
   result := [ ];
   finps := [ ];
   for i in [ 1 .. Length( list ) ] do
      if list[ i ].isUnique then 
         Add( result, [ list [ i ] ] );
         Add( finps, false );
      else
         g    := PcGroupCodeRec( list[i] );
         finp := fpfunc( g );
         j    := Position( finps, finp );
         if IsBool( j ) then
            Add( result, [ list[ i ] ] );
            Add( finps, finp );
            Info( InfoFrattExt, 5, "split into ", Length( finps ),
                  " classes within ", i, " of ", Length( list ), " tests");
         else
            Add( result[ j ], list[ i ] );
         fi;
      fi;
   od;
   for i in [ 1 .. Length( result ) ] do
      if Length( result[ i ] ) = 1 then
         result[ i ][ 1 ].isUnique := true;
      fi;
   od;
   Info( InfoFrattExt, 4, "   Iso: found ", Length(result)," classes incl. ",
          Length( Filtered( result, x -> Length(x) = 1 ) )," unique groups");
   return result;
end;

#############################################################################
##
#F CodeGenerators( gens, spcgs ). . . . . . . . . . . . . . . . . . . . local
##
CodeGenerators := function( gens, spcgs )

   local  layers, first, one, pcgs, sgrps, dep, lay, 
          numf, pos, e, tpos, found, et, p;

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
               sgrps[ tpos ] := Group( Concatenation( [ e ],
                                pcgs{[ tpos + 1 .. first[ lay + 1 ] - 1 ]},
                                spcgs{[ first[lay+1] .. Length(spcgs) ]} ) );
               for p in Set( FactorsInt( Order( e ) ) ) do
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
   return CodePcgs( pcgs );
end;
      
#############################################################################
##
#F CandidateSystemGenerators( G, coc, prop ). . . . . . . . . . . . . . local
##
CandidateSystemGenerators := function( G, coc, prop )

   local k, l, m, n, frattsize, pos, t1p, t1f, t2p, t2f, gensys,
         fhom, concoc, fcoc, felms, elms, elmsr, felmtyp, felmtyps, cfelmtyp,
         collfelmtyps, qual, relclu, cfelmtyp2, mcfelmtyp2;

   frattsize := Size( G ) / prop[ 3 ][ Length( prop[ 3 ] ) ];
   concoc := List( coc, Concatenation );
   fhom := NaturalHomomorphismByNormalSubgroup( G, FrattiniSubgroup( G ) );
   fcoc := CocGroup( Range( fhom ) );
   gensys := rec( origsys := [ ], facsys := [ ] );

   for k in [ 1 .. Length( prop[ 2 ] ) ] do
      felms := Flat( fcoc[ prop[ 2 ][ k ] ] );
      # and the corresponding preimages of the group
      elms := List( felms, x -> AsList( PreImages( fhom, x ) ) );
      # for each element of the frattinifactor it is tried to restrict the
      # preimages to a subset which could be recognized
      elmsr := [ ];
      # this restriction gives a fingerprint of the elements of the factor
      felmtyps := [ ];
      for l in elms do
         felmtyp := [ ];
         for m in l do
            # find the cluster-index of the preimage m
            pos := 0;
            n := 2;
            while pos = 0 do
               if m in concoc[ n ] then
                  pos := n;
               fi;
               n := n + 1;
            od;
            Add( felmtyp, pos );
         od;
         # make the fingerprint idenpended of rowing
         cfelmtyp := Collected( felmtyp );
         cfelmtyp2 := List( cfelmtyp, x -> x[ 2 ] );
         # find the minimal number of recognible preimages
         mcfelmtyp2 := Minimum( cfelmtyp2 );
         relclu := cfelmtyp[ Position( cfelmtyp2, mcfelmtyp2 ) ][ 1 ];
         Add( felmtyps, [ cfelmtyp, mcfelmtyp2 ] );
         # the preimages which should be used
         Add( elmsr, l{ Filtered( [ 1..frattsize ], x->felmtyp[x]=relclu )});
      od;

      # priorize the generators of the factor by  their preimages
      collfelmtyps := Collected( felmtyps );
      # the number of preimages of a typ of generators of the factor group
      qual := List( collfelmtyps, x -> x[ 2 ] * x[ 1 ][ 2 ] );
      collfelmtyps := List( collfelmtyps, x -> x[ 1 ] );
      SortParallel( qual, collfelmtyps );

      t2f := [ ];
      t2p := [ ];
      for l in collfelmtyps do
         t1f := [ ];
         t1p := [ ];
         for m in [ 1 .. Length( felms ) ] do
            if felmtyps[ m ] = l then
               Add( t1f, felms[ m ] );
               Add( t1p, elmsr[ m ] );
            fi;
         od;
         Add( t2f, t1f );
         Add( t2p, t1p );
      od;
      Add( gensys.facsys, t2f );
      Add( gensys.origsys, t2p );
   od;
   return gensys;
end;

#############################################################################
##
#F RandomGeneratorsFF( candsys, gensize, reclevel )
##
RandomGeneratorsFF := function( candsys, gensize, recurlevel )

   local j, k, prio, flagin, search, leftgens, genlen, t3p, t3f,
         genso, gensf, gensubgrp;

   genlen := Length( gensize );
   t3p := candsys.origsys;
   t3f := candsys.facsys;

   # the first generator is easy to choose
   j := Random( [ 1 .. Length( t3f[ 1 ][ 1 ] ) ] );
   # gensf will contain the generators of the Frattini-factorgroup
   gensf := [ t3f[ 1 ][ 1 ][ j ] ];
   gensubgrp := Group( gensf );
   # genso will contain the generators of the group
   genso := [ Random( t3p[ 1 ][ 1 ][ j ] ) ];

   # the other generators could just be fetched if they generate a subgroup
   # of the frattini-faktor of the given size
   for j in [ 2 .. genlen ] do

      # try the generators the way they were priorised
      prio := 1;
      leftgens := [ 1 .. Length( t3f[ j ][ 1 ] ) ];
      flagin := ( j > 2 ) and ( gensize[ j ] / gensize[ j - 1 ] = 2 );
      search := true;

      while search do
         if leftgens = [ ] then
            prio := prio + 1;
            if prio > Length( t3f[ j ] ) then
                # a "wrong class" of generators might be priorised
                if recurlevel > 5 then 
                    # kill priorisation
                    candsys.origsys := List( candsys.origsys,
                                             x -> [ Concatenation( x ) ] );
                    candsys.facsys := List( candsys.facsys,
                                             x -> [ Concatenation( x ) ] );
                    Info( InfoFrattExt, 2, "   mayor problem in ",
                                 "RandomGeneratorsFF, use dumb method" );
                fi;
                Info( InfoFrattExt, 4, "   minor problem in ",
                                       "RandomGeneratorsFF, try again" );
                return RandomGeneratorsFF( candsys,gensize,recurlevel+1);
            fi;
            leftgens := [ 1 .. Length( t3f[ j ][ prio ] ) ];
         fi;
         k := Random( leftgens );
         leftgens := Difference( leftgens, [ k ] );
         if flagin then 
            search := t3f[ j ][ prio ][k] in gensubgrp;
         else 
            search := Size( Group( Concatenation( gensf, 
                [ t3f[ j ][ prio ][ k ] ] ) ) ) <> gensize[ j ];
         fi;
      od;

      Add( gensf, t3f[ j ][ prio ][ k ] );
      gensubgrp := Group( gensf );
      Add( genso, Random( t3p[ j ][ prio ][ k ] ) );
   od;
   return genso;
end;

#############################################################################
##
#F RandomIsomorphismTestFF( list, prop )
##
RandomIsomorphismTestFF := function( list, prop )

   local pcgss, grps, cocs, candsyss, j, k, l, gn, loops, numcand,
         gens, code, newresult, hits, remaining;

   grps  := List( list, PcGroupCodeRec );
   pcgss := List( grps, SpecialPcgs );
   cocs  := List( grps, CocGroup );

   numcand := Length( list );

   candsyss := [ ];
   for j in [ 1 .. numcand ] do
      Add( candsyss, CandidateSystemGenerators( grps[j], cocs[j], prop ) );
   od;

   loops     := 0;
   hits      := List( grps, x -> 0 );
   newresult := List( grps, x -> [ ] );
   remaining := numcand;

   # loop for the guessing of presentations
   while Minimum( hits ) < 10 and remaining > 1 do

      if loops mod 10 = 0 or loops in [ 1, 2, 4, 7, 15, 25 ] then
         Info( InfoFrattExt, 5, loops, " loops\n# ", hits{ Filtered(
                      [ 1 .. numcand ], x -> IsBound( newresult[ x ] ) ) } );
      fi;

      loops := loops + 1;
      for gn in [ 1 .. numcand ] do
         if IsBound( newresult[ gn ] ) then
            gens := RandomGeneratorsFF( candsyss[ gn ], prop[ 3 ], 0 );
            code := CodeGenerators( gens, pcgss[ gn ] );

            if code in newresult[ gn ] then
               hits[ gn ] := hits[ gn ] + 1;

            else
               Add( newresult[ gn ], code );
               for j in [ 1 .. numcand ] do
                  if j <> gn and IsBound( newresult[ j ] ) 
                                     and code in newresult[ j ] then
                     # isomophism found
                     k := Minimum( j, gn );
                     l := Maximum( j, gn );
                     newresult[ k ] := Concatenation( newresult[ gn ],
                                                      newresult[ j ] );
                     Unbind( newresult[ l ] );
                     hits[ k ] := 0;
                     hits[ l ] := 11;
                     remaining := remaining - 1;
                  fi;
               od;
            fi;
         fi;
      od;
   od;

   return list{ Filtered( [ 1 .. numcand ], x -> IsBound( newresult[x] ) ) };
end;

#############################################################################
##
#F ReducedByIsomorphismsSpecial( list )
##
ReducedByIsomorphismsSpecial := function( list )

   local i, j, finps, prop, cocs, result, ff, sortlist;

   # the trivial cases of isomorphism searching
   if Length( list ) = 0 then
      return list;
   fi;
   if Length( list ) = 1 then 
      list[1].isUnique := true;
      return list; 
   fi;
   
   Info( InfoFrattExt, 3, "  reduce ", Length(list), " groups " );

   # split up in sublist
   Info( InfoFrattExt, 4, "   Iso: split list by invariants ");
   sortlist := SplitUpSublistsByFpFunc( list );
   if Set( List( sortlist, Length ) ) = [ 1 ] then 
      # all groups are unique
      return Concatenation( sortlist );
   fi;

   # fetch properties of frattini-factorgroup
   ff := PcGroupCodeRec( list[ 1 ] );
   ff := ff / FrattiniSubgroup( ff );
   prop := FetchPropertiesFrattiniFreeGroup( ff );
   if prop = fail then
      Info( InfoFrattExt, 4, " Frattinifactor ",ff, " unknown, use default");
   else 
      Info( InfoFrattExt, 5, "  Frattinifactor: ", prop[ 1 ] );
   fi;
   
   result := [ ];
   # loop over all sublists
   for i in [ 1 .. Length( sortlist ) ] do
      if Length( sortlist[ i ] ) > 1 then

         Info( InfoFrattExt, 4, "   Iso: reduce list of length ",
                               Length( sortlist[i]));

         if prop <> fail then 
            sortlist[ i ] := RandomIsomorphismTestFF( sortlist[ i ], prop );
         else 
            sortlist[ i ] := RandomIsomorphismTest( sortlist[ i ], 10 );
         fi;
      fi;
      # set information to unique groups / groups which are not unique
      if Length( sortlist[ i ] ) = 1 then
         sortlist[ i ][ 1 ].isUnique := true;
         Add( result, sortlist[ i ][ 1 ] );
         Unbind( sortlist[ i ] );
      fi;
   od;

   sortlist := Compacted( sortlist );
   Sort( sortlist, function( x, y ) return Length(x)<Length(y); end );

   return Concatenation( result, sortlist );
end;

#############################################################################
##
#F DistinguishGroups( list )
##
DistinguishGroups := function( list )

local i, j, cocs, finps;

   i := 1;
   while i <= Length( list ) do
      if IsList( list[ i ] ) then
         cocs := List( list[ i ], x->CocGroup( PcGroupCodeRec( x ) ) );
         finps := DiffCocList( cocs, true );

         if finps[ Length( finps ) ] <> fail then
            # separation was succesful
            finps := finps[ Length( finps ) ];
            finps := List( cocs, x -> Collected( EvalFpCoc( x,finps ) ) );

            list[ i ] := List( Set( finps ), x -> list[ i ]{Filtered(
                    [ 1 .. Length( list[ i ] ) ], y -> finps[ y ] = x ) } );
            Info( InfoFrattExt, 3, "   IdentifyGroups splits list  of ", 
                  Length( finps ), " groups in ", Length( list[ i ] ),
                  " sublists" );
            for j in [ 1 .. Length( list[ i ] ) ] do
                if Length( list[ i ][ j ] ) = 1 then
                    list[ i ][ j ][ 1 ].isUnique := true;
                    list[ i ][ j ] := list[ i ][ j ][ 1 ];
                fi;
            od;
            Append( list, list[ i ]{[ 2 .. Length( list[ i ] ) ]} );
            list[ i ] := list[ i ][ 1 ];

            if IsList( list[ i ] ) then 
               # DiffCocList should be started again on block i
               i := i - 1;
            fi;

         else 
            Info( InfoFrattExt, 3, "   IdentifyGroups could not seperate" );
         fi;
      fi;
      i := i + 1;
   od;
   return list;
end;
