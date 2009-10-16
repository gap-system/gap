#############################################################################
##
#W  gentuple.gi            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: gentuple.gi,v 1.2 2001/09/21 16:16:31 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some functions dealing with questions of generation
##  of class structures.
##
Revision.( "genus/gap/gentuple_gi" ) :=
    "@(#)$Id: gentuple.gi,v 1.2 2001/09/21 16:16:31 gap Exp $";


#############################################################################
##
#F  CardinalityOfHomToSubgroup( <tbl>, <subtbl>, <g0>, <tuple> )
##
InstallGlobalFunction( CardinalityOfHomToSubgroup,
    function( tbl, subtbl, g0, tuple )

    local r,             # length of `tuple'
          fus,           # fusion map from `max' to `tbl'
          fuslen,        # length of `fus'
          preimages,     # list of class structures fusing into `tuple'
          i, j,          # loop variables
          sum,           # sum of homomorphisms, result
          bounds,
          counter,
          subtuple,
          pos;

    # Get the class structures of the subgroup that fuse into `tuple'.
    r:= Length( tuple );
    fus:= GetFusionMap( subtbl, tbl );
    fuslen:= Length( fus );
    preimages:= [];
    for i in [ 1 .. r ] do
      preimages[i]:= [];
    od;
    for i in [ 1 .. fuslen ] do
      for j in [ 1 .. r ] do
        if fus[i] = tuple[j] then
          Add( preimages[j], i );
        fi;
      od;
    od;

    # Sum up the numbers of homomorphisms into the subgroup.
    bounds:= List( preimages, Length );
    if 0 in bounds then
      return 0;
    fi;

    counter:= List( preimages, x -> 1 );
    subtuple:= List( preimages, x -> x[1] );
    pos:= 1;
    counter[ pos ]:= 0;

    sum:= 0;

    repeat
      counter[ pos ]:= counter[ pos ] + 1;
      subtuple[ pos ]:= preimages[ pos ][ counter[ pos ] ];
      sum:= sum + CardinalityOfHom( subtuple, g0, subtbl );
      pos:= 1;
      while pos <= r and counter[ pos ] = bounds[ pos ] do
        counter[ pos ]:= 1;
        subtuple[ pos ]:= preimages[ pos ][1];
        pos:= pos + 1;
      od;
    until r < pos;

    # Return the result.
    return sum;
end );


InstallGlobalFunction( NongenerationByEichlerCriterion,
    function( tbl, tuple )
    local chi, mat;
    chi:= EichlerCharacter( tbl, 0, tuple );
    mat:= MatScalarProducts( tbl, Irr( tbl ), [ chi ] )[1];
    return ForAny( mat, x -> not IsInt( x ) or x < 0 );
end );


#############################################################################
##
#F  IsGeneratingTuple( <tbl>, <g0>, <tuple>, <maxesdata>, <super> )
##
InstallGlobalFunction( IsGeneratingTuple,
    function( tbl, g0, tuple, maxesdata, super )

    local card,
          sizecen,
          supertbl,
          fus,
          supertuple,
          sum,
          allzero,
          cardlowerbound,
          i,
          pos,
          pi;

    # Check the centralizer criterion
    card:= CardinalityOfHom( tuple, g0, tbl );
    sizecen:= Length( ClassPositionsOfCentre( tbl ) );
    if card < Size( tbl ) / sizecen then
#T better bound for g0 > 0 ?
      Info( InfoGenTuple, 1,
            "structure constant rules out ", tuple );
      return false;
    fi;

    # Check some criteria that work only for `<g0> = 0'.
    if g0 = 0 then

      # In the case of `<g0> = 0', apply Scott's trick.
      if NongenerationByScottCriterion( tbl, tuple ) then
        Info( InfoGenTuple, 1,
#T            "Scott (degree ", chi[1], ") rules out ", tuple );
              "Scott (degree ??) rules out ", tuple );
        return false;
      fi;
      if NongenerationByEichlerCriterion( tbl, tuple ) then
        Print( "case where Eichler's criterion strikes!\n" );
#T is this useful at all?
      fi;

      # In the case of `<g0> = 0', use the tables of supergroups.
      for supertbl in super do
        fus:= FusionConjugacyClasses( tbl, supertbl );
        if IsList( fus ) then
          supertuple:= fus{ tuple };
          if CardinalityOfHom( supertuple, 0, supertbl )
              < Size( supertbl ) / sizecen then
            Info( InfoGenTuple, 1,
                  "supergroup ", supertbl, " rules out ", tuple );
            return false;
          fi;
        else
          Info( InfoGenTuple, 1,
                "fusion ", tbl, " -> ", supertbl,
                " not uniquely determined" );
        fi;
      od;

    fi;

    # From here on, use the information about maximal subgroups.
    allzero:= true;
    cardlowerbound:= card;

    # Rule out those tuples for which a single maximal subgroup
    # contains too many tuples!
    for i in [ 1 .. Length( maxesdata ) ] do

      if maxesdata[i] = false then

        # We have no information about at least one maximal subgroup.
        # So we cannot prove that the vector generates,
        # but nongeneration may be proved using another maximal subgroup.
        allzero:= false;
        cardlowerbound:= 0;

      elif IsList( maxesdata[i] ) then

        # We know the permutation character of the `i'-th maximal subgroup.
        # If it is nonzero on all classes of the vector then
        # the corresponding maximal subgroup may contain some of the tuples;
        # however, we cannot count how many there are, so the proof of
        # generation becomes impossible in this case.
        if ForAll( tuple, k -> maxesdata[i][k] <> 0 ) then
          allzero:= false;
          cardlowerbound:= 0;
        fi;

      else

        # We know the character table of the `i'-th maximal subgroup.
        fus:= FusionConjugacyClasses( maxesdata[i], tbl );
        if fus = fail then

          # We have no information about the `i'-th maximal subgroup.
          Info( InfoGenTuple, 1,
                "fusion ", maxesdata[i], " -> ", tbl,
                " not uniquely determined" );
          allzero:= false;
          cardlowerbound:= 0;

        elif ForAll( tuple, k -> k in fus ) then

          # The maximal subgroup may contain relevant tuples.
          allzero:= false;

          # First we check whether this maximal subgroup contains enough
          # relevant tuples to prove nongeneration.
#T does this work  also for g0 > 0 ?
#T (if yes then generalize `NongenerationBySingleSubgroup' !)
          if g0 = 0 then
            if NongenerationBySingleSubgroup( tbl, maxesdata[i], tuple ) then
#T   if card < CardinalityOfHomToSubgroup( tbl, maxesdata[i], 0, tuple ) then
#T compute the cardinality again and again ...
              Info( InfoGenTuple, 1,
                    Ordinal( i ),
                    " max. subgroup rules out ", tuple );
              return false;
            fi;
          fi;

          # Next we update the lower bound
          # (hoping for a positive value in the end, that is, generation).
          if 0 < cardlowerbound then
            if IsClassFusionOfNormalSubgroup( maxesdata[i], fus, tbl ) then
              cardlowerbound:= cardlowerbound
                  - CardinalityOfHomToSubgroup( tbl, maxesdata[i], g0, tuple );
            else
              cardlowerbound:= cardlowerbound
                  - CardinalityOfHomToSubgroup( tbl, maxesdata[i], g0, tuple )
                  * Size( tbl ) / Size( maxesdata[i] );
            fi;
          fi;

        fi;

      fi;

    od;

    # Let us see whether we have proved generation,
    # that is, whether we have inspected all relevant tables of
    # maximal subgroups,
    # and whether the sum of the numbers of tuples lying
    # in maximal subgroups is smaller than the number of tuples for
    # the whole group.
    if allzero then

      # No maximal subgroup contains elements in all classes of `tuple'.
      # So we proved generation.
      Info( InfoGenTuple, 1,
            "perm. characters prove ", tuple );
      return true;

    elif 0 < cardlowerbound then

      # The maximal subgroups do not contain all relevant vectors.
      # So again we proved generation.
      Info( InfoGenTuple, 1,
            "maximal subgroups prove ", tuple );
      return true;

    fi;

    # No decision was possible.
    Info( InfoGenTuple, 1,
          "no decision for ", tuple );
    return fail;
end );


InstallGlobalFunction( ApplyShiftLemma, function( tbl, info )

    local orders,
          powermap,
          tuple,
          other,
          img,
          classes,
          inv,
          s, q,
          test,
          root,
          t, i,
          ttest;

    # This works only for simple groups.
    if not IsSimple( tbl ) then
      return;
    fi;

    # If $G$ is $(2,s,t)$-generated and simple then
    # $G$ is also $(s,s,q)$-generated where the class
    # of elements of order $q$ consists of the squares of the
    # elements in class $t$.
    orders:= OrdersClassRepresentatives( tbl );
    powermap:= PowerMap( tbl, 2 );
    for tuple in info.necessary do
      if Length( tuple ) = 3 and 2 in orders{ tuple } then
        other:= Filtered( tuple, x -> orders[x] <> 2 );
        img:= [ other[1], other[1], powermap[ other[2] ] ];
        Sort( img );
        if not img in info.possible then
Print( "#E  Error for ", tuple, " (case 1)\n" );
        elif not img in info.necessary then
Print( "proved ", img, " (case 1)\n" );
        fi;
        img:= [ other[2], other[2], powermap[ other[1] ] ];
        Sort( img );
        if not img in info.possible then
Print( "#E  Error for ", tuple, " (case 2)\n" );
        elif not img in info.necessary then
Print( "proved ", img, " (case 2)\n" );
        fi;
      fi;
    od;

    # Check reverse direction for all triples $(s,s,q)$ that are *not*
    # in `info.possible'.
    classes:= SizesConjugacyClasses( tbl );
    inv:= Filtered( [ 2 .. Length( orders ) ], i -> orders[i] = 2 );
    for s in [ 2 .. Length( classes ) ] do
      for q in [ 2 .. Length( classes ) ] do
        test:= [ s, s, q ];
        Sort( test );
        if not test in info.possible then
          root:= Filtered( [ 2 .. Length( orders ) ],
                           i -> powermap[i] = q );
          for i in inv do
            for t in root do
              ttest:= [ i, s, t ];
              Sort( ttest );
              if ttest in info.necessary then
Print( "#E  Error for ", ttest, " (case 3)\n" );
              elif ttest in info.possible then
Print( "excluded ", ttest, "\n" );
              fi;
            od;
          od;

        fi;
      od;
    od;
end );


#############################################################################
##
#F  GeneratingTuplesInfo( <tbl>, <r>, <primitives>, <super> )
##
InstallGlobalFunction( GeneratingTuplesInfo,
    function( tbl, r, primitives, super )

    local maxes,      # info about maximal subgroups, optional third argument
          permchars,  # permutation characters of `maxes'
          fusion,     # fusion of a maximal subgroup
          tuples,     # list of `r'-tuples, result
          n,          # number of classes
          tuple,      # `r'-tuple (counter to loop over them)
          pos,        # position between 1 and `r'
          value,      # new counter value
          i,          # loop variable
          found,      # shallow copy of found `r'-tuple
          info;

    # Check the arguments.
    maxes := ShallowCopy( primitives );

    # Get the permutation characters resp. the tables of maximal subgroups.
    permchars:= [];
    if maxes <> false then

      for i in [ 1 .. Length( maxes ) ] do

        if IsString( maxes[i] ) then
          maxes[i]:= CharacterTable( maxes[i] );
          if maxes[i] = fail then
            Error( maxes[i], " is not an admissible library table name" );
          fi;
        fi;

        if IsRowVector( maxes[i] ) or IsClassFunction( maxes[i] ) then
          permchars[i]:= maxes[i];
          maxes[i]:= fail;
        elif IsCharacterTable( maxes[i] ) then
          fusion:= GetFusionMap( maxes[i], tbl );
          if fusion = fail then
            Error( "no fusion map from ", maxes[i], " into ", tbl );
          fi;
          permchars[i]:= Induced( maxes[i], tbl,
                                  [ TrivialCharacter( maxes[i] ) ],
                                  fusion )[1];
        else
          Error( Ordinal( i ), " position in <maxes> is not valid" );
        fi;
      od;

    fi;

    # Loop over the unordered `r'-tuples.
    tuples:= rec( possible  := [],
                  necessary := [],
                  complete  := true );
    n:= NrConjugacyClasses( tbl );

    tuple:= List( [ 1 .. r ], i -> 2 );
    tuple[r]:= 1;

#T use normal subgroups, at least two of the periods must lie
#T outside each normal subgroup!
#T (saves a lot of work for M12:2 ...)
#T (Note that in a single test, Scott's criterion rules out the
#T superfluous tuples; but we need not construct them at all ...)
    while true do

      # Increase the counter `tuple'.
      pos:= r;
      while 1 <= pos and tuple[ pos ] = n do
        pos:= pos - 1;
      od;
      if pos = 0 then
ApplyShiftLemma( tbl, tuples );
        return tuples;
      fi;
      value:= tuple[ pos ] + 1;
      for i in [ pos .. r ] do
        tuple[i]:= value;
      od;

      # Check the `r'-tuple.
      info:= IsGeneratingTuple( tbl, 0, tuple, maxes, super );
      if info <> false then
        found:= ShallowCopy( tuple );
        Add( tuples.possible, found );
        if info = true then
          Add( tuples.necessary, found );
        fi;
      fi;

    od;
end );


#############################################################################
##
#F  IsGeneratingTriple( <grp>, <classlist>, <triple> )
##
InstallGlobalFunction( IsGeneratingTriple, function( grp, classlist, triple )

    local g, h, prod;

    if Size( classlist[ triple[1] ] ) < Size( classlist[ triple[2] ] ) then
      h:= Representative( classlist[ triple[2] ] );
      for g in Elements( classlist[ triple[1] ] ) do
        prod:= g * h;
        if     prod in classlist[ triple[3] ]
           and Size( Subgroup( grp, [ g, h ] ) ) = Size( grp ) then
          return true;
        fi;
      od;
    else
      h:= Representative( classlist[ triple[1] ] );
      for g in Elements( classlist[ triple[2] ] ) do
        prod:= h * g;
        if     prod in classlist[ triple[3] ]
           and Size( Subgroup( grp, [ g, h ] ) ) = Size( grp ) then
          return true;
        fi;
      od;
    fi;
    return false;
end );


#############################################################################
##
#F  GeneratingTriples( <classlist> )
##
InstallGlobalFunction( GeneratingTriples, function( classlist )

    local grp,
          n,
          inv,
          check,
          triples,
          i, j, k;

    grp:= classlist[1].group;

    # Compute the inverse of each class.

    n:= Length( classlist );
    inv:= [];
    for i in [ 1 .. Length( classlist ) ] do
      if not IsBound( inv[i] ) then
        j:= i;
        k:= Representative( classlist[i] )^-1;
        while not k in classlist[j] do
          j:= j+1;
        od;
        inv[i]:= j;
        inv[j]:= i;
      fi;
    od;

    # Define the function that checks a triple.
    check:= function( triple )
    if IsGeneratingTriple( grp, classlist, triple ) then
      Add( triples, triple );
    fi;
    end;

    # Loop over the triples.
    triples:= [];

    for i in [ 1 .. n ] do
      for j in [ i .. n ] do
        for k in [ j .. n ] do

          # Check the triple `[ i, j, k ]'.
          check( [ i, j, k ] );

          # If necessary check the triples
          # `[ inv[i], j, inv[k] ]' and `[ inv[i], j, k ]'.
          if inv[i] = i then
            if inv[k] < j then
              check( [ i, j, inv[k] ] );
            fi;
          else
            if inv[i] > j then
              check( [ inv[i], j, k ] );
            fi;
            if ( inv[k] < j or inv[i] > j ) then
              check( [ inv[i], j, inv[k] ] );
            fi;
          fi;
            
        od;
      od;
    od;

    return triples;
    end );


#############################################################################
##
#F  RandomFindGeneration( <G>, <tbl>, <ijk>, <g_ig_j>, <n> )
##
#T compute probablility for finding generation ...
##
InstallGlobalFunction( RandomFindGeneration, function( G, tbl, ijk, gigj, n )

    local IsGoodElement,
          names,
          orders,
          i, j, k,
          classes,
          centralizers,
          c,
          gi, gj,
          elm,
          elmorderk,
          sameorderk,
          cenorderk,
          prob,
          class,
          foundelmord,
          foundsizes,
          pos,
          ord,
          siz,
          x,
          z,
          H,
          inv;

    # local function to identify the class an element is contained in
    IsGoodElement:= function( g, classpos )
      local ord;
      ord:= Order( g );
      if ord mod orders[ classpos ] <> 0 then
        return false;
      fi;
      g:= g ^ ( ord / orders[ classpos ] );
      if Size( Centralizer( G, g ) ) <> SizesCentralizers( tbl )[ classpos ] then
        return false;
      fi;
      # Here we *know* that element and centralizer order determine!
      return g;
    end;

    # Get the class positions.
    names:= ClassNames( tbl );
    orders:= OrdersClassRepresentatives( tbl );
#T improve for lists of positions for each class!
    i:= ijk[1]; if IsString( i ) then i:= Position( names, i ); fi;
    j:= ijk[2]; if IsString( j ) then j:= Position( names, j ); fi;
    k:= ijk[3];
    if IsString( k ) then
      k:= [ Position( names, k ) ];
    elif IsInt( k ) then
      k:= [ k ];
    elif IsList( k ) then
      k:= List( k, x -> Position( names, x ) );
    fi;

    # Get the elements of classes `i' and `j'.
    classes:= SizesConjugacyClasses( tbl );
    centralizers:= SizesCentralizers( tbl );
    if IsBound( gigj[1] ) then
      gi:= gigj[1];
    else
      InfoGenTuple( "#I  trying to compute element in class <i>\n" );
      if Number( [ 1 .. Length( classes ) ],
                 x -> orders[x] = orders[i] and
                      centralizers[x] = centralizers[i] ) > 1 then
        Error( "element of class <i> not determined by el. and cent. order" );
      fi;
      c:= 1;
      elm:= false;
      while c <= Length( G.generators ) and elm = false do
        elm:= IsGoodElement( G.generators[c], i );
        c:= c+1;
      od;
      c:= c-1;
      if elm = false then
        gi:= Random( G.generators );
        repeat
          gi:= gi * Random( G.generators );
          c:= c+1;
          elm:= IsGoodElement( gi, i );
        until elm <> false;
      fi;
      gi:= elm;
      InfoGenTuple( "#I  (", c, " tries were necessary)\n" );
    fi;
    if IsBound( gigj[2] ) then
      gj:= gigj[2];
    else
      InfoGenTuple( "#I  trying to compute element in class <j>\n" );
      if Number( [ 1 .. Length( classes ) ],
                 x -> orders[x] = orders[j] and
                      centralizers[x] = centralizers[j] ) > 1 then
        Error( "element of class <j> not determined by el. and cent. order" );
      fi;
      c:= 1;
      elm:= false;
      while c <= Length( G.generators ) and elm = false do
        elm:= IsGoodElement( G.generators[c], j );
        c:= c+1;
      od;
      c:= c-1;
      if elm = false then
        gj:= Random( G.generators );
        repeat
          gj:= gj * Random( G.generators );
          c:= c+1;
          elm:= IsGoodElement( gj, j );
        until elm <> false;
      fi;
      gj:= elm;
      InfoGenTuple( "#I  (", c, " tries were necessary)\n" );
    fi;

    # Set up the criteria of identification of class `k'.
    elmorderk:= Set( orders{k} );
    if Length( elmorderk ) = 1 then
      elmorderk:= elmorderk[1];
    else
      Error( "elements in classes <k> must have the same order" );
    fi;
    sameorderk:= Filtered( [ 1 .. Length( classes ) ],
                           x -> orders[x] = elmorderk );
    if sameorderk = k then
      # The class is identified by its element order.
      cenorderk:= false;
    else
      # More information is needed to identify the class(es).
      cenorderk:= Set( centralizers{k} );
      if Length( cenorderk ) = 1 then
        cenorderk:= cenorderk[1];
      else
        Error( "elements in classes <k> must have same centralizer order" );
      fi;
      if Number( sameorderk, x -> centralizers[x] = cenorderk )
         > Length( k ) then
        Error( "classes <k> not determined by el. and cent. orders" );
      fi;
    fi;

    # Compute the probability of finding `[ i, j, k ]'
    # (not necessarily generating).
    inv:= InverseClasses( tbl );
    prob:= 0;
    for class in k do
      prob:= prob
         + ClassMultiplicationCoefficient( tbl, i, j, inv[ class ] ) * classes[ class ];
    od;
    InfoGenTuple( "#I  probability of finding (", i, ",", j, ",", k, ") is ",
                   Int( ( prob * 100 / classes[i] ) / classes[j] ),
                   " %.\n" );

    # Initialize the statistics variables.
    foundelmord := [ [], [] ];
    foundsizes  := [ [], [] ];

    # Run the tests.
    # Conjugate the element with smallest centralizer among `[ gi, gj ]'
    # by a random element, and check for generation.
    for c in [ 1 .. n ] do

      x:= Random( G );
      if centralizers[i] < centralizers[j] then
  
        z:= gi^x * gj;
        ord:= Order( z );
        if ord = elmorderk then
          H:= Subgroup( G, [ z, gj ] );
          siz:= Size( H );
          if siz = Size( tbl ) and ( cenorderk = false
               or Size( Centralizer( G, z ) ) = cenorderk ) then
            InfoGenTuple( "#I  solution found in try no. ", c, "\n" );
            return [ gi^x, gj, z ];
          else
            pos:= Position( foundsizes[1], siz );
            if pos <> fail then
              foundsizes[2][ pos ]:= foundsizes[2][ pos ] + 1;
            else
              Add( foundsizes[1], siz );
              Add( foundsizes[2], 1 );
            fi;
          fi;
        else
          pos:= Position( foundelmord[1], ord );
          if pos <> fail then
            foundelmord[2][ pos ]:= foundelmord[2][ pos ] + 1;
          else
            Add( foundelmord[1], ord );
            Add( foundelmord[2], 1 );
          fi;
        fi;
  
      else
  
        z:= gi * gj^x;
        ord:= Order( z );
        if ord = elmorderk then
          H:= Subgroup( G, [ z, gi ] );
          siz:= Size( H );
          if siz = Size( tbl ) and ( cenorderk = false
               or Size( Centralizer( G, z ) ) = cenorderk ) then
            InfoGenTuple( "#I  solution found in try no. ", c, "\n" );
            return [ gi, gj^x, z ];
          else
            pos:= Position( foundsizes[1], siz );
            if pos <> fail then
              foundsizes[2][ pos ]:= foundsizes[2][ pos ] + 1;
            else
              Add( foundsizes[1], siz );
              Add( foundsizes[2], 1 );
            fi;
          fi;
        else
          pos:= Position( foundelmord[1], ord );
          if pos <> fail then
            foundelmord[2][ pos ]:= foundelmord[2][ pos ] + 1;
          else
            Add( foundelmord[1], ord );
            Add( foundelmord[2], 1 );
          fi;
        fi;
  
      fi;

    od;

    # No generation found after `n' tries.
    SortParallel( foundelmord[1], foundelmord[2] );
    SortParallel( foundsizes[1], foundsizes[2] );

    InfoGenTuple( "#I  no generation found after ", n, " tries,\n",
                   "#I  found other element orders of the product <i> with",
                   " <j>:\n",
                   "#I  ", foundelmord, "\n",
                   "#I  for correct element order found generated subgroups",
                   " of sizes\n",
                   "#I  ", foundsizes, "\n" );
    return fail;
end );


#############################################################################
##
#F  MonodromyGenus( <tbl>, <permchar>, <listoftuples> )
##
InstallGlobalFunction( MonodromyGenus,
    function( tbl, permchar, listoftuples )

    local n,    # degree of `permchar'
          nu;   # list of `n' minus orbit number

    n:= permchar[1];

    # For all classes, compute `n' minus the number of orbits.
    nu:= List( [ 1 .. Length( permchar ) ],
               i -> n - DimensionFixedSpace( tbl, permchar, i ) );
      
    # For each entry, compute the genus.
    return List( listoftuples, x -> 1 - n + Sum( nu{ x } ) / 2 );
end );


#############################################################################
##
#F  UpperBoundMonodromyGenus( <tbl>, <permchars>, <info> )
##
InstallGlobalFunction( UpperBoundMonodromyGenus,
    function( tbl, permchars, info )

    local min,
          pi,
          genus,
          localmin,
          attained,
          poss,
          smaller,
          equal,
          filt;

    if Length( info.necessary ) = 0 then
      InfoGenTuple( "#I  no necessarily generating tuple known\n" );
      return "infinity";
    elif Length( permchars ) = 0 then
      InfoGenTuple( "#I  no primitive permutation character known\n" );
      return "infinity";
    fi;
if not IsBound( info.complete ) or not info.complete then
  Error( "not complete info!" );
fi;

    min:= "infinity";
    for pi in permchars do
      genus:= MonodromyGenus( tbl, pi, info.necessary );
      localmin:= Minimum( genus );
      if localmin < min then
        min:= localmin;
        attained:= [ pi,
                     info.necessary{ Filtered( [ 1 .. Length( info.necessary ) ],
                                             x -> genus[x] = min ) } ];
      elif localmin = min then
       
        Add( attained, [ pi,
                     info.necessary{ Filtered( [ 1 .. Length( info.necessary ) ],
                                             x -> genus[x] = min ) } ] );
      fi;
    od;

    # Compute which of the not necessarily generating triples could afford
    # a strictly smaller genus.
    poss    := Difference( info.possible, info.necessary );
    smaller := [];
    equal   := [];
    for pi in permchars do
      genus:= MonodromyGenus( tbl, pi, poss );
      filt:= poss{ Filtered( [ 1 .. Length( poss ) ],
                                     x -> genus[x] < min ) };
      if Length( filt ) > 0 then
        Add( smaller, [ pi, filt ] );
      fi;
      filt:= poss{ Filtered( [ 1 .. Length( poss ) ],
                                     x -> genus[x] = min ) };
      if Length( filt ) > 0 then
        Add( equal, [ pi, filt ] );
      fi;
    od;

    return rec(
                genus         := min,
                attained      := attained,
                maybeequal    := equal,
                maybesmaller  := smaller
               );
end );


#############################################################################
##
#F  UpperBoundStrongSymmetricGenus( <tbl>, <info> )
##
InstallGlobalFunction( UpperBoundStrongSymmetricGenus, function( tbl, info )

    local min,
          size,
          orders,
          tuple,      # loop over `info.necessary'
          genus,
          attained,
          smaller,
          equal;

    if Length( info.necessary ) = 0 then
      InfoGenTuple( "#I  no necessarily generating tuple known\n" );
      return "infinity";
    fi;

    min:= "infinity";
    size:= Size( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    for tuple in info.necessary do
      genus:= 1 - size + Sum( orders{ tuple }, mi -> size - size/mi ) / 2;
      if genus < min then
        min:= genus;
        attained:= [ tuple ];
      elif genus = min then
        Add( attained, tuple );
      fi;
    od;

    smaller := [];
    equal   := [];

    if info.complete then

      # Compute which of the not necessarily generating triples may afford
      # a strictly smaller genus.
      for tuple in Difference( info.possible, info.necessary ) do
        genus:= 1 - size + Sum( orders{ tuple }, mi -> size - size/mi ) / 2;
        if genus < min then
          Add( smaller, tuple );
        elif genus = min then
          Add( equal, tuple );
        fi;
      od;

    else

      if genus < 1 + size/12 then

        # only triples need to be considered.
        Print( "try `OptimisticBoundStrongSymmetricGenus'\n" );
#T !!

      else
        Print( "warning: not all tuples were available!\n" );
      fi;
    fi;

    return rec(
                genus         := min,
                attained      := attained,
                maybeequal    := equal,
                maybesmaller  := smaller
               );
end );


#############################################################################
##
#F  MinimalCyclicGenus( <n> )
##
InstallGlobalFunction( MinimalCyclicGenus, function( n )

    local facts,
          g;

    facts:= Collected( Factors( n ) );
    if 1 < facts[1][2] then
      g:= ( facts[1][1] - 1 ) / 2 * ( n / facts[1][1] );
    elif Length( facts ) = 1 then
      g:= ( facts[1][1] - 1 ) / 2;
    else
      g:= ( facts[1][1] - 1 ) / 2 * ( n / facts[1][1] - 1 );
    fi;
    if g < 2 then
      g:= 2;
    fi;
    return g;
end );


#############################################################################
##
#F  NongenerationBySingleSubgroup( <tbl>, <subtbl>, <tuple> )
##
InstallGlobalFunction( NongenerationBySingleSubgroup,
    function( tbl, subtbl, tuple )

    local r,             # length of `tuple'
          fus,           # fusion map from `max' to `tbl'
          fuslen,        # length of `fus'
          L,             # 
          i, j,          # loop variables
          card,          #
          classes,
          subclasses,
          Ci,            #
          LL,
          K;

    r:= Length( tuple );
    fus:= GetFusionMap( subtbl, tbl );
    fuslen:= Length( fus );

    # Compute $L = C \cap H$.
    L:= List( [ 1 .. r ], x -> [] );
    for i in [ 1 .. fuslen ] do
      for j in [ 1 .. r ] do
        if fus[i] = tuple[j] then
          Add( L[j], i );
        fi;
      od;
    od;

    # If some of the $C_i \cap H$ are empty then $H$ does not help us.
    if ForAny( L, x -> x = [] ) then
      return false;
    fi;

    # Compute the difference $|\Hom_C(0,G)| - |\Stab_{\Aut(G)}(C)|$,
    # where we use $|G/Z(G)|$ for the latter.
    card:= CardinalityOfHom( tuple, 0, tbl )
             - Size( tbl ) / Length( ClassPositionsOfCentre( tbl ) );

    # Loop over the positions from 1 to `r'.
    classes:= SizesConjugacyClasses( tbl );
    subclasses:= SizesConjugacyClasses( subtbl );
    for i in [ 1 .. r ] do

      Ci:= classes[ tuple[i] ];

      # Loop over the $H$-classes in $C_i \cap H$.
      LL:= ShallowCopy( L );
      for K in L[i] do
        LL[i]:= K;
        if card
            < CardinalityOfHom( LL, 0, subtbl ) * Ci / subclasses[K] then
          return true;
        fi;
      od;

    od;

    # `tuple' may generate.
    return false;
end );





InstallGlobalFunction( OptimisticBoundStrongSymmetricGenus, function( arg )

    local tbl,        # character table, first argument
          r,          # length of the tuples to consider, second argument
          maxes,      # info about maximal subgroups, optional third argument
          super,      #
          permchars,  # permutation characters of `maxes'
          fusion,     # fusion of a maximal subgroup
          tuples,     # list of `r'-tuples, result
          n,          # number of classes
          orders,
          size,
          cand,       #
          genera,     #
          powermap,
          shift1,     #
          shift2,     #
          tuple,      # `r'-tuple (counter to loop over them)
          pos,        # position between 1 and `r'
          value,      # new counter value
          i,          # loop variable
          found,      # shallow copy of found `r'-tuple
          info;

    # Check and get the arguments.
    if   Length( arg ) = 1 and IsCharacterTable( arg[1] ) then

      # We have no information about maximal subgroups.
      tbl   := arg[1];
      maxes := false;
      super := [];

    elif Length( arg ) = 2 and IsCharacterTable( arg[1] )
                           and IsList( arg[2] ) then

      tbl   := arg[1];
      maxes := ShallowCopy( arg[2] );
      super := [];

      # Get the permutation characters resp. the tables of maximal subgroups.
      permchars:= [];
      for i in [ 1 .. Length( maxes ) ] do

        if IsString( maxes[i] ) then
          maxes[i]:= CharacterTable( maxes[i] );
          if maxes[i] = fail then
            Error( maxes[i], " is not an admissible library table name" );
          fi;
        fi;

        if IsRowVector( maxes[i] ) or IsClassFunction( maxes[i] ) then
          permchars[i]:= maxes[i];
          maxes[i]:= fail;
        elif IsCharacterTable( maxes[i] ) then
          fusion:= GetFusionMap( maxes[i], tbl );
          if fusion = fail then
            Error( "no fusion map from ", maxes[i], " into ", tbl );
          fi;
          permchars[i]:= Induced( maxes[i], tbl,
                                  [ TrivialCharacter( maxes[i] ) ],
                                  fusion )[1];
        else
          Error( Ordinal( i ), " position in <maxes> is not valid" );
        fi;
      od;

#T improve this!!
    elif Length( arg ) = 3 and IsCharacterTable( arg[1] )
                           and IsList( arg[2] )
                           and IsList( arg[3] ) then

      tbl   := arg[1];
      maxes := ShallowCopy( arg[2] );
      super := ShallowCopy( arg[3] );

      # Get the permutation characters resp. the tables of maximal subgroups.
      permchars:= [];
      for i in [ 1 .. Length( maxes ) ] do

        if IsString( maxes[i] ) then
          maxes[i]:= CharacterTable( maxes[i] );
          if maxes[i] = fail then
            Error( maxes[i], " is not an admissible library table name" );
          fi;
        fi;

        if IsRowVector( maxes[i] ) or IsClassFunction( maxes[i] ) then
          permchars[i]:= maxes[i];
          maxes[i]:= fail;
        elif IsCharacterTable( maxes[i] ) then
          fusion:= GetFusionMap( maxes[i], tbl );
          if fusion = fail then
            Error( "no fusion map from ", maxes[i], " into ", tbl );
          fi;
          permchars[i]:= Induced( maxes[i], tbl,
                                  [ TrivialCharacter( maxes[i] ) ],
                                  fusion )[1];
        else
          Error( Ordinal( i ), " position in <maxes> is not valid" );
        fi;
      od;

    else
      Error( "usage: OptimisticBound...( <tbl>[, <primitives>] )" );
    fi;

    n:= NrConjugacyClasses( tbl );

    # Loop over the triples that would yield $G$ as a group in genus $g$
    # with $|G| \geq 24 (g-1)$.
    orders:= OrdersClassRepresentatives( tbl );
    size:= Size( tbl );
    cand:= UnorderedTuples( [ 2 .. n ], 3);
    genera:= List( cand, tup -> 1-size + size/2 *Sum( orders{ tup }, x -> 1 - 1/x ) );
    SortParallel( genera, cand );
    i:= 1;
    while genera[i] < 2 do
      i:= i+1;
    od;
    cand:= cand{[i..Length(cand)]};
    genera:= genera{[i..Length(cand)]};

    powermap:= PowerMap( tbl, 2 );
    for tuple in cand do
Print( "test ", tuple, " of orders ", orders{ tuple }, "\n" );
      info:= IsGeneratingTuple( tbl, 0, tuple, maxes, [] );
      if info <> fail then

        if orders[ tuple[1] ] = 2 then
          shift1:= [ tuple[2], tuple[2], powermap[ tuple[3] ] ];
          Sort( shift1 );
          shift2:= [ tuple[3], tuple[3], powermap[ tuple[2] ] ];
          Sort( shift2 );
        fi;

        if orders[ tuple[1] ] <> 2 or
           ( IsGeneratingTuple( tbl, 0, shift1, maxes, super ) <> fail and
             IsGeneratingTuple( tbl, 0, shift2, maxes, super ) <> fail ) then

Print( "may be ", tuple, " of orders ", orders{ tuple }, "\n" );
          if maxes <> false and
             IsGeneratingTuple( tbl, 0, tuple, maxes, [] ) = true then
Print( "is ", tuple, "\n" );
return tuple;
          fi;

        fi;

      fi;
    od;
    return fail;
end );


#############################################################################
##
#E

