#############################################################################
##
#W  tietze.gi                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for Tietze transformations of presentation
##  records (i.e., of presentations of finitely presented groups (fp groups).
##
Revision.tietze_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  AbstractWordTietzeWord( <word>, <fgens> )  . . . .  convert a Tietze word
#M                                                        to an abstract word
##
##  'AbstractWordTietzeWord'  assumes  <fgens>  to be  a list  of  free group
##  generators and  <word> to be a Tietze word in these generators,  i. e., a
##  list of positive or negative generator numbers.  It converts <word> to an
##  abstract word,
##
AbstractWordTietzeWord := function ( word, fgens )

    local aword, num;

    aword := One( fgens[1] );
    for num in word do
        if num > 0 then
            aword := aword * fgens[num];
        else
            aword := aword * fgens[-num]^-1;
        fi;
    od;
    return aword;
end;


#############################################################################
##
#M  AddRelator( <Tietze record>, <word> )  . . . . . . . . . .  add a relator
##
##  'AddRelator'  adds the given  relator  to the given  Tietze presentation.
##
AddRelator := function ( T, word )

    local flags, leng, lengths, numrels, rel, rels, tietze;

    # check the first argument to be a Tietze record.
    TzCheckRecord( T );

    if T.printLevel >= 3 then  Print( "#I  adding relator ",word,"\n" );  fi;

    tietze := T.tietze;
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    flags := tietze[TZ_FLAGS];
    lengths := tietze[TZ_LENGTHS];

    # add rel to the relators of T, and make the Tietze lists consistent.
    rel := TzRelator( T, word );
    leng := Length( rel );
    if leng > 0 then
        numrels := numrels + 1;
        rels[numrels] := rel;
        lengths[numrels] := leng;
        flags[numrels] := 1;
        tietze[TZ_NUMRELS] := numrels;
        tietze[TZ_TOTAL] := tietze[TZ_TOTAL] + leng;
        tietze[TZ_MODIFIED] := true;
    fi;

    # if generator images and preimages are being traced through the Tietze
    # transformations applied to T, delete them.
    if IsBound( T.imagesOldGens ) then
        TzUpdateGeneratorImages( T, -1, 0 );
    fi;
end;


#############################################################################
##
#M  FpGroupPresentation( <Tietze record> ) . . . .  converts the given Tietze
#M                                         presentation to a fin. pres. group
##
##  'FpGroupPresentation'  constructs the group  defined by the  given Tietze
##  presentation and returns the group record.
##
FpGroupPresentation := function ( T )

    local F, G, fgens, gens, frels, numgens, origin, redunds, rels, tietze,
          tzword;

    if T.printLevel >= 3 then
        Print( "#I  converting the Tietze presentation to a group\n" );
    fi;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );

    # get some local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    rels := tietze[TZ_RELATORS];
    redunds := tietze[TZ_NUMREDUNDS];

    # tidy up the Tietze presentation.
    if redunds > 0 then  TzRemoveGenerators( T );  fi;
### TzSort( T );

    # create an appropriate free group.
    F := FreeGroup( numgens );
    fgens := GeneratorsOfGroup( F );

    # convert the relators from Tietze words to words in the generators of F.
    frels := [ ];
    for tzword in rels do
        if tzword <> [ ] then
            Add( frels, AbstractWordTietzeWord( tzword, fgens ) );
        fi;
    od;

    # get the resulting finitely presented group.
    G := F / frels;

    # save the generator images, if available.
    origin := rec( );
    if IsBound( T.imagesOldGens ) then
        origin.imagesOldGens := Immutable( T.imagesOldGens );
        origin.preImagesNewGens := Immutable( T.preImagesNewGens );
    fi;
    SetTietzeOrigin( G, origin );
    
    return G;
end;


#############################################################################
##
#M  PresentationFpGroup( <G> [,<print level>] ) . . .  create a Tietze record
##
##  'PresentationFpGroup'  creates a presentation, i.e. a  Tietze record, for
##   the given finitely presented group.
##
PresentationFpGroup := function ( arg )

    local F, G, fggens, freegens, frels, gens, grels, i, invs, lengths,
          numgens, numrels, printlevel, rels, T, tietze, total;

    # check the first argument to be a finitely presented group.
    G := arg[1];
    if not ( IsSubgroupFpGroup( G ) and IsWholeFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;

    # check the second argument to be an integer.
    printlevel := 1;
    if Length( arg ) = 2 then  printlevel := arg[2];  fi;
    if not IsInt( printlevel ) then
        Error( "second argument must be an integer" );
    fi;

    # Create the Tietze record.
    T := rec( );
    T.isTietze := true;
    T.operations := PresentationOps;
    tietze := [ ]; tietze[TZ_LENGTHTIETZE] := 0;
    T.tietze := tietze;

    # initialize the Tietze stack.
    fggens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    F := FreeGroup( infinity, "_x" );
    freegens := GeneratorsOfGroup( F );
    tietze[TZ_FREEGENS] := freegens;
    numgens := Length( fggens );
    tietze[TZ_NUMGENS] := numgens;
    gens := List( [ 1 .. numgens ], i -> freegens[i] );
    tietze[TZ_GENERATORS] := gens;
    invs := ( numgens + 1 ) - [ 1 .. 2 * numgens + 1 ];
    tietze[TZ_INVERSES] := invs;
    frels := List( grels, rel -> MappedWord( rel, fggens, gens ) );
    numrels := Length( frels );
    rels := List( [ 1 .. numrels ], i -> TzRelator( T, frels[i] ) );
    lengths := List( [ 1 .. numrels ], i -> Length( rels[i] ) );
    total := Sum( lengths );
    tietze[TZ_NUMRELS] := numrels;
    tietze[TZ_RELATORS] := rels;
    tietze[TZ_LENGTHS] := lengths;
    tietze[TZ_FLAGS] := ListWithIdenticalEntries( numrels, 1 );
    tietze[TZ_TOTAL] := total;
    tietze[TZ_STATUS] := [ 0, 0, -1 ];
    tietze[TZ_MODIFIED] := false;
    T.generators := tietze[TZ_GENERATORS];
    T.components := [ ]; T.components[numgens] := 0;
    for i in [ 1 .. numgens ] do
        T.(String( i )) := gens[i];
        T.components[i] := i;
    od;
    T.nextFree := numgens + 1;
    T.identity := Identity( F );

    # initialize the Tietze options by their default values.
    T.eliminationsLimit := 100;
    T.expandLimit := 150;
    T.generatorsLimit := 0;
    T.lengthLimit := "infinity";
    T.loopLimit := "infinity";
    T.printLevel := printlevel;
    T.saveLimit := 10;
    T.searchSimultaneous := 20;

    # print the status line.
    if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;

    # handle relators of length 1 or 2, but do not eliminate generators.
    T.protected := Length( gens );
### TzHandleLength1Or2Relators( T );
    T.protected := 0;

    # sort the relators and print the status line.
### TzSort( T );
    if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;

    # return the Tietze record.
    return T;
end;


#############################################################################
##
#M  RemoveRelator( <Tietze record>, <n> ) . . . . . . . . .  remove a relator
#M                                                        from a presentation
##
##  'RemoveRelator'   removes   the  nth  relator   from  the  given   Tietze
##  presentation.
##
RemoveRelator := function ( T, n )

    local invs, leng, lengths, num, numgens1, numrels, rels, tietze;

    # check the first argument to be a Tietze record.
    TzCheckRecord( T );

    # get some local variables.
    tietze := T.tietze;
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];
    invs := tietze[TZ_INVERSES];
    numgens1 := tietze[TZ_NUMGENS] + 1;

    # check the second argument to be in range.
    if ( n < 1 or n > numrels ) then
        Error( "relator number out of range" );
    fi;

    # print a message.
    if T.printLevel >= 3 then
        Print( "#I  removing the ", n, "th relator\n" );
    fi;

    # check if the nth relator has defined an involution.
    leng := lengths[n];
    if leng = 2 and rels[n][1] = rels[n][2] then
        num := rels[n][1];
        if num < 0 then  num := -num;  fi;
        if invs[numgens1+num] = num then  invs[numgens1+num] := -num;  fi;
    fi;

    # remove the nth relator, and make the Tietze lists consistent.
    rels[n] := [ ];
    lengths[n] := 0;
    tietze[TZ_TOTAL] := tietze[TZ_TOTAL] - leng;
    TzSort( T );
    if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;

    # if generator images and preimages are being traced through the Tietze
    # transformations applied to T, delete them.
    if IsBound( T.imagesOldGens ) then
        TzUpdateGeneratorImages( T, -1, 0 );
    fi;
end;


#############################################################################
##
#M  TietzeWordAbstractWord( <word>, <fgens> ) . . .  convert an abstract word
#M                                                           to a Tietze word
##
##  'TietzeWordAbstractWord'  assumes  <fgens>  to be a  list  of  free group
##  generators  and  <word>  to be an abstract word  in these generators.  It
##  converts <word> into a Tietze word, i. e., a list of positive or negative
##  generator numbers.
##
TietzeWordAbstractWord := function ( word, generators )

    local gen, i, length, pos, tzword;

    length := LengthWord( word );
    tzword := [ ]; tzword[length] := 0;
    for i in [ 1 .. length ] do
        gen := Subword( word, i, i );
        pos := Position( generators, gen );
        if pos = false then
            pos := Position( generators, gen^-1 );
            if pos = false then
                # print an error message.
                Error( "given word is not a word in the given generators" );
            fi;
            pos := - pos;
        fi;
        tzword[i] := pos;
    od;
    return tzword;

end;


#############################################################################
##
#M  TzCheckRecord( <Tietze record> )  . . . .  check Tietze record components
##
##  'TzCheckRecord'  checks some components of the  given Tietze record to be
##  consistent.
##
TzCheckRecord := function ( T )

    local tietze;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    # check the generator lists to be consistent.
    tietze := T.tietze;
    if not ( IsIdentical( T.generators, tietze[TZ_GENERATORS] ) ) or
        Length( tietze[TZ_GENERATORS] ) <> tietze[TZ_NUMGENS] then
        Error( "inconsistent generator lists" );
    fi;

    # check the inverses list.
    if Length( tietze[TZ_INVERSES] ) <> 2 * tietze[TZ_NUMGENS] + 1 then
        Error( "inconsistent generator inverses" );
    fi;

    # check the relator list.
    if Length( tietze[TZ_RELATORS] ) <> tietze[TZ_NUMRELS] or
        Length( tietze[TZ_LENGTHS] ) <> tietze[TZ_NUMRELS] or
        Length( tietze[TZ_FLAGS] ) <> tietze[TZ_NUMRELS] then
        Error( "inconsistent relators" );
    fi;

end;


#############################################################################
##
#M  TzEliminateGen( <Tietze record>, <n> ) . . . eliminates the nth generator
##
##  'TzEliminateGen' eliminates the Tietze generator tietze[TZ_GENERATORS][n]
##  if possible, i. e. if that generator can be isolated  in some appropriate
##  Tietze relator.  However,  the elimination  will not be  performed if the
##  resulting total length of the relators cannot be guaranteed to not exceed
##  the parameter T.lengthLimit.
##
TzEliminateGen := function ( T, num )

    local gen, gens, invs, length, lengths, numgens, numrels, occRelNum,
          occur, occTotal, pos, rel, rels, space, spacelimit, tietze, word;

    # check the first argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;
    spacelimit := T.lengthLimit;

    tietze[TZ_MODIFIED] := false;

    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    invs := tietze[TZ_INVERSES];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];

    # check the second argument to be a generator number in range.
    if not IsInt( num ) or num <= 0 or num > numgens then  Error(
        "TzEliminateGen: second argument is not a valid generator number" );
    fi;

    # determine the number of occurrences of the given generator.
    occur := TzOccurrences( tietze, num );
    occTotal := occur[1][1];
    if occTotal > 0 and occur[3][1] = 1 then

        occRelNum := occur[2][1];

        length := lengths[occRelNum];
        space := (occTotal - 1) * (length - 1) - length;

        if tietze[TZ_TOTAL] + space <= spacelimit then

            # if there is a tree of generators and if the generator to be
            # deleted is not the last generator, then delete the tree.
            if num < numgens and IsBound( T.tree ) then
                Unbind( T.tree );
            fi;

            # find the substituting word.
            gen := num;
            rel := rels[occRelNum];
            length := lengths[occRelNum];
            pos := Position( rel, gen );
            if pos = false then
                gen := -gen;
                pos := Position( rel, gen );
            fi;
            word := Concatenation( rel{ [pos+1..length] },
                rel{ [1..pos-1] } );

            # replace all occurrences of gen by word^-1.
            if T.printLevel >= 2 then
                Print( "#I  eliminating ", gens[num], " = " );
                if gen > 0 then  Print( TzWord( tietze, word )^-1, "\n" );
                else  Print( TzWord( tietze, word ), "\n" );  fi;
            fi;
            TzSubstituteGen( tietze, -gen, word );

            # update the generator images, if available.
            if IsBound( T.imagesOldGens ) then
                if gen > 0 then  word := -1 * Reversed( word );  fi;
                TzUpdateGeneratorImages( T, num, word );
            fi;
            
            # mark gen to be redundant.
            invs[numgens+1-num] := 0;
            tietze[TZ_NUMREDUNDS] := tietze[TZ_NUMREDUNDS] + 1;
            tietze[TZ_MODIFIED] := true;
        fi;
    fi;
end;


#############################################################################
##
#M  TzEliminateGen1( <Tietze record> )  . . . . . . .  eliminates a generator
##
##  'TzEliminateGen1'  tries to  eliminate a  Tietze generator:  If there are
##  Tietze generators which occur just once in certain Tietze relators,  then
##  one of them is chosen  for which the product of the length of its minimal
##  defining word  and the  number of its  occurrences  is minimal.  However,
##  the elimination  will not be performed  if the resulting  total length of
##  the  relators   cannot  be  guaranteed   to  not  exceed   the  parameter
##  T.lengthLimit.
##
TzEliminateGen1 := function ( T )

    local gen, gens, i, invs, ispace, j, length, lengths, modified, num,
          numgens, numrels, occur, occMultiplicities, occRelNum, occRelNums,
          occTotals, pos, protected, rel, rels, space, spacelimit, tietze,
          total, word;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;
    protected := T.protected;
    spacelimit := T.lengthLimit;

    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    invs := tietze[TZ_INVERSES];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];

    occur := TzOccurrences( tietze );
    occTotals := occur[1];
    occRelNums := occur[2];
    occMultiplicities := occur[3];

    modified := false;
    num := 0;
    space := 0;

    for i in [ protected + 1 .. numgens ] do
        if IsBound( occMultiplicities[i] ) and occMultiplicities[i] = 1 then
            total := occTotals[i];
            length := lengths[occRelNums[i]];
            ispace := (total - 1) * (length - 1) - length;
            if num = 0 or ispace <= space then
                num := i;
                space := ispace;
            fi;
        fi;
    od;

    if num > 0 and tietze[TZ_TOTAL] + space <= spacelimit then

        # if there is a tree of generators and if the generator to be deleted
        # is not the last generator, then delete the tree.
        if num < numgens and IsBound( T.tree ) then
            Unbind( T.tree );
        fi;

        # find the substituting word.
        gen := num;
        occRelNum := occRelNums[num];
        rel := rels[occRelNum];
        length := lengths[occRelNum];
        pos := Position( rel, gen );
        if pos = false then
            gen := -gen;
            pos := Position( rel, gen );
        fi;
        word := Concatenation( rel{ [pos+1..length] }, rel{ [1..pos-1] } );

        # replace all occurrences of gen by word^-1.
        if T.printLevel >= 2 then
            Print( "#I  eliminating ", gens[num], " = " );
            if gen > 0 then  Print( TzWord( tietze, word )^-1, "\n" );
            else  Print( TzWord( tietze, word ), "\n" );  fi;
        fi;
        TzSubstituteGen( tietze, -gen, word );

        # update the generator images, if available.
        if IsBound( T.imagesOldGens ) then
            if gen > 0 then  word := -1 * Reversed( word );  fi;
            TzUpdateGeneratorImages( T, num, word );
        fi;

        # mark gen to be redundant.
        invs[numgens+1-num] := 0;
        tietze[TZ_NUMREDUNDS] := tietze[TZ_NUMREDUNDS] + 1;
        modified := true;
    fi;

    tietze[TZ_MODIFIED] := modified;
end;


#############################################################################
##
#M  TzEliminateGens( <Tietze record> [, <decode>] )  .  Eliminates generators
##
##  'TzEliminateGens'  repeatedly eliminates generators from the presentation
##  of the given group until at least one  of  the  following  conditions  is
##  violated:
##
##  (1) The  current  number of  generators  is greater  than  the  parameter
##      T.generatorsLimit.
##  (2) The   number   of   generators   eliminated   so  far  is  less  than
##      the parameter T.eliminationsLimit.
##  (3) The  total length of the relators  has not yet grown  to a percentage
##      greater than the parameter T.expandLimit.
##  (4) The  next  elimination  will  not  extend the total length to a value
##      greater than the parameter T.lengthLimit.
##
##  If a  second argument  has been  specified,  then it is  assumed  that we
##  are in the process of decoding a tree.
##
##  If not, then the function will not eliminate any protected generators.
##
TzEliminateGens := function ( arg )

    local bound, decode, maxnum, modified, num, redundantsLimit, T, tietze;

    # check the number of arguments.
    if Length( arg ) > 2 or Length( arg ) < 1 then
        Error( "usage: TzEliminateGens( <Tietze record> [, <decode> ] )" );
    fi;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    if T.printLevel >= 3 then  Print( "#I  eliminating generators\n" );  fi;

    # get the second argument.
    decode := Length( arg ) = 2;

    tietze := T.tietze;
    redundantsLimit := 5;
    maxnum := T.eliminationsLimit;
    bound := tietze[TZ_TOTAL] * (T.expandLimit / 100);
    modified := false;
    tietze[TZ_MODIFIED] := true;
    num := 0;
    while  tietze[TZ_MODIFIED]  and  num < maxnum  and
        tietze[TZ_TOTAL] <= bound and
        tietze[TZ_NUMGENS] - tietze[TZ_NUMREDUNDS] > T.generatorsLimit  do
        if decode then
            TzEliminateFromTree( T );
        else
            TzEliminateGen1( T );
        fi;
        if tietze[TZ_NUMREDUNDS] = redundantsLimit then
            TzRemoveGenerators( T );
        fi;
        modified := modified or tietze[TZ_MODIFIED];
        num := num + 1;
    od;
    tietze[TZ_MODIFIED] := modified;
    if tietze[TZ_NUMREDUNDS] > 0 then  TzRemoveGenerators( T );  fi;

    if modified then
        # handle relators of length 1 or 2.
        TzHandleLength1Or2Relators( T );
        # sort the relators and print the status line.
        TzSort( T );
        if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;
    fi;
end;


#############################################################################
##
#M  TzFindCyclicJoins( <Tietze record> )  . . . . . . handle cyclic subgroups
##
##  'TzFindCyclicJoins'  searches for  power and commutator relators in order
##  to find  pairs of generators  which  generate a  common  cyclic subgroup.
##  It uses these pairs to introduce new relators,  but it does not introduce
##  any new generators as is done by 'TzSubstituteCyclicJoins'.
##
TzFindCyclicJoins := function ( T )

    local e, exp, exponents, fac, flags, gen, gens, ggt, i, invs, j, k, l,
          length, lengths, n, newstart, next, num, numgens, numrels, prev,
          powers, rel, rels, tietze, word;

    if T.printLevel >= 3 then
        Print( "#I  searching for cyclic joins\n" );
    fi;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );
    tietze := T.tietze;
    tietze[TZ_MODIFIED] := false;

    # start the routine and repeat it whenever a generator has been
    # eliminated.
    newstart := true;
    while newstart do

      # try to find exponents for the generators.
      exponents := TzGeneratorExponents( T );
      if Sum( exponents ) = 0 then  return;  fi;

      # initialize some local variables.
      newstart := false;
      gens := tietze[TZ_GENERATORS];
      numgens := tietze[TZ_NUMGENS];
      rels := tietze[TZ_RELATORS];
      numrels := tietze[TZ_NUMRELS];
      lengths := tietze[TZ_LENGTHS];
      invs := tietze[TZ_INVERSES];
      flags := tietze[TZ_FLAGS];

      # now work off all commutator relators of length 4.
      i := 0;
      while i < numrels do

        # find the next commutator.
        i := i + 1;
        rel := rels[i];
        if lengths[i] = 4 and rel[1] = invs[numgens+1+rel[3]] and
          rel[2] = invs[numgens+1+rel[4]] then

          # There is a commutator relator of the form [a,b]. Check if
          # there are also power relators of the form a^m or b^n.

          num := [ AbsInt( rel[1] ), AbsInt( rel[2] ) ];
          exp := [ exponents[num[1]], exponents[num[2]] ];
          fac := [ 0, 0 ];
          e   := [ 0, 0 ];

          # If there is at least one relator of the form a^m or b^n, then
          # search for a relator of the form  a^s * b^t  (modulo [a,b])
          # with s prime to m or t prime to n, respectively. For, if s is
          # prime to m, then we can use the Euclidian algorithm to
          # express a as a power of b and then eliminate a.

          if exp[1] > 0 or exp[2] > 0 then

             j := 0;
             while j < numrels do

                # get the next relator.
                j := j + 1;
                if lengths[j] > 0 and j <> i then
                   rel := rels[j];

                   # check whether rel is a word in a and b.
                   length := lengths[j];
                   e[1]   := 0;
                   e[2]   := 0;
                   powers := 0;
                   prev   := 0;
                   l      := 0;
                   while l < length do
                      l := l + 1;
                      next := rel[l];
                      if next <> prev then
                         powers := powers + 1;
                         prev := next;
                      fi;
                      if next = num[1] then  e[1] := e[1] + 1;
                      elif next = num[2] then  e[2] := e[2] + 1;
                      elif next = -num[1] then  e[1] := e[1] - 1;
                      elif next = -num[2] then  e[2] := e[2] - 1;
                      else l := length + 1;
                      fi;
                   od;

                   if l = length and powers > 1 then

                      # reduce exponents, if possible.
                      for k in [ 1, 2 ] do
                         fac[k] := num[k];
                         if exp[k] > 0 then
                            e[k] := e[k] mod exp[k];
                            if e[k] > exp[k]/2 then
                               e[k] := exp[k] - e[k];
                               fac[k] := - fac[k];
                            fi;
                         elif e[k] < 0 then
                            e[k] := - e[k];
                            fac[k] := - fac[k];
                         fi;
                         if fac[k] < 0 then
                            fac[k] := invs[numgens+1-fac[k]];
                         fi;
                      od;

                      # now the e[k] are non-negative.
                      for k in [ 1, 2 ] do
                         if e[k] > 0 and e[3-k] = 0 then
                            exp[k] := GcdInt( e[k], exp[k] );
                            if exp[k] <> exponents[num[k]] then
                               exponents[num[k]] := exp[k];
                               e[k] := exp[k];
                            fi;
                         fi;
                      od;

                      # reduce the current relator, if possible.
                      if e[1] + e[2] < length or powers > 2 then
                         rel := [ ];
                         if e[1] > 0 then  rel := Concatenation(
                             rel, fac[1] + ListWithIdenticalEntries(
                             e[1], fac[2] ) );
                         fi;
                         if e[2] > 0 then  rel := Concatenation(
                            rel, fac[2] + ListWithIdenticalEntries(
                            e[2], fac[2] ) );
                         fi;
                         rels[j] := rel;
                         lengths[j] := e[1] + e[2];
                         tietze[TZ_TOTAL] := tietze[TZ_TOTAL] - length
                            + lengths[j];
                         flags[j] := 1;
                         tietze[TZ_MODIFIED] := true;
                         if T.printLevel >= 3 then  Print(
                            "#I  rels[",j,"] reduced to ",rels[j],"\n" );
                         fi;
                      fi;

                      # try to find a generator that can be deleted.
                      if e[1] = 1 then  n := num[1];
                      elif e[2] = 1 then  n := num[2];
                      else n := 0;
                         for k in [ 1, 2 ] do
                            if n = 0 and e[k] > 1 and
                               GcdInt( e[k], exp[k] ) = 1 then
                               ggt := Gcdex( e[k], exp[k] );
                               gen := [gens[num[1]], gens[num[2]]];
                               if fac[1] < 0 then  gen[1] := gen[1]^-1;  fi;
                               if fac[2] < 0 then  gen[2] := gen[2]^-1;  fi;
                               word := gen[k] * gen[3-k]^(e[3-k]*ggt.coeff1);
                               AddRelator( T, word );
                               numrels := tietze[TZ_NUMRELS];
                               n := num[k];
                            fi;
                         od;
                      fi;

                      # eliminate a generator if it is possible and allowed.
                      if n <> 0 and T.generatorsLimit < numgens then
                         TzEliminate( T );
                         tietze[TZ_MODIFIED] := true;
                         j := numrels;
                         i := numrels;
                         if TZ_NUMGENS < numgens then
                            newstart := true;
                         fi;
                      fi;
                   fi;
                fi;
             od;
          fi;
        fi;
      od;
    od;

    if tietze[TZ_MODIFIED] then
        # handle relators of length 1 or 2.
        TzHandleLength1Or2Relators( T );
        # sort the relators and print the status line.
        TzSort( T );
        if T.printLevel >= 1 then  TzPrintStatus( T, true );  fi;
    fi;
end;


#############################################################################
##
#M  TzGeneratorExponents( <Tietze record> ) . . . list of generator exponents
##
##  'TzGeneratorExponents'  tries to find exponents for the Tietze generators
##  and return them in a list parallel to the list of the generators.
##
TzGeneratorExponents := function ( T )

    local exp, exponents, flags, i, invs, j, l, length, lengths, num, num1,
          numgens, numrels, rel, rels, tietze;

    if T.printLevel >= 3 then
        Print( "#I  trying to find generator exponents\n" );
    fi;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;

    numgens := tietze[TZ_NUMGENS];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];
    invs := tietze[TZ_INVERSES];
    flags := tietze[TZ_FLAGS];

    # Initialize the exponents list.
    exponents := [ ]; exponents[numgens] := 0;

    # Find all relators which are powers of a single generator.
    for i in [ 1 .. numrels ] do
        if lengths[i] > 0 then
            rel := rels[i];
            length := lengths[i];
            num1 := rel[1];
            j := 2;
            while j <= length and rel[j] = num1 do  j := j + 1;  od;
            if j > length then
                num := AbsInt( num1 );
                if exponents[num] = 0 then  exp := length;
                else  exp := GcdInt( exponents[num], length );  fi;
                exponents[num] := exp;
                if exp < length then
                    rels[i] := ListWithIdenticalEntries( exp, num );
                    lengths[i] := exp;
                    tietze[TZ_TOTAL] := tietze[TZ_TOTAL] - length + exp;
                    flags[i] := 1;
                    tietze[TZ_MODIFIED] := true;
                elif num1 < 0 then
                    rels[i] := - rel;
                fi;
            fi;
        fi;
    od;

    return exponents;
end;


#############################################################################
##
#M  TzGo( <Tietze record> [, <silent> ) . . . . .  run Tietze transformations
##
##  'TzGo'  automatically  performs  suitable  Tietze transformations  of the
##  presentation in the given Tietze record.
##
##  If "silent" is specified as true, then the printing of the status line by
##  'TzGo' in case of T.printLevel = 1 is suppressed.
##
##  rels    is the set of relators.
##  gens    is the set of generators.
##  total   is the total length of all relators.
##
TzGo := function ( arg )

    local count, looplimit, printstatus, T, tietze;

    # get the arguments.
    T := arg[1];
    printstatus := T.printLevel = 1 and
        not ( Length( arg ) > 1 and IsBool( arg[2] ) and arg[2] );

    # check the first argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;

    # substitute substrings by shorter ones.
    TzSearch( T );

    # now run our standard strategy and repeat it.
    looplimit := T.loopLimit;
    count := 0;
    while count < looplimit and tietze[TZ_TOTAL] > 0 do

        # replace substrings by substrings of equal length.
        TzSearchEqual( T );
        if tietze[TZ_MODIFIED] then  TzSearch( T );  fi;

        # eliminate generators.
        TzEliminateGens( T );
        if tietze[TZ_MODIFIED] then
            TzSearch( T );
            count := count + 1;
        else
            count := looplimit;
        fi;

        if printstatus then  TzPrintStatus( T, true );  fi;
    od;

    # try to find cyclic subgroups by looking at power and commutator
    # relators.
    if tietze[TZ_TOTAL] > 0 then
        TzFindCyclicJoins( T );
        if tietze[TZ_MODIFIED] then  TzSearch( T );  fi;
        if printstatus then  TzPrintStatus( T, true );  fi;
    fi;

end;

SimplifyPresentation := TzGo;


#############################################################################
##
#M  TzGoGo( <Tietze record> ) . . . . .  run the Tietze go command repeatedly
##
##  'TzGoGo'  calls  the 'TzGo' command  again  and again  until it  does not
##  reduce the presentation any more.  'TzGo' automatically performs suitable
##  Tietze  transformations  of the presentation  in the given Tietze record.
##
##  rels    is the set of relators.
##  gens    is the set of generators.
##  total   is the total length of all relators.
##
TzGoGo := function ( T )

    local count, numgens, numrels, silentGo, tietze, total;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    # initialize the local variables.
    tietze := T.tietze;
    numgens := tietze[TZ_NUMGENS];
    numrels := tietze[TZ_NUMRELS];
    total := tietze[TZ_TOTAL];
    silentGo := T.printLevel = 1;
    count := 0;

    #loop over the Tietze transformations.
    while count < 5 do
        TzGo( T, silentGo );
        count := count + 1;
        if silentGo and ( tietze[TZ_NUMGENS] < numgens or
            tietze[TZ_NUMRELS] < numrels ) then
            TzPrintStatus( T, true );
        fi;
        if tietze[TZ_NUMGENS] < numgens or tietze[TZ_NUMRELS] < numrels or
            tietze[TZ_TOTAL] < total then
            numgens := tietze[TZ_NUMGENS];
            numrels := tietze[TZ_NUMRELS];
            total := tietze[TZ_TOTAL];
            count := 0;
        fi;
    od;

    if silentGo then  TzPrintStatus( T, true );  fi;
end;


#############################################################################
##
#M  TzMostFrequentPairs( <Tietze record>, <n> ) . . . .  occurrences of pairs
##
##  'TzMostFrequentPairs'  returns a list  describing the  n  most frequently
##  occurruing relator subwords of the form  g1 * g2,  where  g1  and  g2 are
##  different generators or their inverses.
##
TzMostFrequentPairs := function ( T, nmax )

    local gens, i, j, k, max, n, numgens, occlist, pairs, tietze;

    # check the first argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    # check the second argument.
    if not IsInt( nmax ) or nmax <= 0 then
        Error( "second argument must be a positive integer" );
    fi;

    # intialize some local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    occlist := [ ]; occlist[4*numgens] := 0;
    pairs := [ ];
    n := 0;

    if nmax = 1 then
        max := 0;

        # find a pair [gen[i], gen[j]] of generators or inverse generators
        # such that the word gen[i] * gen[j] is a most often occurring
        # relator subword.
        for i in [ 1 .. numgens-1 ] do
            occlist := TzOccurrencesPairs( tietze, i, occlist );
            for j in [ i+1 .. numgens ] do
                for k in [ 1 .. 4 ] do
                    if occlist[(4-k)*numgens+j] >= max then
                        max := occlist[(4-k)*numgens+j];
                        pairs[1] := [ max, i, j, 4 - k ];
                        n := 1;
                    fi;
                od;
            od;
        od;

    else

        # compute a sorted list which for each word of the form
        # gen[i]^+-1 * gen[j]^+-1, with i  not equal to j, contains the
        # (negative) number of occurrences of that word as relator subword,
        # the (negative) two indices i and j, and a sign flag (the negative
        # values will make the list be sorted in reversed order).
        for i in [ 1 .. numgens-1] do
            occlist := TzOccurrencesPairs( tietze, i, occlist );
            for j in [ i+1 .. numgens ] do
                for k in [ 0 .. 3 ] do
                    if occlist[k*numgens+j] > 0 then
                        n := n + 1;
                        pairs[n] := [ - occlist[k*numgens+j], - i, - j, k ];
                    fi;
                od;
            od;
            if n > nmax then
                Sort( pairs );
                pairs := pairs{ [1..nmax] };
                n := nmax;
            fi;
        od;

        # sort the list, and then invert the negative entries.
        Sort( pairs );
        for i in [ 1 .. n ] do
            pairs[i][1] := - pairs[i][1];
            pairs[i][2] := - pairs[i][2];
            pairs[i][3] := - pairs[i][3];
        od;
    fi;

    return pairs;
end;


#############################################################################
##
#M  TzNewGenerator( <Tietze record> ) . . . . . . . . .  adds a new generator
##
##  'TzNewGenerator'  defines a  new  abstract generator  and adds it  to the
##  given presentation.
##
##  Let  i  be the smallest positive integer  which has not yet been used  as
##  a generator number  and for which no component  T.i  exists so far in the
##  given  Tietze record  T,  say.  A new abstract generator  _xi  is defined
##  and then added as component  T.i  to the given Tietze record.
##
##  Warning:  'TzNewGenerator'  is  an  internal  subroutine  of  the  Tietze
##  routines.  You should not call it.  Instead, you should call the function
##  'AddGenerator', if needed.
##
TzNewGenerator := function ( T )

    local freegens, gen, gens, numgens, recnames, new, tietze;

    # check the argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "first argument must be a Tietze record" );
    fi;

    # get some local variables.
    tietze := T.tietze;
    freegens := tietze[TZ_FREEGENS];
    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];

    # determine the next free generator number.
    new := T.nextFree;
    recnames := RecNames( T );
    while String( new ) in recnames do  new := new + 1;  od;
    T.nextFree := new + 1;

    # define the new abstract generator.
    gen := freegens[new];
    T.(String( new )) := gen;

    # add the new generator to the presentation.
    numgens := numgens + 1;
    gens[numgens] := gen;
    T.components[numgens] := new;
    tietze[TZ_NUMGENS] := numgens;
    tietze[TZ_INVERSES] := Concatenation( [numgens], tietze[TZ_INVERSES],
        [-numgens] );

    return gen;
end;


#############################################################################
##
#M  TzPrint( <Tietze record> [,<list>] ) . print internal Tietze presentation
##
##  'TzPrint'  prints the current generators and relators of the given Tietze
##  record in their  internal representation.  The optional  second parameter
##  can be  used  to specify  the numbers  of the  relators  to  be  printed.
##  Default: all relators are printed.
##
TzPrint := function ( arg )

    local gens, i, leng, lengths, list, numrels, rels, T, tietze;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # initialize the local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];

    # print the generators.
    if gens = [] then
        Print( "#I  there are no generators\n" );
    else
        Print( "#I  generators: ", gens, "\n" );
    fi;

    # if the relators list is empty, print an appropriate message.
    if numrels = 0 then
        Print( "#I  there are no relators\n" );
        return;
    fi;

    # else print the relators.
    Print( "#I  relators:\n" );
    if Length( arg ) = 1 then
        for i in [1 .. numrels] do
            Print( "#I  ", i, ".  ", lengths[i], "  ", rels[i], "\n" );
        od;
    else
        list := arg[2];
        for i in list do
            if 1 <= i and i <= numrels then
                Print( "#I  ", i, ".  ", lengths[i], "  ", rels[i], "\n" );
            fi;
        od;
    fi;
end;


#############################################################################
##
#M  TzPrintGeneratorImages( <Tietze record> ) . . . .  print generator images
##
##  'TzPrintGeneratorImages'  assumes that  <T>  is a presentation record for
##  which the generator images and preimages under the Tietze transformations
##  applied to <T> are being traced. It displays the preimages of the current
##  generators as  Tietze words in the old generators,  and the images of the
##  old generators as Tietze words in the the current generators.
##
TzPrintGeneratorImages := function ( T )

    local i, images;

    # check T to be a Tietze record.
    TzCheckRecord( T );

    # check if generator images are available.
    if IsBound( T.imagesOldGens ) then

        # display the preimages of the current generators.
        images := T.preImagesNewGens;
        Print( "#I  preimages of current generators as Tietze words",
            " in the old ones:\n" );
        for i in [1 .. Length( images ) ] do
            Print( "#I  ", i, ". ", images[i], "\n" );
        od;

        # display the images of the old generators.
        images := T.imagesOldGens;
        Print( "#I  images of old generators as Tietze words in the",
            " current ones:\n" );
        for i in [1 .. Length( images ) ] do
            Print( "#I  ", i, ". ", images[i], "\n" );
        od;

    else

        # if not, display an appropriate message.
        Print( "#I  generator images are not available\n" );

    fi;

end;


#############################################################################
##
#M  TzPrintGenerators( <Tietze record> [,<list>] ) . . . . . print generators
##
##  'TzPrintGenerators'  prints the generators of the given  Tietze presenta-
##  tion together with the  number of their occurrences.  The optional second
##  parameter  can be used to specify  the numbers  of the  generators  to be
##  printed.  Default: all generators are printed.
##
TzPrintGenerators := function ( arg )

    local gens, i, invs, leng, list, max, min, num, numgens, occur, T,
          tietze;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # initailize some local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    invs := tietze[TZ_INVERSES];
    numgens := tietze[TZ_NUMGENS];

    # if the generators list is empty, print an appropriate message.
    if numgens = 0 then
        Print( "#I  there are no generators\n" );
        return;
    fi;

    # else determine the list of generators to be printed.
    if Length( arg ) = 1 then
        list := [ 1 .. numgens ];
        min := 1;
        max := numgens;
    else
        # check the second argument to be a list.
        list := arg[2];
        if not ( IsList( list ) ) then
            Error( "second argument must be a list" );
        fi;
        if list = [] then  list := [ 0 ];  fi;
        leng := Length( list );

        if IsRange( list ) then
            min := Maximum( list[1], 1 );
            max := Minimum( list[leng], numgens );
            list := [ min .. max ];
        else
            min := Maximum( Minimum( list ), 1 );
            max := Minimum( Maximum( list ), numgens );
        fi;
    fi;

    if min = max then

        # determine the number of occurrences of the specified generator.
        occur := TzOccurrences( tietze, max );

        # print the generator.
        num := occur[1][1];
        if num = 1 then
            Print( "#I  ",max,".  ",gens[max],"   ",num," occurrence " );
        else
            Print( "#I  ",max,".  ",gens[max],"   ",num," occurrences" );
        fi;
        if invs[numgens+1+max] > 0 then  Print( "   involution" );  fi;
        Print( "\n" );

    elif min < max then

        # determine the number of occurrences for all generators.
        occur := TzOccurrences( tietze );

       # print the generators.
        for i in list do
            if 1 <= i and i <= numgens then
                num := occur[1][i];
                if num = 1 then
                    Print( "#I  ",i,".  ",gens[i],"   ",num," occurrence " );
                else
                    Print( "#I  ",i,".  ",gens[i],"   ",num," occurrences" );
                fi;
                if invs[numgens+1+i] > 0 then  Print( "   involution" );  fi;
                Print( "\n" );
            fi;
        od;
    fi;
end;


#############################################################################
##
#M  TzPrintLengths( <Tietze record> )  . . . . . . . .  print relator lengths
##
##  'TzPrintLengths'  prints  a list  of all  relator  lengths  of the  given
##  presentation record.
##
TzPrintLengths := function ( T )

    local tietze;

    # check the argument to be a Tietze record.
    TzCheckRecord( T );
    tietze := T.tietze;

    # print the list of relator lengths;
    Print( tietze[TZ_LENGTHS], "\n" );
end;


#############################################################################
##
#M  TzPrintPairs( <Tietze record> [,<n>] ) . . . . print occurrences of pairs
##
##  'TzPrintPairs'  prints the n most often occurring relator subwords of the
##  form  a * b,  where a and b are  different generators  or their inverses,
##  together with their numbers of occurrences. The default value of n is 10.
##  If n has been specified to be zero, then it is interpreted as "infinity".
##
TzPrintPairs := function ( arg )

    local geni, genj, gens, k, m, n, num, pairs, T, tietze;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # get the second argument.
    n := 10;
    if Length( arg ) > 1 then  n := arg[2];  fi;
    if not IsInt( n ) or n < 0 then
        Error( "second argument must be a positive integer" );
    fi;
    if n = 0 then  n := "infinity";  fi;

    # intialize the local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];

    # determine the n most frequently occurring pairs.
    pairs := TzMostFrequentPairs( T, n );

    # print them.
    n := Length( pairs );
    for m in [ 1 .. n ] do
        num := pairs[m][1];
        k := pairs[m][4];
        geni := gens[pairs[m][2]];
        if k > 1 then  geni := geni^-1;  fi;
        genj := gens[pairs[m][3]];
        if k mod 2 = 1 then  genj := genj^-1;  fi;
        if num = 1 then  Print(
            "#I  ",m,".  ",num,"  occurrence  of  ",geni," * ",genj,"\n" );
        elif num > 1 then  Print(
            "#I  ",m,".  ",num,"  occurrences of  ",geni," * ",genj,"\n" );
        fi;
    od;
end;


#############################################################################
##
#M  TzPrintPresentation( <Tietze record> ) . . . . . . . . print presentation
##
##  'TzPrintGenerators'  prints the  generators and the  relators of a Tietze
##  presentation.
##
TzPrintPresentation := function ( T )

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );

    # print the generators.
    Print( "#I  generators:\n" );
    TzPrintGenerators( T );

    # print the relators.
    Print( "#I  relators:\n" );
    TzPrintRelators( T );

    # print the status line.
    TzPrintStatus( T );
end;


#############################################################################
##
#M  TzPrintStatus( <Tietze record> [, <norepeat> ] ) . . .  print status line
##
##  'TzPrintStatus'  prints the number of generators, the number of relators,
##  and the total length of all relators in the  Tietze  presentation  of the
##  given group.  If  "norepeat"  is specified as true,  then the printing is
##  suppressed if none of the three values has changed since the last call.
##
TzPrintStatus := function ( arg )

    local norepeat, numgens, numrels, status, T, tietze, total;

    # get the arguments.
    T := arg[1];
    norepeat := Length( arg ) > 1 and IsBool( arg[2] ) and arg[2];

    # check the first argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "first argument must be a Tietze record" );
    fi;
    tietze := T.tietze;
    total := tietze[TZ_TOTAL];

    # get number of generators and number of relators.
    numgens := tietze[TZ_NUMGENS] - tietze[TZ_NUMREDUNDS];
    numrels := tietze[TZ_NUMRELS];

    status := [ numgens, numrels, total ];
    if not ( status = tietze[TZ_STATUS] and norepeat ) then

        # print the Tietze status line.
        if IsBound( T.name ) then  Print( "#I  ", T.name, " has " );
        else Print( "#I  there are " );  fi;
        if status[1] = 1 then  Print( status[1], " generator" );
        else  Print( status[1], " generators" );  fi;
        if status[2] = 1 then  Print( " and ", status[2], " relator" );
        else  Print( " and ", status[2], " relators" );  fi;
        Print( " of total length ", status[3], "\n" );

        # save the new status.
        tietze[TZ_STATUS] := status;
    fi;
end;


#############################################################################
##
#M  TzRelator( <Tietze record>, <word> ) . . . . . . . . . . . . . . . . . .
##
##  'TzRelator'
##
TzRelator := function ( T, word )

    local gen, gens, i, i1, i2, pos, tietze, tzword;

    # get some local variables
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];

    # cyclically reduce the given word
    i1 := 1;
    i2 := LengthWord( word );
    while i1 < i2 and Subword( word, i1, i1 ) = Subword( word, i2, i2 )^-1 do
        i1 := i1 + 1;
        i2 := i2 - 1;
    od;

    # build up the corresponding Tieze word
    tzword := [ i1 .. i2 ];
    for i in [ i1 .. i2 ] do
        gen := Subword( word, i, i );
        pos := Position( gens, gen );
        if pos = fail then
            pos := Position( gens, gen^-1 );
            if pos = fail then Error(
               "given relator is not a word in the Tietze generators" );
            fi;
            pos := - pos;
        fi;
        tzword[i-i1+1] := pos;
    od;

    return tzword;
end;


#############################################################################
##
#M  TzRemoveGenerators( <Tietze record> ) . . . . Remove redundant generators
##
##  'TzRemoveGenerators'   deletes  the   redundant  Tietze  generators   and
##  renumbers  the non-redundant ones  accordingly.  The redundant generators
##  are  assumed   to  be   marked   in  the   inverses  list   by  an  entry
##  invs[numgens+1-i] <> i.
##
TzRemoveGenerators := function ( T )

    local comps, gens, i, image, invs, j, newim, numgens, numgens1,
          oldnumgens, pointers, preimages, redunds, tietze, tracingImages,
          tree, treelength, treeNums;

    if T.printLevel >= 3 then
        Print( "#I  renumbering the Tietze generators\n" );
    fi;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    tietze := T.tietze;
    redunds := tietze[TZ_NUMREDUNDS];
    if redunds = 0 then  return;  fi;

    tracingImages := IsBound( T.imagesOldGens );
    if tracingImages then  preimages := T.preImagesNewGens;  fi;
    comps := T.components;
    gens := tietze[TZ_GENERATORS];
    invs := tietze[TZ_INVERSES];
    numgens := tietze[TZ_NUMGENS];
    numgens1 := numgens + 1;
    tree := 0;

    if IsBound( T.tree ) then

        tree := T.tree;
        treelength := tree[TR_TREELENGTH];
        treeNums := tree[TR_TREENUMS];
        pointers := tree[TR_TREEPOINTERS];

        # renumber the non-redundant generators in the relators.
        j := 0;
        for i in [ 1 .. numgens ] do
            if invs[numgens1-i] = i then
                j := j + 1;
                if j < i then
                    comps[j] := comps[i];
                    treeNums[j] := treeNums[i];
                    pointers[AbsInt(treeNums[j])] := treelength + j;
                    invs[numgens1-i] := j;
                    if invs[numgens1+i] > 0 then  invs[numgens1+i] := j;
                    else  invs[numgens1+i] := -j;  fi;
                fi;
            else
                Unbind( T.(String(comps[i])) );
                invs[numgens1-i] := 0;
                invs[numgens1+i] := 0;
            fi;
        od;

    else

        # renumber the non-redundant generators in the relators.
        j := 0;
        for i in [ 1 .. numgens ] do
            if invs[numgens1-i] = i then
                j := j + 1;
                if j < i then
                    comps[j] := comps[i];
                    invs[numgens1-i] := j;
                    if invs[numgens1+i] > 0 then  invs[numgens1+i] := j;
                    else  invs[numgens1+i] := -j;  fi;
                fi;
            else
                Unbind( T.(String(comps[i])) );
                invs[numgens1-i] := 0;
                invs[numgens1+i] := 0;
            fi;
        od;

    fi;

    if j <> numgens - redunds then
         Error( "This is a bug.  You should never get here.\n",
         "Please send a copy of your job to the GAP administrators.\n" );
    fi;
    TzRenumberGens( tietze );

    # update the generator images, if available.
    if tracingImages then
        for i in [ 1 .. Length( T.imagesOldGens ) ] do
            image := T.imagesOldGens[i];
            newim := [];
            for j in [ 1 .. Length( image ) ] do
                Add( newim, invs[numgens1-image[j]] );
            od;
            T.imagesOldGens[i] := ReducedRrsWord( newim );
        od;
    fi;

    # update the other generators list and the lists related to it.
    for i in [ 1 .. numgens ] do
        j := invs[numgens1-i];
        if j < i and j > 0 then
            gens[j] := gens[i];
            invs[numgens1-j] := j;
            invs[numgens1+j] := invs[numgens1+i];
            if tracingImages then
                preimages[j] := preimages[i];
            fi;
        fi;
    od;
    j := numgens;
    numgens := numgens - redunds;
    tietze[TZ_INVERSES] := invs{ [numgens1-numgens..numgens1+numgens] };
    while j > numgens do
        Unbind( gens[j] );
        Unbind( comps[j] );
        if tree <> 0 then  Unbind( treeNums[j] );  fi;
        if tracingImages then  Unbind( preimages[j] );  fi;
        j := j - 1;
    od;

    tietze[TZ_NUMGENS] := numgens;
    tietze[TZ_NUMREDUNDS] := 0;
end;


#############################################################################
##
#M  TzSearch( <Tietze record> ) . . . . . . .  search subwords and substitute
##
##  'TzSearch'  searches for  relator subwords  which in some  relator have a
##  complement of shorter length  and which occur in other relators, too, and
##  uses them to reduce these other relators.
##
TzSearch := function ( T )

    local altered, flags, i, flag, j, k, lastj, leng, lengths, lmax, loop,
          maxlen, modified, numrels, oldtotal, rels, save, simultan,
          simultanlimit, tietze;

    if T.printLevel >= 3 then  Print( "#I  searching subwords\n" );  fi;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );
    tietze := T.tietze;
    simultanlimit := T.searchSimultaneous;

    rels := tietze[TZ_RELATORS];
    lengths := tietze[TZ_LENGTHS];
    flags := tietze[TZ_FLAGS];
    tietze[TZ_MODIFIED] := false;
    save := T.saveLimit / 100;

    loop := tietze[TZ_TOTAL] > 0;  while loop do

        TzSort( T );
        numrels := tietze[TZ_NUMRELS];
        modified := false;
        oldtotal := tietze[TZ_TOTAL];

        # search subwords with shorter complements, and substitute.
        flag := 0;
        i := 1;
        while i < numrels do
            if flags[i] <= 1 and lengths[i] > 0 then
                leng := lengths[i];
                lmax := leng + (leng + 1) mod 2;
                if flag < flags[i] then  flag := flags[i];  fi;
                simultan := 1;
                j := i;
                lastj := 0;
                k := i + 1;
                while k <= numrels and lengths[k] <= lmax and
                    simultan < simultanlimit do
                    if flags[k] <= 1 and
                        ( lengths[k] = leng or lengths[k] = lmax ) then
                        lastj := j;
                        j := k;
                        simultan := simultan + 1;
                    fi;
                    k := k + 1;
                od;
                while k <= numrels and ( lengths[k] < leng or
                    flags[k] > 1 or flag = 0 and flags[k] = 0 ) do
                    k := k + 1;
                od;
                if k > numrels then  j := lastj;  fi;
                if i <= j then
                    altered := TzSearchC( tietze, i, j );
                    modified := modified or altered > 0;
                    i := j;
                fi;
            fi;
            i := i + 1;
        od;

        # reset the Tietze flags.
        for i in [ 1 .. numrels ] do
            if flags[i] = 1 or flags[i] = 2 then
                flags[i] := flags[i] - 1;
            fi;
        od;

        if modified then
            if tietze[TZ_TOTAL] < oldtotal then
                tietze[TZ_MODIFIED] := true;
                # handle relators of length 1 or 2.
                TzHandleLength1Or2Relators( T );
                # sort the relators and print the status line.
                TzSort( T );
                if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;
            fi;
        fi;

        loop := tietze[TZ_TOTAL] < oldtotal and tietze[TZ_TOTAL] > 0 and
                (oldtotal - tietze[TZ_TOTAL]) / oldtotal >= save;
    od;
end;


#############################################################################
##
#M  TzSearchEqual( <Tietze record> ) . . . .  search subwords of equal length
##
##  'TzSearchEqual'  searches  for  Tietze relator  subwords  which  in  some
##  relator  have a  complement of  equal length  and which  occur  in  other
##  relators, too, and uses them to modify these other relators.
##
TzSearchEqual := function ( T )

    local altered, equal, i, j, k, lastj, leng, lengths, modified, numrels,
          oldtotal, rels, simultan, simultanlimit, tietze;

    if T.printLevel >= 3 then
        Print( "#I  searching subwords of equal length\n" );
    fi;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );
    tietze := T.tietze;
    simultanlimit := T.searchSimultaneous;

    TzSort( T );

    rels := tietze[TZ_RELATORS];
    lengths := tietze[TZ_LENGTHS];
    numrels := tietze[TZ_NUMRELS];
    modified := false;
    oldtotal := tietze[TZ_TOTAL];
    equal := true;

    # substitute substrings by substrings of equal length.
    i := 1;
    while i < numrels do
        leng := lengths[i];
        if leng > 3 and leng mod 2 = 0 then
            simultan := 1;
            j := i;
            lastj := 0;
            k := i + 1;
            while k <= numrels and lengths[k] <= leng and
                simultan < simultanlimit do
                if lengths[k] = leng then
                    lastj := j;
                    j := k;
                    simultan := simultan + 1;
                fi;
                k := k + 1;
            od;
            while k <= numrels and lengths[k] < leng do
                k := k + 1;
            od;
            if k > numrels then  j := lastj;  fi;
            if i <= j then
                altered := TzSearchC( tietze, i, j, equal );
                modified := modified or altered > 0;
                i := j;
            fi;
        fi;
        i := i + 1;
    od;

    if modified then
        if tietze[TZ_TOTAL] < oldtotal then
            tietze[TZ_MODIFIED] := true;
            # handle relators of length 1 or 2.
            TzHandleLength1Or2Relators( T );
            # sort the relators and print the status line.
            TzSort( T );
            if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;
        fi;
    fi;
end;


#############################################################################
##
#M  TzSort( <Tietze record> ) . . . . . . . . . . . . . . . . . sort relators
##
##  'TzSort'  sorts the relators list of the given Tietze Record T, say, and,
##  in parallel, the search flags list.  Note:  All relators  of length 0 are
##  removed from the list.
##
##  The sorting algorithm used is the same as in the GAP function Sort.
##
TzSort := function ( T )

    if T.printLevel >= 3 then  Print( "#I  sorting the relators\n" );  fi;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    if T.tietze[TZ_NUMRELS] > 1 then  TzSortC( T.tietze );  fi;
end;


#############################################################################
##
#M  TzSubstituteWord( <Tietze record>, <word> [, <string> ] ) . .  substitute
#M                                            a given word as a new generator
##
##  'TzSubstituteWord'  expects <T> to be a Tietze record  and <word> to be a
##  word in the generators of <T>.  It adds a new generator, gen say, to <T>,
##  and then it adds a new relator of the form  gen^-1 * <Word>  to <T>. If a
##  string  <string>  has been  specified,  gen  will be  named by  <string>,
##  otherwise it will get a default name by the function 'AddGenerator'.
##
##  The second argument, <word>, may be  either an abstract word  or a Tietze
##  word, i. e., a list of positive or negative generator numbers.
##
##  More precisely: The effect of a call
##
##     TzSubstituteWord( T, word );
##
##  is more or less equivalent to that of
##
##     AddGenerator( T );
##     gen := T.generators[Length( T.generators )];
##     AddRelator( T, gen^-1 * word );
##
##  Similarly, the effect of
##
##     TzSubstituteWord( T, word, string );
##
##  is more or less equivalent to that of
##
##     gen := AbstractGenerator( string );
##     AddGenerator( T, gen );
##     AddRelator( T, gen^-1 * word );
##
##  The  essential  difference  is,  that  'TzSubstituteWord',  as  a  Tietze
##  transformation of T,  saves and updates the lists of generator images and
##  preimages,  if they are  being traced  under the  Tietze  transformations
##  applied to T,  whereas a call of the function 'AddGenerator' (which  does
##  not perform  Tietze transformations)  will delete  these lists  and hence
##  terminate the tracing.
##
TzSubstituteWord := function ( arg )

    local
          freegens, new, recnames, tietze,
          gen, gens, images, nargs, printlevel, T, tzword, word;

    # check the number of arguments.
    nargs := Length( arg );
    if nargs < 2 or nargs > 3 then  Error(
       "usage: TzSubstituteWord( <Tietze record> <word> [, <string> ] )" );
    fi;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # check the second argument to be an abstract word or a Tietze word in
    # the generators.
    gens := T.generators;
    if IsList( arg[2] ) then
        tzword := ReducedRrsWord( arg[2] );
        word := AbstractWordTietzeWord( tzword, gens );
    else
        word := arg[2];
        tzword := TietzeWordAbstractWord( word, gens );
    fi;

    # if generator images and preimages are being traced through the Tietze
    # transformations of T, save them from being deleted by 'AddGenerator'.
    images := 0;
    if IsBound( T.imagesOldGens ) then
        images := T.imagesOldGens;
        Unbind( T.imagesOldGens );
    fi;

    # add a new generator.
    if nargs = 3 then
###     gen := AbstractGenerator( arg[3] );
        # determine the next free generator number.
        new := T.nextFree;
        recnames := RecNames( T );
        while String( new ) in recnames do  new := new + 1;  od;
        T.nextFree := new + 1;
        # define the new abstract generator.
        tietze := T.tietze;
        freegens := tietze[TZ_FREEGENS];
        gen := freegens[new];
###     T.(String( new )) := gen;
        AddGenerator( T, gen );
    else
        AddGenerator( T );
        gen := T.generators[Length( T.generators )];
    fi;

    # add the corresponding relator.
    if T.printLevel >= 1 then  Print(
        "#I  substituting new generator ",gen," defined by ",word,"\n" );
    fi;
    AddRelator( T, gen^-1 * word );

    # restore the generator images and update the generator preimages, if
    # available.
    if IsList( images ) then
        T.imagesOldGens := images;
        TzUpdateGeneratorImages( T, 0, tzword );
    fi;

    if T.printLevel >= 1 then  TzPrintStatus( T, true );  fi;
end;


#############################################################################
##
#E  tietze.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .. ends here

