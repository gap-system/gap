#############################################################################
##
#W  ctblmaps.gi                 GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains those functions that are used to construct maps,
##  (mostly fusion maps and power maps).
##
Revision.ctblmaps_gi :=
    "@(#)$Id$";

#T UpdateMap: assertions for returned 'true' in the library occurrencies


#############################################################################
##
#F  CharacterString( <char>, <str> )  . . . . .  character information string
##
CharacterString := function( char, str )
    str:= Concatenation( str, " of degree ", String( char[1] ) );
    ConvertToStringRep( str );
    return str;
end;


#############################################################################
##
#F  Indeterminateness( <paramap> ) . . . . the indeterminateness of a paramap
##
Indeterminateness := function( paramap )
    local prod, i;
    prod:= 1;
    for i in paramap do
      if IsList( i ) then
        prod:= prod * Length( i );
      fi;
    od;
    return prod;
end;


#############################################################################
##
#F  PrintAmbiguity( <list>, <paramap> ) . . . .  ambiguity of characters with
#F                                                       respect to a paramap
##
PrintAmbiguity := function( list, paramap )
    local i, composition;
    for i in list do
      composition:= CompositionMaps( i, paramap );
      Print( i, " ", Indeterminateness( composition ), " ",
             Filtered( [ 1 .. Length( composition ) ],
                       x -> IsList( composition[x] ) ),
             "\n" );
    od;
end;


#############################################################################
##
#F  Parametrized( <list> )
##
Parametrized := function( list )
    local i, j, parametrized;
    if list = [] then return []; fi;
    parametrized:= [];
    for i in [ 1 .. Length( list[1] ) ] do
      if ( IsList( list[1][i] ) and not IsString( list[1][i] ) ) 
         or list[1][i] = [] then
        parametrized[i]:= list[1][i];
      else
        parametrized[i]:= [ list[1][i] ];
      fi;
    od;
    for i in [ 2 .. Length( list ) ] do
      for j in [ 1 .. Length( list[i] ) ] do
        if ( IsList( list[i][j] ) and not IsString( list[i][j] ) ) 
           or list[i][j] = [] then
          UniteSet( parametrized[j], list[i][j] );
        else
          AddSet( parametrized[j], list[i][j] );
        fi;
      od;
    od;
    for i in [ 1 .. Length( list[1] ) ] do
      if Length( parametrized[i] ) = 1 then
        parametrized[i]:= parametrized[i][1];
      fi;
    od;
    return parametrized;
end;


#############################################################################
##
#F  ContainedMaps( <paramap> )
##
ContainedMaps := function( paramap )
    local i, j, containedmaps, copy;
    i:= 1;
    while i <= Length( paramap ) and
          ( not IsList( paramap[i] ) or IsString( paramap[i] ) ) do
      i:= i+1;
    od;
    if i > Length( paramap ) then
      return [ DeepCopy( paramap ) ];
    else
      containedmaps:= [];
      copy:= ShallowCopy( paramap );
      for j in paramap[i] do
        copy[i]:= j;
        Append( containedmaps, ContainedMaps( copy ) );
      od;
      return containedmaps;
    fi;
end;


#############################################################################
##
#F  Indirected( <character>, <paramap> )
##
Indirected := function( character, paramap )
    local i, imagelist, indirected;
    indirected:= [];
    for i in [ 1 .. Length( paramap ) ] do
      if IsInt( paramap[i] ) then
        indirected[i]:= character[ paramap[i] ];
      else
        imagelist:= Set( character{ paramap[i] } );
        if Length( imagelist ) = 1 then
          indirected[i]:= imagelist[1];
        else
          indirected[i]:= Unknown();
        fi;
      fi;
    od;
    return indirected;
end;


#############################################################################
##
#F  ElementOrdersPowerMap( <powermap> )
##
ElementOrdersPowerMap := function( powermap )
    local i, primes, elementorders, nccl, bound, newbound, map, pos;

    if powermap = [] then
      Error( "sorry, no power maps bound" );
    fi;

    primes:= Filtered( [ 1 .. Length( powermap ) ],
                       x -> IsBound( powermap[x] ) );
    nccl:= Length( powermap[ primes[1] ] );

    if 2 <= InfoLevel( InfoCharacterTable ) then
      for i in primes do
        if ForAny( powermap[i], IsList ) then
          Print( "#I ElementOrdersPowermap: ", Ordinal( i ),
                 " power map not unique at classes\n",
                 "#I ", Filtered( [ 1 .. nccl ],
                                  x -> IsList( powermap[i][x] ) ),
                 " (ignoring these entries)\n" );
        fi;
      od;
    fi;
     
    elementorders:= [ 1 ];
    bound:= [ 1 ];

    while bound <> [] do
      newbound:= [];
      for i in primes do
        map:= powermap[i];
        for pos in [ 1 .. nccl ] do
          if IsInt( map[ pos ] ) and map[ pos ] in bound
             and IsBound( elementorders[ map[ pos ] ] )
             and not IsBound( elementorders[ pos ] ) then
            elementorders[ pos ]:= i * elementorders[ map[ pos ] ];
            AddSet( newbound, pos );
          fi;
        od;
      od;
      bound:= newbound;
    od;
    for i in [ 1 .. nccl ] do
      if not IsBound( elementorders[i] ) then
        elementorders[i]:= Unknown();
      fi;
    od;
    if     2 <= InfoLevel( InfoCharacterTable )
       and ForAny( elementorders, IsUnknown ) then
      Print( "#I ElementOrdersPowermap: element orders not determined for",
             " classes in\n",
             "#I ", Filtered( [ 1 .. nccl ],
                              x-> IsUnknown( elementorders[x] ) ), "\n" );
    fi;
    return elementorders;
end;


#############################################################################
##
#F  CollapsedMat( <mat>, <maps> )
##
CollapsedMat := function( mat, maps )

    local i, j, k, nontrivblock, nontrivblocks, row, newblocks, values,
            blocks, pos, minima, fusion;

    # Compute successivly the partition of column families defined by
    # the rows already processed.
    nontrivblocks:= [ [ 1 .. Length( mat[1] ) ] ];
    for row in Concatenation( maps, mat ) do
      newblocks:= [];
      for nontrivblock in nontrivblocks do
        values:= [];
        blocks:= [];
        for k in nontrivblock do
          pos:= 1;
          while pos <= Length( values ) and values[ pos ] <> row[k] do
            pos:= pos + 1;
          od;
          if Length( values ) < pos then
            values[ pos ]:= row[k];
            blocks[ pos ]:= [ k ];
          else
            AddSet( blocks[ pos ], k );
          fi;
        od;
        for k in blocks do
          if 1 < Length( k ) then Add( newblocks, k ); fi;
        od;
      od;
      nontrivblocks:= newblocks;
    od;

    minima:= List( nontrivblocks, Minimum );
    nontrivblocks:= Permuted( nontrivblocks, Sortex( minima ) );
    minima:= Concatenation( [ 0 ], minima );
    fusion:= [];
    pos:= 1;
    for i in [ 1 .. Length( minima ) - 1 ] do
      for j in [ minima[i] + 1 .. minima[i+1] - 1 ] do
        if not IsBound( fusion[j] ) then
          fusion[j]:= pos;
          pos:= pos + 1;
        fi;
      od;
      for j in nontrivblocks[i] do fusion[j]:= pos; od;
      pos:= pos + 1;
    od;
    for i in [ minima[ Length( minima ) ] + 1 .. Length( mat[1] ) ] do
      if not IsBound( fusion[i] ) then
        fusion[i]:= pos;
        pos:= pos + 1;
      fi;
    od;

    values:= ProjectionMap( fusion );
    return rec( mat:= List( mat, x -> x{ values } ),
#T do I really need the component 'mat'?
                fusion:= fusion );
end;


#############################################################################
##
#F  UpdateMap( <char>, <paramap>, <indirected> )
##
UpdateMap := function( char, paramap, indirected )

    local i, j, value, fus;

    for i in [ 1 .. Length( paramap ) ] do
      if IsInt( paramap[i] ) then
        if indirected[i] <> char[ paramap[i] ] then
          Print( "#E UpdateMap: inconsistency at class ", i, "\n" );
          return false;
        fi;
      else
        value:= indirected[i];
        if not IsList( value ) then value:= [ value ]; fi;
        fus:= [];
        for j in paramap[i] do
          if char[j] in value then Add( fus, j ); fi;
        od;
        if fus = [] then
          Print( "#E UpdateMap: inconsistency at class ", i, "\n" );
          return false;
        else
          if Length( fus ) = 1 then fus:= fus[1]; fi;
          paramap[i]:= fus;
        fi;
      fi;
    od;
    return true;
end;


#############################################################################
##
#F  NonnegIntScalarProducts( <tbl>, <chars>, <candidate> )
##
NonnegIntScalarProducts := function( tbl, chars, candidate )

    local i, sc, classes, order, char, weighted;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    weighted:= [];
    for char in chars do
      for i in [ 1 .. Length( char ) ] do
        weighted[i]:= classes[i] * char[i];
      od;
      sc:= weighted * candidate / order;
      if not IsInt( sc ) or IsNegRat( sc ) then return false; fi;
    od;
    return true;
end;


#############################################################################
##
#F  IntScalarProducts( <tbl>, <chars>, <candidate> )
##
IntScalarProducts := function( tbl, chars, candidate )

    local i, classes, order, char, weighted;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    weighted:= [];
    for char in chars do
      for i in [ 1 .. Length( char ) ] do
        weighted[i]:= classes[i] * char[i];
      od;
      if not IsInt( weighted * candidate / order ) then return false; fi;
    od;
    return true;
end;


#############################################################################
##
#F  ContainedSpecialVectors( <tbl>, <chars>, <paracharacter>, <func> )
##
ContainedSpecialVectors := function( tbl, chars, paracharacter, func )

    local i, j, x, classes, unknown, images, number, index, direction,
          pos, oldvalue, newvalue, norm, sum, possibilities, order;

    classes:= SizesConjugacyClasses( tbl );
    order:= Size( tbl );
    paracharacter:= ShallowCopy( paracharacter );
    unknown:= [];
    images:= [];
    number:= [];
    index:= [];
    direction:= [];
    pos:= 1;
    for i in [ 1 .. Length( paracharacter ) ] do
      if IsList( paracharacter[i] ) then
        unknown[pos]:= i;
        images[pos]:= paracharacter[i];
        number[pos]:= Length( paracharacter[i]);
        index[pos]:= 1;
        direction[pos]:= 1;               # 1 means up, -1 means down
        paracharacter[i]:= paracharacter[i][1];
        pos:= pos + 1;
      fi;
    od;
    sum:= classes * paracharacter;
    norm:= classes * List( paracharacter, x -> x * GaloisCyc( x, -1 ) );
    possibilities:= [];
    if IsInt( sum / order ) and IsInt( norm / order) 
       and func( tbl, chars, paracharacter ) then
      possibilities[1]:= ShallowCopy( paracharacter );
    fi;
    i:= 1;
    while true do
      i:= 1;
      while i <= Length( unknown ) and 
         ( ( index[i] = number[i] and direction[i] = 1 ) or
              ( index[i] = 1 and direction[i] = -1 ) ) do
        direction[i]:= - direction[i];
        i:= i+1;
      od;
      if Length( unknown ) < i then             # we are through
        return possibilities;
      else                                      # update at position i
        oldvalue:= images[i][ index[i] ];
        index[i]:= index[i] + direction[i];
        newvalue:= images[i][ index[i] ];
        sum:= sum + classes[ unknown[i] ] * ( newvalue - oldvalue );
        norm:= norm + classes[ unknown[i] ]
                * (   newvalue * GaloisCyc( newvalue, -1 )
                    - oldvalue * GaloisCyc( oldvalue, -1 ) );
        if IsInt( sum / order ) and IsInt( norm / order ) then
          for j in [ 1 .. Length( unknown ) ] do
            paracharacter[ unknown[j] ]:= images[j][ index[j] ];
          od;
          if func( tbl, chars, paracharacter ) then
            Add( possibilities, ShallowCopy( paracharacter ) );
          fi;
        fi;
      fi;
    od;
end;


#############################################################################
##
#F  ContainedPossibleCharacters( <tbl>, <chars>, <paracharacter> )
##
ContainedPossibleCharacters := function(tbl, chars, paracharacter)
    return ContainedSpecialVectors( tbl, chars, paracharacter,
                                    NonnegIntScalarProducts );
end;


#############################################################################
##
#F  ContainedPossibleVirtualCharacters( <tbl>, <chars>, <paracharacter> )
##
ContainedPossibleVirtualCharacters :=function( tbl, chars, paracharacter )
    return ContainedSpecialVectors( tbl, chars, paracharacter,
                                    IntScalarProducts );
end;


#############################################################################
##
#F  InitFusion( <subtbl>, <tbl> )
##
InitFusion := function( subtbl, tbl )

    local subcentralizers,
          subclasses,
          subsize,
          centralizers,
          classes,
          initfusion,
          upper,
          i, j,
          orders,
          suborders,
          sameord,
          elm,
          errors,
          choice;

    # Check the arguments.
    if not ( IsOrdinaryTable( subtbl ) and IsOrdinaryTable( tbl ) ) then
      Error( "<subtbl>, <tbl> must be ordinary character tables" );
    fi;

    subcentralizers:= SizesCentralizers( subtbl );
    subclasses:= SizesConjugacyClasses( subtbl );
    subsize:= Size( subtbl );
    centralizers:= SizesCentralizers( tbl );
    classes:= SizesConjugacyClasses( tbl );

    initfusion:= [];
    upper:= [ 1 ]; # upper[i]: upper bound for the number of elements
                   # fusing in class i

    for i in [ 2 .. Length( centralizers ) ] do
      upper[i]:= Minimum( subsize, classes[i] );
    od;

    # if orders are known
    if     HasOrdersClassRepresentatives( subtbl )
       and HasOrdersClassRepresentatives( tbl ) then
      orders   := OrdersClassRepresentatives( tbl );
      suborders:= OrdersClassRepresentatives( subtbl );
      sameord:= [];
      for i in [ 1 .. Length( orders ) ] do
        if IsInt( orders[i] ) then
          if IsBound( sameord[ orders[i] ] ) then
            AddSet( sameord[ orders[i] ], i );
          else
            sameord[ orders[i] ]:= [ i ];
          fi;
        else                 # para-orders
          for j in orders[i] do
            if IsBound( sameord[j] ) then
              AddSet( sameord[j], i );
            else
              sameord[j]:= [ i ];
            fi;
          od;
        fi;
      od;

      for i in [ 1 .. Length( suborders) ] do
        initfusion[i]:= [];
        if IsInt( suborders[i] ) then
          if not IsBound( sameord[ suborders[i] ] ) then
            Info( InfoCharacterTable, 2,
                  "InitFusion: no fusion possible because of ",
                  "representative orders" );
            return fail;
          fi;
          for j in sameord[ suborders[i] ] do
            if centralizers[j] mod subcentralizers[i] = 0 and
                                    upper[j] >= subclasses[i] then
              AddSet( initfusion[i], j );
            fi;
          od;
        else                 # para-orders
          choice:= Filtered( suborders[i], x -> IsBound( sameord[x] ) );
          if choice = [] then
            Info( InfoCharacterTable, 2,
                  "InitFusion: no fusion possible because of ",
                  "representative orders" );
            return fail;
          fi;
          for elm in choice do
            for j in sameord[ elm ] do
              if centralizers[j] mod subcentralizers[i] = 0 then
                AddSet( initfusion[i], j );
              fi;
            od;
          od;
        fi;
        if IsEmpty( initfusion[i] ) then
          Info( InfoCharacterTable, 2,
                "InitFusion: no images possible for class ", i );
          return fail;
        fi;
      od;

    # just centralizers are known:
    else

      for i in [ 1 .. Length( subcentralizers ) ] do
        initfusion[i]:= [];
        for j in [ 1 .. Length( centralizers ) ] do
          if centralizers[j] mod subcentralizers[i] = 0 and
                                    upper[j] >= subclasses[i] then
            AddSet( initfusion[i], j );
          fi;
        od;
        if IsEmpty( initfusion[i] ) then
          Info( InfoCharacterTable, 2,
                  "InitFusion: no images possible for class ", i );
          return fail;
        fi;
      od;

    fi;

    # step 2: replace sets with exactly one element by that element
    for i in [ 1 .. Length( initfusion ) ] do
      if Length( initfusion[i] ) = 1 then
        initfusion[i]:= initfusion[i][1];
      fi;
    od;

    return initfusion;
end;


#############################################################################
##
#F  CheckPermChar( <subtbl>, <tbl>, <fusionmap>, <permchar> )
##
##  tries to improve the parametrized fusion <fusionmap> from the character
##  table <subtbl> into the character table <tbl> using the permutation
##  character <permchar> that belongs to the required fusion\:
##
##  An upper bound for the number of elements fusing into each class is
##  $'upper[i]'= 'Size( <subtbl> ) \*
##               '<permchar>[i]' / 'SizesCentralizers( <tbl> )[i]'$.
##
##  We first subtract from that the number of all elements which {\em must}
##  fuse into that class:
##  $'upper[i]':= 'upper[i]' -
##                      \sum_{'fusionmap[i]'='i'} '<subtbl>.classes[i]'$.
##
##  After that, we delete all those possible images 'j' in 'initfusion[i]'
##  which do not satisfy $'<subtbl>.classes[i]' \leq 'upper[j]'$
##  (local function 'deletetoolarge').
##
##  At last, if there is a class 'j' with
##  $'upper[j]' = \sum_{'j' \in 'initfusion[i]'}' <subtbl>.classes[i]'$,
##  then 'j' must be the image for all 'i' with 'j' in 'initfusion[i]'
##  (local function 'takealliffits').
##
##  'CheckPermChar' returns 'true' if no inconsistency occured, and 'false'
##  otherwise.
##
##  ('CheckPermChar' is used as subroutine of 'SubgroupFusions'.)
##
CheckPermChar := function( subtbl, tbl, fusionmap, permchar )

    local centralizers,
          subsize,
          classes,
          subclasses,
          i,
          upper,
          deletetoolarge,
          takealliffits,
          totest,
          improved;

    centralizers:= SizesCentralizers( tbl );
    subsize:= Size( subtbl );
    classes:= SizesConjugacyClasses( tbl );
    subclasses:= SizesConjugacyClasses( subtbl );

    upper:= [];

    if permchar = [] then

      # just check upper bounds
      for i in [ 1 .. Length( centralizers ) ] do
        upper[i]:= Minimum( subsize, classes[i] );
      od;
    else

      # number of elements that fuse in each class
      for i in [ 1 .. Length( centralizers ) ] do
        upper[i]:= permchar[i] * subsize / centralizers[i];
      od;
    fi;

    # subtract elements where the image is unique
    for i in [ 1 .. Length( fusionmap ) ] do
      if IsInt( fusionmap[i] ) then
        upper[ fusionmap[i] ]:= upper[ fusionmap[i] ] - subclasses[i];
      fi;
    od;
    if Minimum( upper ) < 0 then
      Info( InfoCharacterTable, 2,
            "CheckPermChar: too many preimages for classes in ",
            Filtered( [ 1 .. Length( upper ) ],
                      x-> upper[x] < 0 ) );
      return false;
    fi;

    # Only those classes are allowed images which are not too big
    # also after diminishing upper:
    # 'deletetoolarge( <totest> )' excludes all those possible images 'x' in
    # sets 'fusionmap[i]' which are contained in the list <totest> and
    # which are larger than 'upper[x]'.
    # (returns 'i' in case of an inconsistency at class 'i', otherwise the
    # list of classes 'x' where 'upper[x]' was diminished)
    #
    deletetoolarge:= function( totest )
      local i, improved, delete;

      if totest = [] then return []; fi; 
      improved:= [];
      for i in [ 1 .. Length( fusionmap ) ] do
        if IsList( fusionmap[i] )
           and Intersection( fusionmap[i], totest ) <> [] then
          fusionmap[i]:= Filtered( fusionmap[i],
                                   x -> ( subclasses[i] <= upper[x] ) );
          if fusionmap[i] = [] then
            return i;
          elif Length( fusionmap[i] ) = 1 then
            fusionmap[i]:= fusionmap[i][1];
            AddSet( improved, fusionmap[i] );
            upper[ fusionmap[i] ]:= upper[fusionmap[i]] - subclasses[i];
          fi;
        fi;
      od;
      delete:= deletetoolarge( improved );
      if IsInt( delete ) then
        return delete;
      else
        return Union( improved, delete );
      fi;
    end;

    # Check if there are classes into which more elements must fuse
    # than known up to now; if all possible preimages are
    # necessary to satisfy the permutation character, improve 'fusionmap'.
    # 'takealliffits( <totest> )' sets 'fusionmap[i]' to 'x' if 'x' is in
    # the list 'totest' and if all possible preimages of 'x' are necessary
    # to give 'upper[x]'.
    # (returns 'i' in case of an inconsistency at class 'i', otherwise the
    # list of classes 'x' where 'upper[x]' was diminished)
    #
    takealliffits:= function( totest )
      local i, j, preimages, sum, improved, take;
      if totest = [] then return []; fi;
      improved:= [];
      for i in Filtered( totest, x -> upper[x] > 0 ) do
        preimages:= [];
        for j in [ 1 .. Length( fusionmap ) ] do
          if IsList( fusionmap[j] ) and i in fusionmap[j] then
            Add( preimages, j );
          fi;
        od;
        sum:= Sum( List( preimages, x -> subclasses[x] ) );
        if sum = upper[i] then

          # take them all
          for j in preimages do fusionmap[j]:= i; od;
          upper[i]:= 0;
          Add( improved, i );
        elif sum < upper[i] then
          return i;
        fi;
      od;
      take:= takealliffits( improved );
      if IsInt( take ) then
        return take;
      else
        return Union( improved, take );
      fi;
    end;

    # Improve until no new improvement can be found!
    totest:= [ 1 .. Length( permchar ) ];
    while totest <> [] do
      improved:= deletetoolarge( totest );
      if IsInt( improved ) then
        Info( InfoCharacterTable, 2,
              "CheckPermChar: no image possible for class ", improved );
        return false;
      fi;
      totest:= takealliffits( Union( improved, totest ) );
      if IsInt( totest ) then
        Info( InfoCharacterTable, 2,
              "CheckPermChar: not enough preimages for class ", totest );
        return false;
      fi;
    od;
    return true;
end;


#############################################################################
##
#F  MeetMaps( <map1>, <map2> )
##
MeetMaps := function( map1, map2 )

    local i;      # loop over the classes

    for i in [ 1 .. Maximum( Length( map1 ), Length( map2 ) ) ] do
      if IsBound( map1[i] ) then
        if IsBound( map2[i] ) then

          # This is the only case where we have to work.
          if IsInt( map1[i] ) then
            if IsInt( map2[i] ) then
              if map1[i] <> map2[i] then
                return i;
              fi;
            elif not map1[i] in map2[i] then
              return i;
            fi;
          elif IsInt( map2[i] ) then
            if map2[i] in map1[i] then
              map1[i]:= map2[i];
            else
              return i;
            fi;
          else
            map1[i]:= Intersection( map1[i], map2[i] );
            if map1[i] = [] then
              return i;
            elif Length( map1[i] ) = 1 then
              map1[i]:= map1[i][1];
            fi;
          fi;

        fi;
      elif IsBound( map2[i] ) then
        map1[i]:= map2[i];
      fi;
    od;
    return true;
end;


#############################################################################
##
#F  ImproveMaps( <map2>, <map1>, <composition>, <class> )
##
ImproveMaps := function( map2, map1, composition, class )

    local j, map1_i, newvalue;

    map1_i:= map1[ class ];
    if IsInt( map1_i ) then

      # case 1: map2[ map1_i ] must be a set,
      #         try to improve map2 at that position
      if composition <> map2[ map1_i ] then
        if Length( composition ) = 1 then
          map2[ map1_i ]:= composition[1];
        else
          map2[ map1_i ]:= composition;
        fi;

        # map2[ map1_i ] was improved
        return map1_i;
      fi;
    else

      # case 2: try to improve map1[ class ]
      newvalue:= [];
      for j in map1_i do
        if ( IsInt( map2[j] ) and map2[j] in composition ) or
           (     IsList( map2[j] )
             and Intersection2( map2[j], composition ) <> [] ) then
          AddSet( newvalue, j );
        fi;
      od;
      if newvalue <> map1_i then
        if Length( newvalue ) = 1 then
          map1[ class ]:= newvalue[1];
        else
          map1[ class ]:= newvalue;
        fi;
        return -1;                  # map1 was improved
      fi;
    fi;
    return 0;                       # no improvement
end;


#############################################################################
##
#F  CompositionMaps( <paramap2>, <paramap1> )
#F  CompositionMaps( <paramap2>, <paramap1>, <class> )
##
CompositionMaps := function( arg )

    local i, j, map1, map2, class, result, newelement;

    if Length(arg) = 2 and IsList(arg[1]) and IsList(arg[2]) then

      map2:= arg[1];
      map1:= arg[2];
      result:= [];
      for i in [ 1 .. Length( map1 ) ] do
        if IsBound( map1[i] ) then
          result[i]:= CompositionMaps( map2, map1, i );
        fi;
      od;
      return result;

    elif Length( arg ) = 3
         and IsList( arg[1] ) and IsList( arg[2] ) and IsInt( arg[3] ) then

      map2:= arg[1];
      map1:= arg[2];
      class:= arg[3];
      if IsInt( map1[ class ] ) then
        return map2[ map1[ class ] ];
      else
        result:= [];
        for j in map1[ class ] do

          newelement:= map2[j];
          if IsList( newelement ) and not IsString( newelement ) then
            UniteSet( result, newelement );
          else
            AddSet( result, newelement );
          fi;

        od;
        if Length( result ) = 1 then result:= result[1]; fi;
        return result;
      fi;
    else
      Error(" usage: CompositionMaps( <map2>, <map1>, <class> ) resp.\n",
            "        CompositionMaps( <map2>, <map1> )" );
    fi;
end;


#############################################################################
##
#F  ProjectionMap( <fusionmap> ) . . projection corresponding to a fusion map
##
ProjectionMap := function( fusionmap )

    local i, projection;

    projection:= [];
    for i in Reversed( [ 1 .. Length( fusionmap ) ] ) do
      projection[ fusionmap[i] ]:= i;
    od;
    return projection;
end;


#############################################################################
##
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4> )
#F  CommutativeDiagram( <paramap1>, <paramap2>, <paramap3>, <paramap4>,
#F                      <improvements> )
##
CommutativeDiagram := function( arg )

    local i, paramap1, paramap2, paramap3, paramap4, imp1, imp2, imp4,
          globalimp1, globalimp2, globalimp3, globalimp4, newimp1, newimp2,
          newimp4, map2_map1, map4_map3, composition, imp;

    if not ( Length(arg) in [ 4, 5 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) and IsList( arg[4] ) )
       or ( Length( arg ) = 5 and not IsRecord( arg[5] ) ) then
      Error("usage: CommutativeDiagram(<pmap1>,<pmap2>,<pmap3>,<pmap4>)\n",
          "resp. CommutativeDiagram(<pmap1>,<pmap2>,<pmap3>,<pmap4>,<imp>)");
    fi;

    paramap1:= arg[1];
    paramap2:= arg[2];
    paramap3:= arg[3];
    paramap4:= arg[4];
    if Length( arg ) = 5 then
      imp1:= Union( arg[5].imp1, arg[5].imp3 );
      imp2:= arg[5].imp2;
      imp4:= arg[5].imp4;
    else
      imp1:= List( [ 1 .. Length( paramap1 ) ] );
      imp2:= [];
      imp4:= [];
    fi;
    globalimp1:= [];
    globalimp2:= [];
    globalimp3:= [];
    globalimp4:= [];
    while imp1 <> [] or imp2 <> [] or imp4 <> [] do
      newimp1:= [];
      newimp2:= [];
      newimp4:= [];
      for i in [ 1 .. Length( paramap1 ) ] do
        if i in imp1
           or ( IsList(paramap1[i]) and Intersection2(paramap1[i],imp2)<>[] )
           or ( IsList(paramap3[i]) and Intersection2(paramap3[i],imp4)<>[] )
           or ( IsInt( paramap1[i] ) and paramap1[i] in imp2 )
           or ( IsInt( paramap3[i] ) and paramap3[i] in imp4 ) then
          map2_map1:= CompositionMaps( paramap2, paramap1, i );
          map4_map3:= CompositionMaps( paramap4, paramap3, i );

          if IsInt( map2_map1 ) then map2_map1:= [ map2_map1 ]; fi;
          if IsInt( map4_map3 ) then map4_map3:= [ map4_map3 ]; fi;

          composition:= Intersection2( map2_map1, map4_map3 );
          if composition = [] then
            Info( InfoCharacterTable, 2,
                  "CommutativeDiagram: inconsistency at class", i );
            return fail;
          fi;
          if composition <> map2_map1 then
            imp:= ImproveMaps( paramap2, paramap1, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp1, i );
            elif imp <> 0 then
              AddSet( newimp2, imp );
              AddSet( globalimp2, imp );
            fi;
          fi;
          if composition <> map4_map3 then
            imp:= ImproveMaps( paramap4, paramap3, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp3, i );
            elif imp <> 0 then
              AddSet( newimp4, imp );
              AddSet( globalimp4, imp );
            fi;
          fi;
        fi;
      od;
      imp1:= newimp1;
      imp2:= newimp2;
      imp4:= newimp4;
    od;
    return rec(
                imp1:= globalimp1,
                imp2:= globalimp2,
                imp3:= globalimp3,
                imp4:= globalimp4
                                  );
end;


#############################################################################
##
#F  CheckFixedPoints( <inside1>, <between>, <inside2> )
##
CheckFixedPoints := function( inside1, between, inside2 )

    local i, j, improvements, errors, image;

    improvements:= [];
    errors:= [];
    for i in [ 1 .. Length( inside1 ) ] do
      if inside1[i] = i then             # for all fixed points of 'inside1'
        if IsInt( between[i] ) then
          if inside2[ between[i] ] <> between[i] then
            if IsInt( inside2[ between[i] ] )
               or not between[i] in inside2[ between[i] ] then
              Add( errors, i );
            else
              inside2[ between[i] ]:= between[i];
              Add( improvements, i );
            fi;
          fi;
        else
          image:= [];
          for j in between[i] do
            if inside2[j] = j
               or ( IsList( inside2[j] ) and j in inside2[j] ) then
              Add( image, j );
            fi;
          od;
          if image = [] then
            AddSet( errors, i );
          elif image <> between[i] then
            between[i]:= image;
            AddSet( improvements, i );
          fi;
        fi;
      fi;
    od;

    if errors = [] then
      if improvements <> [] then
        Info( InfoCharacterTable, 2,
              "CheckFixedPoints: improvements at classes ", improvements );
      fi;
      return improvements;
    else
      Info( InfoCharacterTable, 2,
            "CheckFixedPoints: no image possible for classes ", errors );
      return fail;
    fi;
end;
   

#############################################################################
##
#F  TransferDiagram( <inside1>, <between>, <inside2> )
#F  TransferDiagram( <inside1>, <between>, <inside2>, <improvements> )
##
TransferDiagram := function( arg )

    local i, inside1, between, inside2, imp1, impb, imp2, globalimp1,
          globalimpb, globalimp2, newimp1, newimpb, newimp2, bet_ins1,
          ins2_bet, composition, imp, check;

    if not ( Length(arg) in [ 3, 4 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) )
       or ( Length( arg ) = 4 and not IsRecord( arg[4] ) ) then
      Error("usage: TransferDiagram(<inside1>,<between>,<inside2>) resp.\n",
            "       TransferDiagram(<inside1>,<between>,<inside2>,<imp> )" );
    fi;
    inside1:= arg[1];
    between:= arg[2];
    inside2:= arg[3];
    if Length( arg ) = 4 then
      imp1:= arg[4].impinside1;
      impb:= arg[4].impbetween;
      imp2:= arg[4].impinside2;
    else
      imp1:= List( [ 1 .. Length( inside1 ) ] );
      impb:= [];
      imp2:= [];
    fi;
    globalimp1:= [];
    globalimpb:= [];
    globalimp2:= [];
    while imp1 <> [] or impb <> [] or imp2 <> [] do
      newimp1:= [];
      newimpb:= [];
      newimp2:= [];
      for i in [ 1 .. Length( inside1 ) ] do
        if i in imp1 or i in impb
           or ( IsList( inside1[i] ) and Intersection(inside1[i],impb)<>[] )
           or ( IsList( between[i] ) and Intersection(between[i],imp2)<>[] )
           or ( IsInt( inside1[i] ) and inside1[i] in impb )
           or ( IsInt( between[i] ) and between[i] in imp2 ) then
          bet_ins1:= CompositionMaps( between, inside1, i );
          ins2_bet:= CompositionMaps( inside2, between, i );
          if IsInt( bet_ins1 ) then bet_ins1:= [ bet_ins1 ]; fi;
          if IsInt( ins2_bet ) then ins2_bet:= [ ins2_bet ]; fi;
          composition:= Intersection( bet_ins1, ins2_bet );
          if composition = [] then
            Info( InfoCharacterTable, 2,
                  "TransferDiagram: inconsistency at class ", i );
            return fail;
          fi;
          if composition <> bet_ins1 then
            imp:= ImproveMaps( between, inside1, composition, i );
            if imp = -1 then
              AddSet( newimp1, i );
              AddSet( globalimp1, i );
            elif imp <> 0 then
              AddSet( newimpb, imp );
              AddSet( globalimpb, imp );
            fi;
          fi;
          if composition <> ins2_bet then
            imp:= ImproveMaps( inside2, between, composition, i );
            if imp = -1 then
              AddSet( newimpb, i );
              AddSet( globalimpb, i );
            elif imp <> 0 then
              AddSet( newimp2, imp );
              AddSet( globalimp2, imp );
            fi;
          fi;
        fi;
      od;
      imp1:= newimp1;
      impb:= newimpb;
      imp2:= newimp2;
    od;
    check:= CheckFixedPoints( inside1, between, inside2 );
    if check = fail then
      return fail;
    elif check <> [] then
      check:= TransferDiagram( inside1, between, inside2,
                               rec( impinside1:= [], impbetween:= check,
                                    impinside2:= [] ) );
      return rec( impinside1:= Union( check.impinside1, globalimp1 ),
                  impbetween:= Union( check.impbetween, globalimpb ),
                  impinside2:= Union( check.impinside2, globalimp2 ) );
    else
      return rec( impinside1:= globalimp1, impbetween:= globalimpb,
                  impinside2:= globalimp2 );
    fi;
end;


#############################################################################
##
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2> )
#F  TestConsistencyMaps( <powermap1>, <fusionmap>, <powermap2>, <fus_imp> )
##
TestConsistencyMaps := function( arg )

    local i, j, x, powermap1, powermap2, pos, fusionmap, imp,
          fus_improvements, tr;

    if not ( Length(arg) in [ 3, 4 ] and IsList(arg[1]) and IsList(arg[2])
             and IsList( arg[3] ) )
       or ( Length( arg ) = 4 and not IsList( arg[4] ) ) then
      Error("usage: TestConsistencyMaps(<powmap1>,<fusmap>,<powmap2>)",
            " resp.\n    ",
            "TestConsistencyMaps(<powmap1>,<fusmap>,<powmap2>,<fus_imp>)");
    fi;
    powermap1:= [];
    powermap2:= [];
    pos:= [];
    for i in [ 1 .. Length( arg[1] ) ] do
      if IsBound( arg[1][i] ) and IsBound( arg[3][i] ) then
        Add( powermap1, arg[1][i] );
        Add( powermap2, arg[3][i] );
        Add( pos, i );
      fi;
    od;
    fusionmap:= arg[2];
    if Length( arg ) = 4 then
      imp:= arg[4];
    else
      imp:= [ 1 .. Length( fusionmap ) ];
    fi;
    fus_improvements:= List( [ 1 .. Length( powermap1 ) ], x -> imp );
    if fus_improvements = [] then return true; fi;     # no common powermaps
    i:= 1;
    while fus_improvements[i] <> [] do
      tr:= TransferDiagram( powermap1[i], fusionmap, powermap2[i],
                     rec( impinside1:= [],
                          impbetween:= fus_improvements[i],
                          impinside2:= [] ) );
      # (We are only interested in improvements of the fusionmap which may
      #  have occurred.)

      if tr = fail then
        Info( InfoCharacterTable, 2,
              "TestConsistencyMaps: inconsistency in powermap ", pos[i] );
        return false;
      fi;
      for j in [ 1 .. Length( fus_improvements ) ] do
        fus_improvements[j]:= Union( fus_improvements[j], tr.impbetween );
      od;
      fus_improvements[i]:= [];
      i:= ( i mod Length( fus_improvements ) ) + 1;
    od;
    return true;
end;


#############################################################################
##
#F  InitPowermap( <tbl>, <prime> )
##
InitPowermap := function( tbl, prime )

    local i, j, k,        # loop variables
          powermap,       # power map for prime 'prime', result
          centralizers,   # centralizer orders of 'tbl'
          nccl,           # number of conjugacy classes of 'tbl'
          orders,         # representative orders of 'tbl' (if bound)
          sameord;        # contains at position <i> the list of those
                          # classes that (may) have representative order <i>

    powermap:= [];
    centralizers:= SizesCentralizers( tbl );
    nccl:= Length( centralizers );

    if     HasOrdersClassRepresentatives( tbl )
       and IsList( OrdersClassRepresentatives( tbl ) ) then
#T ??

      # Both orders and centralizers are known,
      # construct the list 'sameord'.

      orders:= OrdersClassRepresentatives( tbl );
      sameord:= [];

      for i in [ 1 .. Length( orders ) ] do

        if IsInt( orders[i] ) then

          if IsBound( sameord[ orders[i] ] ) then
            AddSet( sameord[ orders[i] ], i );
          else
            sameord[ orders[i] ]:= [ i ];
          fi;

        else

          # parametrized orders

          for j in orders[i] do
            if IsBound( sameord[j] ) then
              AddSet( sameord[j], i );
            else
              sameord[j]:= [ i ];
            fi;
          od;

        fi;

      od;

      for i in [ 1 .. nccl ] do

        powermap[i]:= [];

        if IsInt( orders[i] ) then

          if orders[i] mod prime = 0 then

            # maps to a class with representative order that is smaller
            # by a factor 'prime'

            for j in sameord[ orders[i] / prime ] do
              if centralizers[j] mod centralizers[i] = 0 then
                AddSet( powermap[i], j );
              fi;
            od;

          elif prime mod orders[i] = 1 then

            # necessarily fixed class
            powermap[i][1]:= i;

          else

            # maps to a class of same order

            for j in sameord[ orders[i] ] do
              if centralizers[j] = centralizers[i] then
                AddSet( powermap[i], j );
              fi;
            od;

          fi;  

        else

          # representative order is not uniquely determined

          for j in orders[i] do

            if j mod prime = 0 then

              # maps to a class with representative order that is smaller
              # by a factor 'prime'

              if IsBound( sameord[ j / prime ] ) then
                for k in sameord[ j / prime ] do
                  if centralizers[k] mod centralizers[i] = 0 then
                    AddSet( powermap[i], k );
                  fi;
                od;
              fi;

            elif prime mod j = 1 then

              # necessarily fixed class
              AddSet( powermap[i], i );

            else

              # maps to a class of same order
              for k in sameord[j] do
                if centralizers[k] = centralizers[i] then
                  AddSet( powermap[i], k );
                fi;
              od;

            fi;  
          od;

          if Gcd( orders[i] ) mod prime = 0 then

            # necessarily the representative order of the image is smaller
            RemoveSet( powermap[i], i );

          fi;
        fi;
      od;

    else

      # just centralizer orders are known

      for i in [ 1 .. nccl ] do
        powermap[i]:= [];
        for j in [ 1 .. nccl ] do
          if centralizers[j] mod centralizers[i] = 0 then
            AddSet( powermap[i], j );
          fi;
        od;
      od;

    fi;

    # Check whether a map is possible, and replace image lists of length 1
    # by their entry.

    for i in [ 1 .. nccl ] do
      if   Length( powermap[i] ) = 0 then
        Info( InfoCharacterTable, 2,
              "InitPowermap: no image possible for classes\n",
              "#E ", Filtered( [ 1..nccl ], x -> powermap[x]=[] ) );
        return fail;
#T check earlier!
      elif Length( powermap[i] ) = 1 then
        powermap[i]:= powermap[i][1];
      fi;
    od;

    # If the representative orders are not uniquely determined,
    # and the centre is not trivial, the image of class 1 is not uniquely
    # determined by the check of centralizer orders.

    if ( IsInt( powermap[1] ) and powermap[1] <> 1 ) or
       ( IsList( powermap[1] ) and not 1 in powermap[1] ) then
      Print( "#E InitPowermap: class 1 cannot contain the identity\n" );
#T ??
#T assert ?
      return fail;
    fi;
    powermap[1]:= 1;

    return powermap;
end;


#############################################################################
##
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime> )
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime>, \"quick\" )
#F  Congruences( <tbl>, <chars>, <prime_powermap>, <prime>, true )
##
Congruences := function( arg )

    local i, j,
          tbl,       # character table, first argument
          chars,     # list of characters, second argument
          powermap,  # 
          prime,     #
          nccl,
          omega,
          images,
          newimage,
          cand_image,
          ok,
          char,
          errors;    # list of classes for that no images are possible

    # Check the arguments.
    if not ( Length( arg ) in [ 4, 5 ] and IsOrdinaryTable( arg[1] )
             and IsList(arg[2]) and IsList(arg[3]) and IsPrimeInt(arg[4]) )
       or ( Length( arg ) = 5
             and arg[5] <> "quick" and not IsBool( arg[5] ) ) then
      Error("usage: Congruences(tbl,chars,powermap,prime,\"quick\")\n",
            " resp. Congruences(tbl,chars,powermap,prime)" );
    fi;

    # Get the arguments.
    tbl:= arg[1];
    chars:= arg[2];
    powermap:= arg[3];
    prime:= arg[4];

    nccl:= Length( powermap );
    omega:= [ 1 .. nccl ];
    if Length( arg ) = 5 and ( arg[5] = "quick" or arg[5] = true ) then
      # "quick": only consider ambiguous classes
      for i in [ 1 .. nccl ] do
        if IsInt( powermap[i] ) or Length( powermap[i] ) <= 1 then
          RemoveSet( omega, i );
        fi;
      od;
    fi;
    for i in omega do
      if IsInt( powermap[i] ) then
        images:= [ powermap[i] ];
      else
        images:= powermap[i];
      fi;
      newimage:= [];
      for cand_image in images do
        j:= 1;
        ok:= true;
        while j <= Length( chars ) and ok do   # loop over characters
          char:= chars[j];
          if not IsUnknown( char[ cand_image ] ) then
            if IsInt( char[i] ) then
              if not IsCycInt( ( char[ cand_image ] - char[i] ) / prime ) then
                ok:= false;
              fi;
            elif IsCyc( char[i] ) then
              if     HasOrdersClassRepresentatives( tbl )
#T treatment of orders ...
                 and IsList( OrdersClassRepresentatives( tbl ) )
                 and ( (     IsInt( OrdersClassRepresentatives( tbl )[i] )
                         and OrdersClassRepresentatives( tbl )[i] mod prime
                             <> 0 ) 
                     or ( IsList( OrdersClassRepresentatives( tbl )[i] )
                           and ForAll( OrdersClassRepresentatives( tbl )[i],
                                       x -> x mod prime <> 0 ) ) ) then
                if char[ cand_image ] <> GaloisCyc( char[i], prime ) then
                  ok:= false;
                fi;
              elif not IsCycInt( ( char[ cand_image ]
                                 - GaloisCyc(char[i],prime) ) / prime ) then
                ok:= false;
              fi;
            fi;
          fi;
          j:= j+1;
        od;
        if ok then
          AddSet( newimage, cand_image );
        fi;
      od;
      powermap[i]:= newimage;
    od;

    # Replace lists of length 1 by their entries,
    # look for empty lists.
    errors:= [];
    for i in omega do
      if   Length( powermap[i] ) = 0 then
        Add( errors, i );
      elif Length( powermap[i] ) = 1 then
        powermap[i]:= powermap[i][1];
      fi;
    od;
    if Length( errors ) > 0 then
      Info( InfoCharacterTable, 1,
            "Congruences(.,.,.,", prime,
            "): no image possible for classes ", errors );
      return false;
    fi;
    return true;
end;


#############################################################################
##
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime> )
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime>, \"quick\" )
#F  ConsiderKernels( <tbl>, <chars>, <prime_powermap>, <prime>, true )
##
ConsiderKernels := function( arg )

    local i,
          tbl,
          tbl_size,
          chars,
          prime_powermap,
          prime,
          nccl,
          omega,
          kernels,
          chi,
          kernel,
          suborder;

    if not ( Length( arg ) in [ 4, 5 ] and IsOrdinaryTable( arg[1] ) and
             IsList( arg[2] ) and IsList( arg[3] ) and IsPrimeInt( arg[4] ) )
       or ( Length( arg ) = 5
             and arg[5] <> "quick" and not IsBool( arg[5] ) ) then
      Error("usage: ConsiderKernels( tbl, chars, prime_powermap, prime )\n",
           "resp. ConsiderKernels(tbl,chars,prime_powermap,prime,\"quick\")");
    fi;

    tbl:= arg[1];
    tbl_size:= Size( tbl );
    chars:= arg[2];
    prime_powermap:= arg[3];
    prime:= arg[4];
    nccl:= Length( prime_powermap );
    omega:= Set( [ 1 .. nccl ] );
    kernels:= [];
    for chi in chars do AddSet( kernels, KernelChar( chi ) ); od;
    kernels:= Difference( kernels, Set( [ omega, [ 1 ] ] ) );
    if Length( arg ) = 5 and ( arg[5] = "quick" or arg[5] = true ) then
      # "quick": only consider ambiguous classes
      omega:= [];
      for i in [ 1 .. nccl ] do
        if IsList(prime_powermap[i]) and Length( prime_powermap[i] ) > 1 then
          AddSet( omega, i );
        fi;
      od;
    fi;
    for kernel in kernels do
      suborder:= 0;
      for i in kernel do suborder:= suborder + tbl.classes[i]; od;
      if tbl_size mod suborder <> 0 then
        Info( InfoCharacterTable, 2,
              "ConsiderKernels: kernel of character is not a", " subgroup" );
        return false;
      fi;
      for i in Intersection( omega, kernel ) do
        if IsList( prime_powermap[i] ) then
          prime_powermap[i]:= Intersection( prime_powermap[i], kernel );
        else
          prime_powermap[i]:= Intersection( [ prime_powermap[i] ], kernel );
        fi;
        if Length( prime_powermap[i] ) = 1 then
          prime_powermap[i]:= prime_powermap[i][1];
        fi;
      od;
      if ( tbl_size / suborder ) mod prime <> 0 then
        for i in Difference( omega, kernel ) do
          if IsList( prime_powermap[i] ) then
            prime_powermap[i]:= Difference( prime_powermap[i], kernel );
          else
            prime_powermap[i]:= Difference( [ prime_powermap[i] ], kernel );
          fi;
          if Length( prime_powermap[i] ) = 1 then
            prime_powermap[i]:= prime_powermap[i][1];
          fi;
        od;
      elif ( tbl_size / suborder ) = prime then
        for i in Difference( omega, kernel ) do
          if IsList( prime_powermap[i] ) then
            prime_powermap[i]:= Intersection( prime_powermap[i], kernel );
          else
            prime_powermap[i]:= Intersection( [ prime_powermap[i] ], kernel );
          fi;
          if Length( prime_powermap[i] ) = 1 then
            prime_powermap[i]:= prime_powermap[i][1];
          fi;
        od;
      fi;
    od;
    if ForAny( prime_powermap, x -> x = [] ) then
      Info( InfoCharacterTable, 2,
            "ConsiderKernels: no images left for classes ", 
                      Filtered( [ 1 .. Length( prime_powermap ) ],
                                x -> prime_powermap[x] = [] ) );
      return false;
    fi;
    return true;
end;


#############################################################################
##
#F  ConsiderSmallerPowermaps( <tbl>, <prime_powermap>, <prime> )
#F  ConsiderSmallerPowermaps( <tbl>, <prime_powermap>, <prime>, \"quick\" )
#F  ConsiderSmallerPowermaps( <tbl>, <prime_powermap>, <prime>, true )
##
ConsiderSmallerPowermaps := function( arg )

    local i, j,            # loop variables
          tbl,             # character table
          tbl_orders,      #
          tbl_powermap,    #
          prime_powermap,  # 2nd argument
          prime,           # 3rd argument
          omega,           # list of classes to be tested
          factors,         # factors modulo representative order
          image,           # possible images after testing
          old,             # possible images before testing
          errors;          # list of classes where no image is possible

    # check the arguments
    if not ( Length( arg ) in [ 3, 4 ] and IsOrdinaryTable( arg[1] )
             and IsList( arg[2] ) and IsPrimeInt( arg[3] ) )
       or ( Length( arg ) = 4
             and arg[4] <> "quick" and not IsBool( arg[4] ) ) then
      Error( "usage: ",
        "ConsiderSmallerPowermaps(<tbl>,<prime_powermap>,<prime>) resp.\n",
        "ConsiderSmallerPowermaps(<tbl>,<prime_powermap>,<prime>,\"quick\")");
    fi;

    tbl:= arg[1];
    if not HasOrdersClassRepresentatives( tbl ) then
      Info( InfoCharacterTable, 2,
            "ConsiderSmallerPowermaps: no orders bound, no test" );
      return true;
    fi;
    tbl_orders:= OrdersClassRepresentatives( tbl);
    tbl_powermap:= ComputedPowerMaps( tbl);
    prime_powermap:= arg[2];
    prime:= arg[3];

    # 'omega' will be a list of classes to be tested
    omega:= [];

    if Length( arg ) = 4 and ( arg[4] = "quick" or arg[4] = true ) then

      # 'quick' option: only test classes with ambiguities
      for i in [ 1 .. Length( prime_powermap ) ] do
        if IsList( prime_powermap[i] ) and prime > tbl_orders[i] then
          Add( omega, i );
        fi;
      od;

    else

      # test all classes where reduction modulo representative orders
      # can yield conditions
      for i in [ 1 .. Length( prime_powermap ) ] do
        if prime > tbl_orders[i] then Add( omega, i ); fi;
      od;

    fi;

    # list of classes where no image is possible
    errors:= [];

    for i in omega do

      factors:= FactorsInt( prime mod tbl.orders[i] );
      if factors = [ 1 ] or factors = [ 0 ] then factors:= []; fi;

      if ForAll( Set( factors ), x -> IsBound( tbl_powermap[x] ) ) then

        # compute image under composition of power maps for smaller primes
        image:= [ i ];
        for j in factors do
          image:= [ CompositionMaps( tbl_powermap[j], image, 1 ) ];
        od;
        image:= image[1];

        # 'old': possible images before testing
        if IsInt( prime_powermap[i] ) then
          old:= [ prime_powermap[i] ];
        else
          old:= prime_powermap[i];
        fi;

        # compare old and new possibilities of images
        if IsInt( image ) then
          if image in old then 
            prime_powermap[i]:= image;
          else
            Add( errors, i );
            prime_powermap[i]:= [];
          fi;
        else
          image:= Intersection2( image, old );
          if image = [] then
            Add( errors, i );
            prime_powermap[i]:= [];
          elif old <> image then
            if Length( image ) = 1 then image:= image[1]; fi;
            prime_powermap[i]:= image;
          fi;
        fi;

      fi;

    od;

    if Length( errors ) <> 0 then
      Info( InfoCharacterTable, 2,
            "ConsiderSmallerPowermaps: no image possible for classes ",
            errors );
      return false;
    fi;

    return true;
end;


#############################################################################
##
#F  PowermapsAllowedBySymmetrisations( <tbl>, <subchars>, <chars>, <pow>,
#F                                     <prime>, <parameters> )
##
##  <parameters> must be a record with fields <maxlen> (int), <contained>,
##  <minamb>, <maxamb> and <quick> (boolean).
##
##  First, for all $\chi \in <chars>$ let
##  'minus:= MinusCharacter( $\chi$, <pow>, <prime> )'. If
##  '<minamb> \< Indeterminateness( minus ) \< <maxamb>', construct
##  'poss:= contained( <tbl>, <subchars>, minus )'.
##  (<contained> is a function that will be 'ContainedCharacters' or
##  'ContainedPossibleCharacters'.)
##  If 'Indeterminateness( minus ) \< <minamb>', delete this character;
##  for unique minus-characters, if '<parameters>.quick = false', the
##  scalar products with <subchars> are checked.
##  (especially if the minus-character is unique, i.e.\ it is not quecked if
##  the symmetrizations of such a character decompose correctly).
##  Improve <pow> if possible.
##
##  If the minus character af a character *becomes* unique during the
##  processing, its scalar products with <subchars> are checked.
##
##  If no further improvement is possible, delete all characters with unique
##  minus-character, and branch:
##  If there is a character left with less or equal <maxlen> possible minus-
##  characters, compute the union of powermaps allowed by these characters;
##  otherwise choose a class 'c' which is significant for some
##  character, and compute the union of all allowed powermaps with image 'x' on
##  'c', where 'x' runs over '<pow>[c]'.
##
##  By recursion, one gets the list of powermaps which are parametrized on all
##  classes where no element of <chars> is significant, and which yield
##  nonnegative integer scalar products for the minus-characters of <chars>
##  with <subchars>.
##
##  If '<parameters>.quick = true', unique minus characters are never
##  considered.
##
PowermapsAllowedBySymmetrisations :=
              function( tbl, subchars, chars, pow, prime, parameters )

    local i, j, x, indeterminateness, numbofposs, lastimproved, minus, indet,
          poss, param, remain, possibilities, improvemap, allowedmaps, rat,
          powerchars, maxlen, contained, minamb, maxamb, quick;

    if IsEmpty( chars ) then
      return [ pow ];
    fi;

    chars:= Set( chars );
    
    # but maybe there are characters with equal restrictions ...
    
    # record 'parameters'\:
    if not IsRecord( parameters ) then
      Error( "<parameters> must be a record with fields 'maxlen',\n",
             "'contained', 'minamb', 'maxamb' and 'quick'" );
    fi;

    maxlen:= parameters.maxlen;
    contained:= parameters.contained;
    minamb:= parameters.minamb;
    maxamb:= parameters.maxamb;
    quick:= parameters.quick;
    
    if quick and Indeterminateness( pow ) < minamb then # immediately return
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrisations: ",
            " indeterminateness of the map\n",
            "#I    is smaller than the parameter value",
            " 'minamb'; returned" );
      return [ pow ];
    fi;
    
    # step 1: check all in <chars>; if one has too big indeterminateness
    #         and contains irrational entries, append its rationalized
    #         character to <chars>.
    indeterminateness:= []; # at pos. i the indeterminateness of character i
    numbofposs:= [];        # at pos. 'i' the number of allowed restrictions
                            # for '<chars>[i]'
    lastimproved:= 0;       # last char which led to an improvement of 'pow';
                            # every run through the list may stop at this char
    powerchars:= [];        # at position 'i' the <prime>-th power of
                            # '<chars>[i]'
    i:= 1;
    while i <= Length( chars ) do
      powerchars[i]:= List( chars[i], x -> x ^ prime );
      minus:= MinusCharacter( chars[i], pow, prime );
      indet:= Indeterminateness( minus );
      indeterminateness[i]:= indet;
      if indet = 1 then
        if not quick
           and not NonnegIntScalarProducts( tbl, subchars, minus ) then
          return [];
        fi;
      elif indet < minamb then
        indeterminateness[i]:= 1;
      elif indet <= maxamb then
        poss:= contained( tbl, subchars, minus );
        if poss = [] then return []; fi;
        numbofposs[i]:= Length( poss );
        param:= Parametrized( poss );
        if param <> minus then  # improvement found
          UpdateMap( chars[i], pow, List( [ 1 .. Length( powerchars[i] ) ],
                             x-> powerchars[i][x] - prime * param[x] ) );
          lastimproved:= i;
          indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], pow ) );
        fi;
      else
        numbofposs[i]:= "infinity";
        if ForAny( chars[i], x -> IsCyc(x) and not IsRat(x) ) then

          # maybe the indeterminateness of the rationalized character is
          # smaller but not 1
          rat:= RationalizedMat( [ chars[i] ] )[1];
          if not rat in chars then Add( chars, rat ); fi;
        fi;
      fi;
      i:= i + 1;
    od;
    if lastimproved > 0 then
      indeterminateness[ lastimproved ]:=
            Indeterminateness( CompositionMaps( chars[lastimproved], pow ) );
    fi;
    
    # step 2: (local function 'improvemap')
    #         loop over characters until no improvement is possible without a
    #         branch; update 'indeterminateness' and 'numbofposs';
    #         first character to test is at position 'first'; at least run up
    #         to character $'lastimproved' - 1$, update 'lastimproved' if an
    #         improvement occurs; return 'false' in the case of an
    #         inconsistency, 'true' otherwise.
    improvemap:= function( chars, pow, first, lastimproved,
                           indeterminateness, numbofposs, powerchars )
    local i, x, poss;
    i:= first;
    while i <> lastimproved do
      if indeterminateness[i] <> 1 then
        minus:= MinusCharacter( chars[i], pow, prime );
        indet:= Indeterminateness( minus );
        if indet < indeterminateness[i] then

          # only test those chars which now have smaller indeterminateness
          indeterminateness[i]:= indet;
          if indet = 1 then
            if not quick
               and not NonnegIntScalarProducts( tbl, subchars, minus ) then
              return false;
            fi;
          elif indet < minamb then
            indeterminateness[i]:= 1;
          elif indet <= maxamb then
            poss:= contained( tbl, subchars, minus );
            if poss = [] then return false; fi;
            numbofposs[i]:= Length( poss );
            param:= Parametrized( poss );
            if param <> minus then  # improvement found
              UpdateMap( chars[i], pow,
                         List( [ 1 .. Length( param ) ],
                               x -> powerchars[i][x] - prime * param[x] ) );
              lastimproved:= i;
              indeterminateness[i]:= Indeterminateness(
                                        CompositionMaps( chars[i], pow ) );
            fi;
          fi;
        fi;
      fi;
      if lastimproved = 0 then lastimproved:= i; fi;
      i:= i mod Length( chars ) + 1;
    od;
    indeterminateness[ lastimproved ]:=
            Indeterminateness( CompositionMaps( chars[lastimproved], pow ) );
    return true;
    end;
    
    # step 3: recursion; (local function 'allowedmaps')
    #         a) delete all characters which now have indeterminateness 1;
    #            their minus-characters (with respect to every powermap that
    #            will be found ) have nonnegative scalar products with
    #            <subchars>.
    #         b) branch according to a significant character or class
    #         c) for each possibility call 'improvemap' and then the recursion
    
    allowedmaps:= function( chars, pow, indeterminateness, numbofposs,
                            powerchars )
    local i, j, class, possibilities, poss, newpow, newpowerchars, newindet,
          newnumbofposs, copy;
    remain:= Filtered( [ 1 .. Length(chars) ], i->indeterminateness[i] > 1 );
    chars:=             chars{ remain };
    indeterminateness:= indeterminateness{ remain };
    numbofposs:=        numbofposs{ remain };
    powerchars:=        powerchars{ remain };

    if chars = [] then
      Info( InfoCharacterTable, 2, "#I  PossiblePowerMapssAllowedBySymmetrisations: no character",
                      " with indeterminateness\n#I    between ", minamb,
                      " and ", maxamb, " significant now\n" );
      return [ pow ];
    fi;
    possibilities:= [];
    if Minimum( numbofposs ) < maxlen then
      # branch according to a significant character
      # with minimal number of possible restrictions
      i:= Position( numbofposs, Minimum( numbofposs ) );
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrisations: branch at character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );
      poss:= contained( tbl, subchars,
                        MinusCharacter( chars[i], pow, prime ) );
      for j in poss do
        newpow:= List( pow, ShallowCopy );
        UpdateMap( chars[i], newpow, powerchars[i] - prime * j );
        newindet:= List( indeterminateness, ShallowCopy );
        newnumbofposs:= List( numbofposs, ShallowCopy );
#T really this way to replace 'Copy' ?
        if improvemap( chars, newpow, i, 0, newindet, newnumbofposs,
                       powerchars ) then
          Append( possibilities,
                  allowedmaps( chars, newpow, newindet, newnumbofposs,
                               ShallowCopy( powerchars ) ) );
        fi;
      od;
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrisations: return from",
            " branch at character\n",
            "#I     ", CharacterString( chars[i], "" ),
            " (", numbofposs[i], " calls)" );
    else
    
      # branch according to a significant class in a
      # character with minimal nontrivial indet.
      i:= Position( indeterminateness, Minimum( indeterminateness ) );
                             # always nontrivial indet.!
      minus:= MinusCharacter( chars[i], pow, prime );
      class:= 1;
      while not IsList( minus[ class ] ) do class:= class + 1; od;
    
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrisations: ",
            "branch at class ",
            class, " (", Length( pow[ class ] ), " calls)\n" );
    
      # too many calls!!
      # (only those were necessary which are different for minus)
    
      for j in pow[ class ] do
        newpow:= List( pow, ShallowCopy );
        newpow[ class ]:= j;
        copy:= DeepCopy( ComputedPowerMaps( tbl ) );
#T really?
        Unbind( copy[ prime ] );
        if TestConsistencyMaps( copy, newpow, copy ) then
          newindet:= List( indeterminateness, ShallowCopy );
          newnumbofposs:= List( numbofposs, ShallowCopy );
#T really?
          if improvemap( chars, newpow, i, 0, newindet, newnumbofposs,
                         powerchars ) then
            Append( possibilities,
                    allowedmaps( chars, newpow, newindet, newnumbofposs,
                                 ShallowCopy( powerchars ) ) );
          fi;
        fi;
      od;
    
      Info( InfoCharacterTable, 2,
            "PowerMapsAllowedBySymmetrisations: return from branch at class ",
            class );
    
    fi;
    return possibilities;
    end;
    
    # start of the recursion:
    
    if lastimproved <> 0 then              # after step 1
      if not improvemap( chars, pow, 1, lastimproved, indeterminateness,
                         numbofposs, powerchars ) then
        return [];
      fi;
    fi;
    return allowedmaps( chars, pow, indeterminateness, numbofposs,
                        powerchars );
end;
  

#T hier!
#T #############################################################################
#T ##
#T #F  PossiblePowerMaps( <tbl>, <prime> )
#T #F  PossiblePowerMaps( <tbl>, <prime>, <parameters> )
#T ##
#T ##  returns a list of possibilities for the <prime>-th powermap of the
#T ##  character table <tbl>.
#T ##  If <tbl> is a Brauer table, the map is computed from the power map
#T ##  of the ordinary table '<tbl>.ordinary' which may cause a call of
#T ##  'Powermap' for this table.
#T ##  
#T ##  The optional record <parameters> may have the following fields\:
#T ##  
#T ##  'chars':\\
#T ##       a list of characters which are used for the check of kernels
#T ##       (see "ConsiderKernels"), the test of congruences (see "Congruences")
#T ##       and the test of scalar products of symmetrisations
#T ##       (see "PowermapsAllowedBySymmetrisations");
#T ##       the default is '<tbl>.irreducibles'
#T ##  
#T ##  'powermap':\\
#T ##       a (parametrized) map which is an approximation of the desired map
#T ##  
#T ##  'decompose':\\
#T ##       a boolean; if 'true', the symmetrisations of 'chars' must have all
#T ##       constituents in 'chars', that will be used in the algorithm;
#T ##       if 'chars' is not bound and '<tbl>.irreducibles' is complete,
#T ##       the default value of 'decompose' is 'true', otherwise 'false'
#T ##  
#T ##  'quick':\\
#T ##       a boolean; if 'true', the subroutines are called with the option
#T ##       '\"quick\"'; especially, a unique map will be returned immediately
#T ##       without checking all symmetrisations; the default value is 'false'
#T ##  
#T ##  'parameters':\\
#T ##       a record with fields 'maxamb', 'minamb' and 'maxlen' which control
#T ##       the subroutine 'PowermapsAllowedBySymmetrisations'\:
#T ##       It only uses characters with actual indeterminateness up to
#T ##       'maxamb', tests decomposability only for characters with actual
#T ##       indeterminateness at least 'minamb' and admits a branch only
#T ##       according to a character if there is one with at most 'maxlen'
#T ##       possible minus-characters.
#T ##
#T InstallMethod( PossiblePowerMaps,
#T     "method for an ordinary character table and a prime",
#T     true,
#T     [ IsOrdinaryTable, IsInt and IsPosRat ], 0,
#T     function( tbl, p )
#T ...
#T Powermap := function( arg )
#T 
#T     local i, x,
#T           tbl,     # character table, first argument
#T           chars,
#T           prime,   # prime number, second argument
#T           powermap, indet,
#T           maxamb,
#T           minamb,
#T           maxlen,
#T           poss, rat, pow, approxval, powerval, approxpowermap, quick, ok,
#T           decompose,
#T           fus,      # Brauer table: fusion map from 'tbl' to 'tbl.ordinary'
#T           inv;      # Brauer table: inverse map of 'fus'
#T     
#T     if not ( Length( arg ) in [ 2, 3 ] and IsOrdinaryTable( arg[1] )
#T              and IsPrimeInt( arg[2] ) )
#T        or ( Length( arg ) = 3 and not IsRecord( arg[3] ) ) then
#T       Error( "usage: Powermap( <tbl>, <prime> )\n",
#T              " resp. Powermap( <tbl>, <prime>, <parameters> )" );
#T     fi;
#T     
#T     tbl:=   arg[1];
#T     prime:= arg[2];
#T 
#T     if Length( arg ) = 3 then       # parameters
#T       if IsBound( arg[3].chars ) then
#T         chars:= arg[3].chars;
#T         decompose:= false;
#T       else
#T         if IsBound( tbl.irreducibles ) then
#T           chars:= tbl.irreducibles;
#T           if Length( chars ) = Length( tbl.centralizers ) then
#T             decompose:= true;
#T           else
#T             decompose:= false;
#T           fi;
#T         else
#T           chars:= [];
#T           decompose:= false;
#T         fi;
#T       fi;
#T       if IsBound( arg[3].powermap ) then
#T         approxpowermap:= arg[3].powermap;
#T       else
#T         approxpowermap:= [];
#T       fi;
#T       if IsBound( arg[3].quick ) and arg[3].quick = true then
#T         quick:= true;
#T       else
#T         quick:= false;
#T       fi;
#T       if IsBound( arg[3].decompose ) then
#T         if arg[3].decompose = true then
#T           decompose:= true;
#T         else
#T           decompose:= false;
#T         fi;
#T       fi;
#T       if IsBound( arg[3].parameters ) then
#T         maxamb:= arg[3].parameters.maxamb;
#T         minamb:= arg[3].parameters.minamb;
#T         maxlen:= arg[3].parameters.maxlen;
#T       else
#T         maxamb:= 100000;
#T         minamb:= 10000;
#T         maxlen:= 10;
#T       fi;
#T     else
#T       if IsBound( tbl.irreducibles ) then 
#T         chars:= tbl.irreducibles;
#T       else
#T         chars:= [];
#T       fi;
#T       if Length( chars ) = Length( tbl.centralizers ) then
#T         decompose:= true;
#T       else
#T         decompose:= false;
#T       fi;
#T       approxpowermap:= [];
#T       quick:= false;
#T       maxamb:= 100000;
#T       minamb:= 10000;
#T       maxlen:= 10;
#T     fi;
#T     
#T     powermap:= InitPowermap( tbl, prime );
#T     if powermap = false then
#T       Info( InfoCharacterTable, 2, "#I  PossiblePowerMaps: no initialization possible\n" );
#T       return [];
#T     fi;
#T     
#T     # use 'approxpowermap'\:
#T     ok:= MeetMaps( powermap, approxpowermap );
#T     if ok <> true then
#T #T ?
#T       Info( InfoCharacterTable, 2,
#T             "PossiblePowerMaps: possible maps not compatible with ",
#T                       "<approxpowermap> at class ", ok );
#T       return [];
#T     fi;
#T 
#T     if not Congruences( tbl, chars, powermap, prime, quick ) then
#T       Info( InfoCharacterTable, 2,
#T             "PossiblePowerMaps: errors in Congruences" );
#T       return [];
#T     fi;
#T     if not ConsiderKernels( tbl, chars, powermap, prime, quick ) then
#T       Info( InfoCharacterTable, 2,
#T             "PossiblePowerMaps: errors in ConsiderKernels" );
#T       return [];
#T     fi;
#T     if not ConsiderSmallerPowermaps( tbl, powermap, prime, quick ) then
#T       Info( InfoCharacterTable, 2,
#T             "PossiblePowerMaps: errors in ConsiderSmallerPowermaps" );
#T       return [];
#T     fi;
#T     
#T     if 2 <= InfoLevel( InfoCharacterTable ) then
#T ??
#T       Print( "#I  PossiblePowerMaps: ", Ordinal( prime ),
#T              " powermap initialized; congruences, kernels and\n",
#T              "#I    maps for smaller primes considered.\n",
#T              "#I    The actual indeterminateness is ",
#T              Indeterminateness( powermap ), ".\n" );
#T       if quick then
#T         Print( "#I    (\"quick\" option specified)\n" );
#T       fi;
#T 
#T     fi;
#T     
#T     if quick and ForAll( powermap, IsInt ) then return [ powermap ]; fi;
#T     
#T     # now use restricted characters:
#T     # If the parameter \"decompose\" was entered, use decompositions
#T     # of minus-characters of <chars> into <chars>;
#T     # otherwise only check the scalar products with <chars>.
#T     
#T     if decompose then                 # usage of decompositions allowed
#T       if Indeterminateness( powermap ) < minamb then
#T         Info( InfoCharacterTable, 2,
#T               "PossiblePowerMaps: indeterminateness too small for test",
#T               " of decomposability" );
#T         poss:= [ powermap ];
#T       else
#T         Info( InfoCharacterTable, 2,
#T               "PossiblePowerMaps: now test decomposability of rational ",
#T               "minus-characters" );
#T         rat:= RationalizedMat( chars );
#T 
#T         poss:= PowermapsAllowedBySymmetrisations( tbl, rat, rat, powermap,
#T                              prime, rec( maxlen:= maxlen,
#T                                          contained:= ContainedCharacters,
#T                                          minamb:= minamb,
#T                                          maxamb:= "infinity",
#T                                          quick:= quick ) );
#T         if 2 <= InfoLevel( InfoCharacterTable ) then
#T 
#T           Print( "#I  PossiblePowerMaps: decomposability tested,\n" );
#T           if Length( poss ) = 1 then
#T             Print( "#I    1 solution with indeterminateness ",
#T                    Indeterminateness( poss[1] ), "\n" );
#T           else
#T             Print( "#I    ", Length( poss ),
#T                    " solutions with indeterminateness\n",
#T                    List( poss, Indeterminateness ), "\n" );
#T           fi;
#T         fi;
#T         if quick and Length( poss ) = 1 and ForAll( poss[1], IsInt ) then
#T           return [ poss[1] ];
#T         fi;
#T       fi;
#T     else
#T       Info( InfoCharacterTable, 2,
#T             "PossiblePowerMaps: no test of decomposability allowed" );
#T       poss:= [ powermap ];
#T     fi;
#T     
#T     Info( InfoCharacterTable, 2,
#T           "PossiblePowerMaps: test scalar products",
#T           " of minus-characters" );
#T     
#T     powermap:= [];
#T     for pow in poss do
#T       Append( powermap,
#T               PowermapsAllowedBySymmetrisations( tbl, chars, chars, pow,
#T                           prime, rec( maxlen:= maxlen,
#T                                       contained:= ContainedPossibleCharacters,
#T                                       minamb:= 1,
#T                                       maxamb:= maxamb,
#T                                       quick:= quick ) ) );
#T     od;
#T 
#T     if 2 <= InfoLevel( InfoCharacterTable ) then
#T 
#T       if ForAny( powermap, x -> ForAny( x, IsList ) ) then
#T         Print( "#I  PossiblePowerMaps: ", Length(powermap), " parametrized solution" );
#T         if Length(powermap) = 1 then Print(",\n"); else Print("s,\n"); fi;
#T         Print( "#I    no further improvement was possible with given",
#T                " characters\n",
#T                "#I    and maximal checked ambiguity of ", maxamb, "\n" );
#T       else
#T         Print( "#I  PossiblePowerMaps: ", Length( powermap ), " solution" );
#T         if Length(powermap) = 1 then Print("\n"); else Print("s\n"); fi;
#T       fi;
#T     fi;
#T     return powermap;
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #F  ConsiderTableAutomorphisms( <parafus>, <grp> )
#T ##
#T ##  improves the parametrized subgroup fusion map <parafus> so that
#T ##  afterwards exactly one representative of fusion maps (that is contained
#T ##  in <parafus>) in every orbit under the action of the permutation group
#T ##  <grp> is contained in <parafus>.
#T ##
#T ##  The list of positions where improvements were found is returned.
#T ##
#T ConsiderTableAutomorphisms := function( parafus, grp )
#T 
#T     local i, support, images, notstable, orbits, isunion, image, orb,
#T           im, found, prop;
#T     
#T     # step 1: Compute the subgroup of <grp> that acts on all images
#T     #         under <parafus>; if <parafus> contains all possible subgroup
#T     #         fusions, this is the whole group of table automorphisms of the
#T     #         supergroup table.
#T     
#T     if IsTrivial( grp ) then
#T       return [];
#T     fi;
#T     images:= Set( parafus );
#T     notstable:= Filtered( images, x -> IsInt(x) and
#T                           ForAny( grp.generators, y->x^y<>x ) );
#T     if notstable = [] then
#T       MakeStabChain( grp );
#T ??
#T     else
#T       InfoPermGroup2( "#I ConsiderTableAutomorphisms: not all generators fix",
#T                       " uniquely\n#I    determined images;",
#T                       " computing admissible subgroup\n" );
#T       grp:= Stabilizer( grp, notstable, OnTuples );
#T     fi;
#T     if grp.generators = [] then return []; fi;
#T ??
#T 
#T     images:= Filtered( images, IsList );
#T     support:= grp.operations.LargestMovedPoint( grp );
#T     orbits:= List( Orbits( grp, [ 1 .. support ] ), Set );
#T                               # sets because entries of parafus are sets
#T 
#T     isunion:= function( image )
#T     while image <> [] do
#T       if image[1] > support then return true; fi;
#T       orb:= First( orbits, x -> image[1] in x );
#T       if Difference( orb, image ) <> [] then return false; fi;
#T       image:= Difference( image, orb );
#T     od;
#T     return true;
#T     end;
#T 
#T     notstable:= Filtered( images, x -> not isunion(x) );
#T     if notstable <> [] then
#T       InfoPermGroup2( "#I ConsiderTableAutomorphisms:",
#T                       " not all generators act;\n",
#T                       "#I    computing admissible subgroup\n" );
#T       for i in notstable do
#T         grp:= grp.operations.StabilizerSet( grp, i );
#T       od;
#T     
#T     #   prop:= function( perm )
#T     #          return ForAll( notstable, x -> Set( x^perm ) = x );
#T     #          end;
#T     #   grp:= SubgroupProperty( grp, prop );
#T     
#T     fi;
#T     
#T     # step 2: If possible, find a class where the image {\em is} a nontrivial
#T     #         orbit under <grp>, i.e. no other points are
#T     #         possible. Then replace the image by the first point of the
#T     #         orbit, and replace <grp> by the stabilizer of
#T     #         the new image in <grp>.
#T     
#T     found:= [];
#T     i:= 1;
#T     while i <= Length( parafus ) and grp.generators <> [] do
#T       if IsList( parafus[i] ) and parafus[i] in orbits then
#T         Add( found, i );
#T         parafus[i]:= parafus[i][1];
#T         grp:= grp.operations.Stabilizer( grp, parafus[i], OnPoints );
#T         if grp.generators <> [] then
#T           support:= grp.operations.LargestMovedPoint( grp );
#T           orbits:= List( Orbits( grp, [ 1 .. support ] ), Set );
#T 
#T           # Compute orbits of the smaller group; sets because entries
#T           # of parafus are sets
#T 
#T         fi;
#T       fi;
#T       i:= i + 1;
#T     od;
#T     
#T     # step 3: If 'grp' is not trivial, find classes where the image
#T     #         {\em contains} a nontrivial orbit under 'grp'. 
#T     
#T     i:= 1;
#T     while i <= Length( parafus ) and grp.generators <> [] do
#T       if IsList( parafus[i] ) and ForAny( grp.generators,
#T                                   x -> ForAny( parafus[i], y->y^x<>y ) ) then
#T         Add( found, i );
#T         image:= [];
#T         while parafus[i] <> [] do
#T     
#T           # now it is necessary to consider orbits of the smaller group,
#T           # since improvements in step 2 and 3 may affect the action
#T           # on the images.
#T     
#T           Add( image, parafus[i][1] );
#T           parafus[i]:= Difference( parafus[i], Orbit( grp, parafus[i][1] ) );
#T         od;
#T         for im in image do
#T           if grp.generators <> [] then
#T             grp:= grp.operations.Stabilizer( grp, im, OnPoints );
#T           fi;
#T         od;
#T         parafus[i]:= image;
#T       fi;
#T       i:= i+1;
#T     od;
#T     return found;
#T end;


#############################################################################
##
#F  OrbitFusions( <subtblautomorphisms>, <fusionmap>, <tblautomorphisms> )
##
OrbitFusions := function( subtblautomorphisms, fusionmap, tblautomorphisms )

    local i, orb, gen, image;

    orb:= [ fusionmap ];
    for fusionmap in orb do
      for gen in GeneratorsOfGroup( subtblautomorphisms ) do
        image:= Permuted( fusionmap, gen );
        if not image in orb then Add( orb, image ); fi;
      od;
    od;
    for fusionmap in orb do
      for gen in GeneratorsOfGroup( tblautomorphisms ) do
        image:= [];
        for i in fusionmap do
          if IsInt( i ) then
            Add( image, i^gen );
          else
            Add( image, Set( OnTuples( i, gen ) ) );
          fi;
        od;
        if not image in orb then Add( orb, image ); fi;
      od;
    od;
    return orb;
end;


#############################################################################
##
#F  OrbitPowerMaps( <powermap>, <matautomorphisms> )
##
OrbitPowerMaps := function( powermap, matautomorphisms )

    local nccl, orb, gen, image;

    nccl:= Length( powermap );
    orb:= [ powermap ];
    for powermap in orb do
      for gen in GeneratorsOfGroup( matautomorphisms ) do
        image:= List( [ 1 .. nccl ], x -> powermap[ x^gen ] / gen );
        if not image in orb then Add( orb, image ); fi;
      od;
    od;
    return orb;
end;


#T #############################################################################
#T ##
#T #F  RepresentativesFusions( <subtblautomorphisms>, <listoffusionmaps>,
#T #F                          <tblautomorphisms> )
#T #F  RepresentativesFusions( <subtbl>, <listoffusionmaps>, <tbl> )
#T ##
#T ##  returns a list of representatives of subgroup fusions in the list
#T ##  <listoffusionmaps> under the action of maximal admissible subgroups
#T ##  of the table automorphisms <subtblautomorphisms> of the subgroup table
#T ##  and <tblautomorphisms> of the supergroup table.
#T ##  The table automorphisms must be both permutation groups.
#T ##
#T RepresentativesFusions := function( subtblautomorphisms, listoffusionmaps,
#T                                     tblautomorphisms )
#T 
#T     local stable, prop, orbits, orbit;
#T     
#T     if listoffusionmaps = [] then return []; fi;
#T     listoffusionmaps:= Set( listoffusionmaps );
#T     
#T     if IsOrdinaryTable( subtblautomorphisms ) then
#T 
#T       if   IsBound( subtblautomorphisms.automorphisms ) then
#T         subtblautomorphisms:= subtblautomorphisms.automorphisms;
#T       elif IsBound( subtblautomorphisms.galomorphisms ) then
#T         subtblautomorphisms:= subtblautomorphisms.galomorphisms;
#T       else
#T         subtblautomorphisms:= Group( () );
#T         Print( "#I RepresentativesFusions:",
#T                " no subtable automorphisms stored\n" );
#T       fi;
#T     fi;
#T     if IsOrdinaryTable( tblautomorphisms ) then
#T       if   IsBound( tblautomorphisms.automorphisms ) then
#T         tblautomorphisms:= tblautomorphisms.automorphisms;
#T       elif IsBound( tblautomorphisms.galomorphisms ) then
#T         tblautomorphisms:= tblautomorphisms.galomorphisms;
#T       else
#T         tblautomorphisms:= Group( () );
#T         Print( "#I RepresentativesFusions: no table automorphisms stored\n" );
#T       fi;
#T     fi;
#T       
#T     # find the subgroups of the table automorphism groups which act on
#T     # <listoffusionmaps>\:
#T     
#T     stable:= Filtered( subtblautomorphisms.generators,
#T                     x -> ForAll( listoffusionmaps, 
#T                               y -> Permuted( y, x ) in listoffusionmaps ) );
#T     if not stable = subtblautomorphisms.generators then
#T       Print("#I RepresentativesFusions: Not all table automorphisms of the\n",
#T             "#I    subgroup table do act;",
#T             " computing the admissible subgroup.\n" );
#T       prop:= ( x -> ForAll( listoffusionmaps, 
#T                             y -> Permuted( y, x ) in listoffusionmaps ) );
#T       subtblautomorphisms:=
#T                PermGroupOps.SubgroupProperty( subtblautomorphisms, prop,
#T                                               Group( stable, () ) );
#T     fi;
#T     
#T     stable:= Filtered( tblautomorphisms.generators,
#T                     x -> ForAll( listoffusionmaps, 
#T                               y -> List( y, z->z^x ) in listoffusionmaps ) );
#T     if not stable = tblautomorphisms.generators then
#T       Print("#I RepresentativesFusions: Not all table automorphisms of the\n",
#T             "#I    supergroup table do act;",
#T             " computing the admissible subgroup.\n" );
#T       prop:= ( x -> ForAll( listoffusionmaps, 
#T                             y -> List( y, z -> z^x ) in listoffusionmaps ) );
#T       tblautomorphisms:= 
#T             PermGroupOps.SubgroupProperty( tblautomorphisms, prop,
#T                                            Group( stable, () ) );
#T     fi;
#T     
#T     # distribute the maps to orbits\:
#T     
#T     orbits:= [];
#T     while listoffusionmaps <> []  do
#T       orbit:= OrbitFusions( subtblautomorphisms, listoffusionmaps[1],
#T                             tblautomorphisms );
#T       Add( orbits, orbit );
#T       SubtractSet( listoffusionmaps, orbit );
#T     od;
#T     
#T     if 2 <= InfoLevel( InfoCharacterTable ) then
#T       if Length( orbits ) = 1 then
#T         Print( "#I RepresentativesFusions: There is 1 orbit of length ",
#T                Length( orbits[1] ), ".\n" );
#T       else
#T         Print( "#I RepresentativesFusions: There are ", Length( orbits ),
#T                " orbits of lengths ", List( orbits, Length ), ".\n" );
#T       fi;
#T     fi;
#T     
#T     # choose representatives\:
#T     
#T     return List( orbits, x -> x[1] );
#T end;
#T     
#T 
#T #############################################################################
#T ##
#T #F  RepresentativesPowerMaps( <listofpowermaps>, <matautomorphisms> )
#T ##
#T ##  returns a list of representatives of powermaps in the list
#T ##  <listofpowermaps> under the action of the maximal admissible subgroup
#T ##  of the matrix automorphisms <matautomorphisms> of the considered
#T ##  character matrix.
#T ##  The matrix automorphisms must be a permutation group.
#T ##
#T RepresentativesPowerMaps := function( listofpowermaps, matautomorphisms )
#T 
#T     local nccl, stable, prop, orbits, orbit;
#T     
#T     if listofpowermaps = [] then return []; fi;
#T     listofpowermaps:= Set( listofpowermaps );
#T     
#T     # find the subgroup of the table automorphism group which acts on
#T     # <listofpowermaps>\:
#T     
#T     nccl:= Length( listofpowermaps[1] );
#T     stable:= Filtered( matautomorphisms.generators,
#T               x -> ForAll( listofpowermaps, 
#T               y -> List( [ 1..nccl ], z -> y[z^x]/x ) in listofpowermaps ) );
#T     if not stable = matautomorphisms.generators then
#T       Print( "#I RepresentativesPowermaps: Not all table automorphisms\n",
#T              "#I    do act; computing the admissible subgroup.\n" );
#T       prop:= ( x -> ForAll( listofpowermaps, 
#T                y -> List( [ 1..nccl ], z -> y[z^x]/x ) in listofpowermaps ) );
#T       if stable = [] then stable:= (); fi;
#T       matautomorphisms:=
#T             PermGroupOps.SubgroupProperty( matautomorphisms, prop,
#T                                            Group( stable, () ) );
#T     fi;
#T     
#T     # distribute the maps to orbits\:
#T     
#T     orbits:= [];
#T     while listofpowermaps <> []  do
#T       orbit:= OrbitPowermaps( listofpowermaps[1], matautomorphisms );
#T       Add( orbits, orbit );
#T       SubtractSet( listofpowermaps, orbit );
#T     od;
#T     
#T     if 2 <= Length( InfoCharacterTable ) then
#T       if Length( orbits ) = 1 then
#T         Print( "#I RepresentativesPowermaps: There is 1 orbit of length ",
#T                Length( orbits[1] ), ".\n" );
#T       else
#T         Print( "#I RepresentativesPowermaps: There are ", Length( orbits ),
#T                " orbits of lengths ", List( orbits, Length ), ".\n" );
#T       fi;
#T     fi;
#T     
#T     # choose representatives\:
#T     
#T     return List( orbits, x -> x[1] );
#T end;
#T     
#T 
#T #############################################################################
#T ##
#T #F  FusionsAllowedByRestrictions( <subtbl>, <tbl>, <subchars>, <chars>,
#T #F                                <fus>, <parameters> )
#T ##
#T ##  <parameters> must be a record with fields <maxlen> (int), <contained>,
#T ##  <minamb>, <maxamb> and <quick> (boolean).
#T ##
#T ##  First, for all $\chi \in <chars>$ let
#T ##  'restricted:= CompositionMaps( $\chi$, <fus> )'.
#T ##  If '<minamb> \< Indeterminateness( restricted ) \< <maxamb>', construct
#T ##  'poss:= contained( <subtbl>, <subchars>, restricted )'.
#T ##  (<contained> is a function that will be 'ContainedCharacters' or
#T ##  'ContainedPossibleCharacters'.)
#T ##  Improve <fus> if possible.
#T ##
#T ##  If 'Indeterminateness( restricted ) \< <minamb>', delete this character;
#T ##  for unique restrictions and '<parameters>.quick = false', the scalar
#T ##  products with <subchars> are checked.
#T ##
#T ##  If the restriction of a character *becomes* unique during the
#T ##  processing, its scalar products with <subchars> are checked.
#T ##
#T ##  If no further improvement is possible, delete all characters with unique
#T ##  restrictions or, more general, indeterminateness at most <minamb>,
#T ##  and branch:
#T ##  If there is a character left with less or equal <maxlen> possible
#T ##  restrictions, compute the union of fusions allowed by these restrictions;
#T ##  otherwise choose a class 'c' of <subgroup> which is significant for some
#T ##  character, and compute the union of all allowed fusions with image 'x' on
#T ##  'c', where 'x' runs over '<fus>[c]'.
#T ##
#T ##  By recursion, one gets the list of fusions which are parametrized on all
#T ##  classes where no element of <chars> is significant, and which yield
#T ##  nonnegative integer scalar products for the restrictions of <chars>
#T ##  with <subchars> (or additionally decomposability).
#T ##
#T ##  If '<parameters>.quick = true', unique restrictions are never considered.
#T ##
#T FusionsAllowedByRestrictions := function( subtbl, tbl, subchars, chars, fus,
#T                                           parameters )
#T 
#T     local x, i, j, indeterminateness, numbofposs, lastimproved, restricted,
#T           indet, rat, poss, param, remain, possibilities, improvefusion,
#T           allowedfusions, maxlen, contained, minamb, maxamb, quick;
#T 
#T     if IsEmpty( chars ) then
#T       return [ fus ];
#T     fi;
#T     chars:= Set( chars );
#T     
#T     # but maybe there are characters with equal restrictions ...
#T     
#T     # record <parameters>\:
#T     if not IsRecord( parameters ) then
#T       Error( "<parameters> must be a record with fields 'maxlen',\n",
#T              "'contained', 'minamb', 'maxamb' and 'quick'" );
#T     fi;
#T 
#T     maxlen:= parameters.maxlen;
#T     contained:= parameters.contained;
#T     minamb:= parameters.minamb;
#T     maxamb:= parameters.maxamb;
#T     quick:= parameters.quick;
#T     
#T     if quick and Indeterminateness( fus ) < minamb then # immediately return
#T       Info( InfoCharacterTable, 2,
#T             "FusionsAllowedByRestrictions: indeterminateness of",
#T             " the map\n#I    is smaller than the parameter value",
#T             " 'minamb'; returned" );
#T       return [ fus ];
#T     fi;
#T     
#T     # step 1: check all in <chars>; if one has too big indeterminateness
#T     #         and contains irrational entries, append its rationalized char
#T     #         <chars>.
#T     indeterminateness:= []; # at position i the indeterminateness of char i
#T     numbofposs:= [];        # at position 'i' the number of allowed
#T                             # restrictions for '<chars>[i]'
#T     lastimproved:= 0;       # last char which led to an improvement of 'fus';
#T                             # every run through the list may stop at this char
#T     i:= 1;
#T     while i <= Length( chars ) do
#T       restricted:= CompositionMaps( chars[i], fus );
#T       indet:= Indeterminateness( restricted );
#T       indeterminateness[i]:= indet;
#T       if indet = 1 then
#T         if not quick
#T            and not NonnegIntScalarProducts(subtbl,subchars,restricted) then
#T           return [];
#T         fi;
#T       elif indet < minamb then
#T         indeterminateness[i]:= 1;
#T       elif indet <= maxamb then
#T         poss:= contained( subtbl, subchars, restricted );
#T         if poss = [] then return []; fi;
#T         numbofposs[i]:= Length( poss );
#T         param:= Parametrized( poss );
#T         if param <> restricted then  # improvement found
#T           UpdateMap( chars[i], fus, param );
#T           lastimproved:= i;
#T       
#T       # call of TestConsistencyMaps ? ( with respect to improved classes )
#T     
#T           indeterminateness[i]:= Indeterminateness(
#T                                         CompositionMaps( chars[i], fus ) );
#T         fi;
#T       else
#T         numbofposs[i]:= "infinity";
#T         if ForAny( chars[i], x -> IsCyc(x) and not IsRat(x) ) then
#T     
#T           # maybe the indeterminateness of the rationalized
#T           # character is smaller but not 1
#T           rat:= RationalizedMat( [ chars[i] ] )[1];
#T           AddSet( chars, rat );
#T         fi;
#T       fi;
#T       i:= i + 1;
#T     od;
#T     
#T     # step 2: (local function 'improvefusion')
#T     #         loop over chars until no improvement is possible without a
#T     #         branch; update 'indeterminateness' and 'numbofposs';
#T     #         first character to test is at position 'first'; at least run
#T     #         up to character $'lastimproved' - 1$; update 'lastimproved' if
#T     #         an improvement occurs;
#T     #         return 'false' in the case of an inconsistency, 'true'
#T     #         otherwise.
#T 
#T     #         Note:
#T     #         'subtbl', 'subchars' and 'maxlen' are global
#T     #         variables for this function, also (but not necessary) global are
#T     #         'restricted', 'indet' and 'param'.
#T     
#T     improvefusion:=
#T          function(chars,fus,first,lastimproved,indeterminateness,numbofposs)
#T     local i, poss;
#T     i:= first;
#T     while i <> lastimproved do
#T       if indeterminateness[i] <> 1 then
#T         restricted:= CompositionMaps( chars[i], fus );
#T         indet:= Indeterminateness( restricted );
#T         if indet < indeterminateness[i] then
#T     
#T           # only test those characters which now have smaller
#T           # indeterminateness
#T           indeterminateness[i]:= indet;
#T           if indet = 1 then
#T             if not quick and
#T                not NonnegIntScalarProducts(subtbl,subchars,restricted) then
#T               return false;
#T             fi;
#T           elif indet < minamb then
#T             indeterminateness[i]:= 1;
#T           elif indet <= maxamb then
#T             poss:= contained( subtbl, subchars, restricted );
#T             if poss = [] then return false; fi;
#T             numbofposs[i]:= Length( poss );
#T             param:= Parametrized( poss );
#T             if param <> restricted then
#T 
#T               # improvement found
#T               UpdateMap( chars[i], fus, param );
#T               lastimproved:= i;
#T       
#T #T call of TestConsistencyMaps ? ( with respect to improved classes )
#T #T (only for locally valid power maps!!)
#T     
#T               indeterminateness[i]:= Indeterminateness(
#T                                         CompositionMaps( chars[i], fus ) );
#T             fi;
#T           fi;
#T         fi;
#T       fi;
#T       if lastimproved = 0 then lastimproved:= i; fi;
#T       i:= i mod Length( chars ) + 1;
#T     od;
#T     return true;
#T     end;
#T     
#T     # step 3: recursion; (local function 'allowedfusions')
#T     #         a) delete all characters which now have indeterminateness 1;
#T     #            their restrictions (with respect to every fusion that will be
#T     #            found ) have nonnegative scalar products with <subchars>.
#T     #         b) branch according to a significant character or class
#T     #         c) for each possibility call 'improvefusion' and then the
#T     #            recursion
#T     
#T     allowedfusions:= function( subpowermap, powermap, chars, fus,
#T                                indeterminateness, numbofposs )
#T     local i, j, class, possibilities, poss, newfus, newpow, newsubpow,
#T           newindet, newnumbofposs;
#T     remain:= Filtered( [ 1..Length( chars ) ], i->indeterminateness[i] > 1 );
#T     chars:=             chars{ remain };
#T     indeterminateness:= indeterminateness{ remain };
#T     numbofposs:=        numbofposs{ remain };
#T 
#T     if chars = [] then
#T       Info( InfoCharacterTable, 2,
#T             "FusionsAllowedByRestrictions: no character with",
#T             " indeterminateness\n#I    between ", minamb, " and ",
#T             maxamb, " significant now" );
#T       return [ fus ];
#T     fi;
#T     possibilities:= [];
#T     if Minimum( numbofposs ) < maxlen then
#T     
#T       # branch according to a significant character
#T       # with minimal number of possible restrictions
#T       i:= Position( numbofposs, Minimum( numbofposs ) );
#T       Info( InfoCharacterTable, 2,
#T             "FusionsAllowedByRestrictions: branch at character\n",
#T             "#I     ", CharacterString( chars[i], "" ),
#T             " (", numbofposs[i], " calls)" );
#T       poss:= contained( subtbl, subchars,
#T                         CompositionMaps( chars[i], fus ) );
#T       for j in poss do
#T         newfus:= List( fus, ShallowCopy );
#T         newpow:= DeepCopy( powermap );
#T #T really?
#T         newsubpow:= DeepCopy( subpowermap );
#T #T really?
#T         UpdateMap( chars[i], newfus, j );
#T         if TestConsistencyMaps( newsubpow, newfus, newpow ) then
#T           newindet:= ShallowCopy( indeterminateness );
#T           newnumbofposs:= ShallowCopy( numbofposs );
#T           if improvefusion(chars,newfus,i,0,newindet,newnumbofposs) then
#T             Append( possibilities,
#T                     allowedfusions( newsubpow, newpow, chars,
#T                                     newfus, newindet, newnumbofposs ) );
#T           fi;
#T         fi;
#T       od;
#T     
#T       Info( InfoCharacterTable, 2,
#T             "FusionsAllowedByRestrictions: return from branch at",
#T             " character\n",
#T             "#I     ", CharacterString( chars[i], "" ),
#T             " (", numbofposs[i], " calls)" );
#T     
#T     else
#T     
#T       # branch according to a significant class in a
#T       # character with minimal nontrivial indet.
#T       i:= Position( indeterminateness, Minimum( indeterminateness ) );
#T       restricted:= CompositionMaps( chars[i], fus );
#T       class:= 1;
#T       while not IsList( restricted[ class ] ) do class:= class + 1; od;
#T       Info( InfoCharacterTable, 2,
#T             "#I FusionsAllowedByRestrictions: branch at class ",
#T             class, "\n#I     (", Length( fus[ class ] ),
#T             " calls)" );
#T       for j in fus[ class ] do
#T         newfus:= List( fus, ShallowCopy );
#T         newfus[ class ]:= j;
#T         newpow:= DeepCopy( powermap );
#T #T really?
#T         newsubpow:= DeepCopy( subpowermap );
#T #T really?
#T         if TestConsistencyMaps( subpowermap, newfus, tbl.powermap ) then
#T           newindet:= ShallowCopy( indeterminateness );
#T           newnumbofposs:= ShallowCopy( numbofposs );
#T           if improvefusion(chars,newfus,i,0,newindet,newnumbofposs) then
#T             Append( possibilities,
#T                     allowedfusions( newsubpow, newpow, chars,
#T                                     newfus, newindet, newnumbofposs ) );
#T           fi;
#T         fi;
#T       od;
#T       Info( InfoCharacterTable, 2,
#T             "FusionsAllowedByRestrictions: return from branch at",
#T             " class ", class, "\n" );
#T     fi;
#T     return possibilities;
#T     end;
#T     
#T     # begin of the recursion:
#T     if lastimproved <> 0 then
#T       if not improvefusion( chars, fus, 1, lastimproved, indeterminateness,
#T                             numbofposs ) then
#T         return [];
#T       fi;
#T     fi;
#T     return allowedfusions( subtbl.powermap, tbl.powermap, chars, fus,
#T                            indeterminateness, numbofposs );
#T end;
#T 
#T 
#T #############################################################################
#T ##
#T #F  PossibleClassFusions( <subtbl>, <tbl> )
#T #F  PossibleClassFusions( <subtbl>, <tbl>, <parameters )
#T ##
#T ##  returns the list of all subgroup fusion maps from <subtbl> into <tbl>.
#T ##  
#T ##  The optional record <parameters> may have the following fields\:
#T ##  
#T ##  'chars':\\
#T ##       a list of characters of <tbl> which will be restricted to <subtbl>,
#T ##       (see "FusionsAllowedByRestrictions");
#T ##       the default is '<tbl>.irreducibles'
#T ##  
#T ##  'subchars':\\
#T ##       a list of characters of <subtbl> which are constituents of the
#T ##       retrictions of 'chars', the default is '<subtbl>.irreducibles'
#T ##  
#T ##  'fusionmap':\\
#T ##       a (parametrized) map which is an approximation of the desired map
#T ##  
#T ##  'decompose':\\
#T ##       a boolean; if 'true', the restrictions of 'chars' must have all
#T ##       constituents in 'subchars', that will be used in the algorithm;
#T ##       if 'subchars' is not bound and '<subtbl>.irreducibles' is complete,
#T ##       the default value of 'decompose' is 'true', otherwise 'false'
#T ##  
#T ##  'permchar':\\
#T ##       a permutaion character; only those fusions are computed which
#T ##       afford that permutation character
#T ##  
#T ##  'quick':\\
#T ##       a boolean; if 'true', the subroutines are called with the option
#T ##       '\"quick\"'; especially, a unique map will be returned immediately
#T ##       without checking all symmetrisations; the default value is 'false'
#T ##  
#T ##  'parameters':\\
#T ##       a record with fields 'maxamb', 'minamb' and 'maxlen' which control
#T ##       the subroutine 'FusionsAllowedByRestrictions'\:
#T ##       It only uses characters with actual indeterminateness up to
#T ##       'maxamb', tests decomposability only for characters with actual
#T ##       indeterminateness at least 'minamb' and admits a branch only
#T ##       according to a character if there is one with at most 'maxlen'
#T ##       possible restrictions.
#T ##
InstallOtherMethod( PossibleClassFusions,
    "method for two ordinary character tables",
    IsIdentical,
    [ IsOrdinaryTable, IsOrdinaryTable ], 0,
    function( subtbl, tbl )
    return PossibleClassFusions( subtbl, tbl,
               rec( 
                    quick      := false,
                    parameters := rec(
                                       approxfus:= [],
                                       maxamb:= 200000,
                                       minamb:= 10000,
                                       maxlen:= 10
                                                        ) ) );
         end );

#T InstallMethod( PossibleClassFusions,
#T     "method for two ordinary character tables, and a parameters record",
#T     true,
#T     [ IsOrdinaryTable, IsOrdinaryTable, IsRecord ], 0,
#T     function( subtbl, tbl, parameters )
#T 
#T ...
#T SubgroupFusions := function( arg )
#T 
#T #T support option 'no branch' ??
#T 
#T     local x, i, subtbl, tbl, subchars, chars, fus, maxamb, minamb,
#T           maxlen, poss, subgroupfusions, imp, subtaut, taut, quick,
#T           decompose, approxfus, fusval, approxval, permchar, grp, flag;
#T 
#T     # available characters of 'subtbl'
#T     if IsBound( parameters.subchars ) then
#T       subchars:= parameters.subchars;
#T       decompose:= false;
#T     elif HasIrr( subtbl ) then
#T       subchars:= Irr( subtbl );
#T       decompose:= true;
#T #T possibility to have subchars and an incomplete tables ???
#T     else
#T       subchars:= [];
#T       decompose:= false;
#T     fi;
#T 
#T     # available characters of 'tbl'
#T     if IsBound( parameters.chars ) then
#T       chars:= parameters.chars;
#T     elif HasIrr( tbl ) then
#T       chars:= Irr( tbl );
#T     else
#T       chars:= [];
#T     fi;
#T 
#T     # parameter 'quick'
#T     quick:= IsBound( parameters.quick ) and parameters.quick = true;
#T 
#T     # is 'decompose' explicitly allowed or forbidden?
#T     if IsBound( parameters.decompose ) then
#T       decompose:= parameters.decompose = true;
#T     fi;
#T 
#T     if IsBound( parameters.parameters ) and IsRecord( parameters.parameters ) then
#T       maxamb:= parameters.parameters.maxamb;
#T       minamb:= parameters.parameters.minamb;
#T       maxlen:= parameters.parameters.maxlen;
#T     else
#T       maxamb:= 200000;
#T       minamb:= 10000;
#T       maxlen:= 10;
#T     fi;
#T 
#T     if IsBound( parameters.fusionmap ) then
#T       approxfus:= parameters.fusionmap;
#T     else
#T       approxfus:= [];
#T     fi;
#T 
#T     if IsBound( parameters.permchar ) then
#T       permchar:= parameters.permchar;
#T       if Length( permchar ) <> NrConjugacyClasses( tbl ) then
#T         Error( "length of <permchar> must be the no. of classes of <tbl>" );
#T       fi;
#T     else
#T       permchar:= [];
#T     fi;
#T     # (end of the inspection of the parameters)
#T 
#T     # initialize the fusion
#T     fus:= InitFusion( subtbl, tbl );
#T     if fus = fail then 
#T       Info( InfoCharacterTable, 2,
#T             "SubgroupFusions: no initialisation possible" );
#T       return [];
#T     fi;
#T     Info( InfoCharacterTable, 2,
#T           "PossibleClassFusions: fusion initialized" );
#T     
#T     # use 'approxfus'\:
#T     flag:= MeetMaps( fus, approxfus );
#T     if flag <> true then
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: possible maps not compatible with ",
#T             "<approxfus> at class ", flag );
#T       return [];
#T     fi;
#T 
#T     # use the permutation character for the first time
#T     if not IsEmpty( permchar ) then
#T       if not CheckPermChar( subtbl, tbl, fus, permchar ) then
#T         Info( InfoCharacterTable, 2,
#T               "PossibleClassFusions: inconsistency of fusion and permchar" );
#T         return [];
#T       fi;
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: permutation character checked");
#T     fi;
#T 
#T     # check consistency of fusion and powermaps
#T     if not TestConsistencyMaps( subtbl.powermap, fus, tbl.powermap ) then
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: inconsistency of fusion and power maps" );
#T       return [];
#T     fi;
#T     Info( InfoCharacterTable, 2,
#T           "PossibleClassFusions: consistency with power maps",
#T           " checked,\n#I    the actual indeterminateness is ",
#T           Indeterminateness( fus ) );
#T 
#T     # may we return?
#T     if quick and ForAll( fus, IsInt ) then return [ fus ]; fi;
#T     
#T     # consider table automorphisms of the supergroup:
#T     if   HasAutomorphismsOfTable( tbl ) then
#T       taut:= AutomorphismsOfTable( tbl );
#T #T     elif IsBound( tbl.galomorphisms ) then
#T #T       taut:= tbl.galomorphisms;
#T     else
#T       taut:= false;
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: no table automorphisms stored" );
#T     fi;
#T 
#T     if taut <> false then
#T       imp:= ConsiderTableAutomorphisms( fus, taut );
#T       if 2 <= InfoLevel( InfoCharacterTable ) then
#T         Print( "#I PossibleClassFusions: table automorphisms checked, " );
#T         if imp = [] then
#T           Print( "no improvements\n" );
#T         else
#T           Print( "improvements at classes\n#I   ", imp, "\n" );
#T           if not TestConsistencyMaps( ComputedPowerMaps( subtbl ),
#T                                       fus,
#T                                       ComputedPowerMaps( tbl ),
#T                                       imp ) then
#T             Info( InfoCharacterTable, 2,
#T                   "PossibleClassFusions: inconsistency of",
#T                   " powermaps and fusion map" );
#T             return [];
#T           fi;
#T           Info( InfoCharacterTable, 2,
#T                 "PossibleClassFusions: consistency with power maps ",
#T                 "checked again,\n",
#T                 "#I    the actual indeterminateness is ",
#T                 Indeterminateness( fus ) );
#T         fi;
#T       fi;
#T     fi;
#T 
#T     # use the permutation character for the second time
#T     if permchar <> [] then
#T       if not CheckPermChar( subtbl, tbl, fus, permchar ) then
#T         Info( InfoCharacterTable, 2,
#T               "PossibleClassFusions: inconsistency of fusion and permchar" );
#T         return [];
#T       fi;
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: permutation character checked again");
#T     fi;
#T     
#T     if quick and ForAll( fus, IsInt ) then return [ fus ]; fi;
#T     
#T     # now use restricted characters:
#T     # If the parameter \"decompose\" was entered, use decompositions of
#T     # indirections of <chars> into <subchars>;
#T     # otherwise only check the scalar products with <subchars>.
#T     
#T     if decompose then                      # usage of decompositions allowed
#T       if Indeterminateness( fus ) < minamb then
#T         Info( InfoCharacterTable, 2,
#T               "PossibleClassFusions: indeterminateness too small",
#T               " for test of decomposability" );
#T         poss:= [ fus ];
#T       else
#T         Info( InfoCharacterTable, 2,
#T               "#I PossibleClassFusions: now test decomposability of",
#T               " rational restrictions" );
#T         poss:= FusionsAllowedByRestrictions( subtbl, tbl,
#T                       RationalizedMat( subchars ),
#T                       RationalizedMat( chars ), fus,
#T                       rec( maxlen:= maxlen,
#T                            contained:= ContainedCharacters,
#T                            minamb:= minamb,
#T                            maxamb:= "infinity",
#T                            quick:= quick ) );
#T 
#T         poss:= Filtered( poss, x ->
#T                   TestConsistencyMaps( subtbl.powermap, x, tbl.powermap ) );
#T 
#T         # use the permutation character for the third time
#T         if permchar <> [] then
#T           poss:= Filtered( poss, x -> CheckPermChar(subtbl,tbl,x,permchar) );
#T         fi;
#T     
#T         if 2 <= InfoLevel( InfoCharacterTable ) then
#T           Print( "#I PossibleClassFusions: decomposability tested,\n" );
#T           if Length( poss ) = 1 then
#T             Print( "#I    1 solution with indeterminateness ",
#T                    Indeterminateness( poss[1] ), "\n" );
#T           else
#T             Print( "#I    ", Length( poss ),
#T                    " solutions with indeterminateness\n#I    ",
#T                     List( poss, Indeterminateness ), "\n" );
#T           fi;
#T         fi;
#T       fi;
#T 
#T     else
#T       Info( InfoCharacterTable, 2,
#T             "PossibleClassFusions: no test of decomposability" );
#T       poss:= [ fus ];
#T     fi;
#T     
#T     Info( InfoCharacterTable, 2,
#T           "PossibleClassFusions: test scalar products of restrictions" );
#T     
#T     subgroupfusions:= [];
#T     for fus in poss do
#T       Append( subgroupfusions,
#T               FusionsAllowedByRestrictions( subtbl, tbl, subchars, chars,
#T                         fus, rec( maxlen:= maxlen,
#T                                   contained:= ContainedPossibleCharacters,
#T                                   minamb:= 1,
#T                                   maxamb:= maxamb,
#T                                   quick:= quick ) ) );
#T     od;
#T 
#T     #  make orbits under the admissible subgroup of 'tbl.automorphisms'
#T     #  to get the whole set of all subgroup fusions;
#T     #  admissible means\:\  If there was an approximation 'fusionmap' in
#T     #  the argument record, this map must be respected; if the permutation
#T     #  character 'permchar' was entered, it must be respected, too.
#T 
#T     if taut <> false then
#T       if permchar = [] then
#T         grp:= taut;
#T       else
#T 
#T         # use the permutation character for the fourth time
#T         grp:= taut.operations.SubgroupProperty(
#T                    taut, x->ForAll([1..Length(permchar)],
#T                                           y->permchar[y]=permchar[y^x]) );
#T       fi;
#T       subgroupfusions:= Set( Concatenation( List( subgroupfusions,
#T                                 x->OrbitFusions( Group(()), x, grp ) ) ) );
#T     fi;
#T 
#T     if approxfus <> [] then
#T       subgroupfusions:= Filtered( subgroupfusions,
#T           x -> ForAll( [ 1 .. Length( approxfus ) ],
#T                  y -> not IsBound( approxfus[y] )
#T                        or ( IsInt(approxfus[y]) and x[y] =  approxfus[y] )
#T                        or ( IsList(approxfus[y]) and IsInt( x[y] )
#T                             and x[y] in approxfus[y] )
#T                        or ( IsList(approxfus[y]) and IsList( x[y] )
#T                             and Difference( x[y], approxfus[y] ) = [] )));
#T     fi;
#T 
#T     if 2 <= InfoLevel( InfoCharacterTable ) then
#T 
#T       # if possible make orbits under the groups of table automorphisms
#T       if ForAll( subgroupfusions, x -> ForAll( x, IsInt ) ) then
#T 
#T         if   IsBound( subtbl.automorphisms ) then
#T           subtaut:= subtbl.automorphisms;
#T         elif IsBound( subtbl.galomorphisms ) then
#T           subtaut:= subtbl.galomorphisms;
#T         else
#T           subtaut:= Group( () );
#T         fi;
#T         if   IsBound( tbl.automorphisms ) then
#T           taut:= tbl.automorphisms;
#T         elif IsBound( tbl.galomorphisms ) then
#T           taut:= tbl.galomorphisms;
#T         else
#T           taut:= Group( () );
#T         fi;
#T         RepresentativesFusions( subtaut, subgroupfusions, taut );
#T 
#T       fi;
#T 
#T       # print the messages
#T       if ForAny( subgroupfusions, x -> ForAny( x, IsList ) ) then
#T         Print( "#I PossibleClassFusions: ", Length( subgroupfusions ),
#T                " parametrized solution" );
#T         if Length( subgroupfusions ) = 1 then
#T           Print( ",\n" );
#T         else
#T           Print( "s,\n" );
#T         fi;
#T         Print( "#I    no further improvement was possible with",
#T                " given characters\n",
#T                "#I    and maximal checked ambiguity of ", maxamb, "\n" );
#T       else
#T         Print( "#I PossibleClassFusions: ", Length( subgroupfusions ),
#T                " solution" );
#T         if Length( subgroupfusions ) = 1 then
#T           Print( "\n" );
#T         else
#T           Print( "s\n" );
#T         fi;
#T       fi;
#T 
#T     fi;
#T     return subgroupfusions;
#T     end );


#############################################################################
##
#E  ctblmaps.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



