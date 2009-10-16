#############################################################################
##
#W  disting.gi                GAP library                  Hans Ulrich Besche
#W                                                               Bettina Eick
##
Revision.("grpconst/gap/disting_gi") :=
    "@(#)$Id: disting.gi,v 1.3 2005/02/22 11:17:23 gap Exp $";

#############################################################################
##
#F DiffCocList( <coclist>, <flagwordtest> ) . . . . . . . . . . . . . . local
##
InstallGlobalFunction( DiffCocList, function( coclist, flagwordtest )

   # coclist is a list of CocGroup's of some groups. DiffCocList tries to
   # find, if necessary recursive, some "tests" which will differentiate
   # the groups, or at least, to differentiate the clusters of the
   # CocGroup's. If flagwordtest is true, then beside the investigation
   # of the powermaps, additionally some words will be evaluated on the
   # classes.

   local i, j, k, ii, jj, kk, pos, word, lencoc,
         fpcand, fpqual, orders, finps, sfinps,
         qual, mqual, qualfp, hits, phits, cphits, poses, leading;

   Info( InfoRandIso, 2, "    DiffCocList starts" );

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
         Info( InfoRandIso, 2, "    DiffCocList split ", Length( coclist ),
                                " groups up" );
         return [ fpcand[ i ] ];
      fi;
      Add( fpqual, [ Length( sfinps ), Length( finps[ 1 ] ) ] );
   od;

   # find the test best spliting the list of groups
   pos := Position( fpqual, Maximum( fpqual ) );
   if fpqual[ pos ][ 1 ] > 1 then
      Info( InfoRandIso, 2, "    DiffCocList split ", Length( coclist ),
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
      Info( InfoRandIso, 2, "    DiffCocList failed without wordtest" );
      return [ fail ];
   fi;

   Info( InfoRandIso, 2, "    DiffCocList starts wordtest" );
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

            # check up desc's [ 4 or 5, x, j, k ], count hits
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
                  qualfp := [ word, i, j, k ];
                  if qual[ 1 ] = Length( coclist ) then 
                     Info( InfoRandIso, 2, "    DiffCocList split ",
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
      Info( InfoRandIso, 2, "    DiffCocList failed after wordtest" );
      return  [ fail ];
   fi;

   if mqual[ 1 ] > 1 then
      Info( InfoRandIso, 2, "    DiffCocList split ", Length( coclist ),
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

end);

#############################################################################
##
#F DistinguishGroups( list, flagwordtest )
##
InstallGlobalFunction( DistinguishGroups, function( list, flagwordtest )

   local i, j, cocs, finps;

   i := 1;
   while i <= Length( list ) do
      if IsList( list[ i ] ) then
         Info( InfoRandIso, 2, "    DistinguishGroups starts block ", i,
               "/", Length( list ) );
         cocs := List( list[ i ], x->CocGroup( PcGroupCodeRec( x ) ) );
         finps := DiffCocList( cocs, flagwordtest );

         if finps[ Length( finps ) ] <> fail then
            # separation was succesful
            finps := finps[ Length( finps ) ];
            finps := List( cocs, x -> Collected( EvalFpCoc( x,finps ) ) );

            list[ i ] := List( Set( finps ), x -> list[ i ]{Filtered(
                    [ 1 .. Length( list[ i ] ) ], y -> finps[ y ] = x ) } );
            Info( InfoRandIso, 1, "   IdentifyGroups splits list  of ",
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
            Info( InfoRandIso, 1, "   IdentifyGroups could not seperate" );
         fi;
      fi;
      i := i + 1;
   od;
   return list;
end);

