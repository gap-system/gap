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
#M  AddGenerator( <Tietze record> )  . . . . . . . . . . . .  add a generator
##
##  'AddGenerator'  extends the given Tietze presentation by a new generator.
##
##  Let  i  be the smallest positive integer  which has not yet been used  as
##  a generator number  and for which no component  T.i  exists so far in the
##  given  Tietze  record  T,  say.  'AddGenerator'  defines  a new  abstract
##  generator _xi  and adds it, as component T.i, to the given Tietze record.
##
AddGenerator := function ( T )

    local gen, numgens, tietze;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );

    # define an abstract generator and add it to the set of generators.
    gen := TzNewGenerator( T );

    # display a message.
    if T.printLevel >= 1 then
        tietze := T.tietze;
        numgens := tietze[TZ_NUMGENS];
        Print( "#I  now the presentation has ", numgens,
            " generators, the new generator is ", gen, "\n");
    fi;

    # if there is a tree of generators, delete it.
    if IsBound( T.tree ) then  Unbind( T.tree );  fi;

    # if generator images and preimages are being traced through the
    # Tietze transformations applied to T, delete them.
    if IsBound( T.imagesOldGens ) then
        TzUpdateGeneratorImages( T, -1, 0 );
    fi;

    tietze[TZ_MODIFIED] := true;
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
#M  DecodeTree( <Tietze record> )  . . . .  decode a subgroup generators tree
##
##  'DecodeTree'  applies the tree decoding method to a subgroup presentation
##  provided by the  Reduced Reidemeister-Schreier  or by the  Modified Todd-
##  Coxeter method.
##
##  rels    is the set of relators.
##  gens    is the set of generators.
##  total   is the total length of all relators.
##
DecodeTree := function ( T )

    local count, decode, looplimit, primary, protected, tietze, trlast;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;
    protected := T.protected;

    # check if there is a tree of generators.
    if not IsBound( T.tree ) then
        Error( "there is not tree to decode it" );
    fi;
    decode := true;
    T.protected := Maximum( protected, T.tree[TR_PRIMARY] );

    # if generator images are being traced, delete them.
    if IsBound( T.imagesOldGens ) then
        Unbind( T.imagesOldGens );
    fi;

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
        TzEliminateGens( T, decode  );
        if tietze[TZ_MODIFIED] then
            TzSearch( T );
            if tietze[TZ_MODIFIED] then  TzSearch( T );  fi;
            if tietze[TZ_MODIFIED] then  TzSearchEqual( T );  fi;
            if tietze[TZ_MODIFIED] then  TzSearch( T );  fi;
            count := count + 1;
        else
            count := looplimit;
        fi;

        if T.printLevel = 1 then  TzPrintStatus( T, true );  fi;
    od;

    # check if the tree decoding has been finished.
    primary := T.tree[TR_PRIMARY];
    trlast := T.tree[TR_TREELAST];
    if trlast <= primary then
        # if yes, delete the tree ...
        Unbind( T.tree );
        # ... and reinitialize the tracing of generator images images if
        # it had been initialized before.
        if IsBound( T.preImagesNewGens ) then
            TzInitGeneratorImages( T );
            if T.printLevel > 0 then
                Print( "#I  Warning: ",
                "the generator images have been reinitialized\n" );
            fi;
        fi;
    else
        # if not, display a serious warning.
        Print( "\n", "#I  **********  WARNING:  the tree decoding is",
            " incomplete !  **********\n\n",
            "#I  hence the isomporphism type of the presented group may",
            " have changed,\n",
            "#I  you should continue by first calling the 'DecodeTree'",
            " command again,\n",
            "#I  possibly after changing the Tietze option parameters",
            " appropriately\n\n" );
    fi;

    T.protected := protected;
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
    TzSort( T );

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
    tietze := ListWithIdenticalEntries( TZ_LENGTHTIETZE, 0 );
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
    invs := ShallowCopy( numgens - [ 0 .. 2 * numgens ] );
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
    T.components := [ 1 .. numgens ];
    for i in [ 1 .. numgens ] do
        T.(String( i )) := gens[i];
    od;
    T.nextFree := numgens + 1;
    T.identity := Identity( F );

    # initialize the Tietze options by their default values.
    T.eliminationsLimit := 100;
    T.expandLimit := 150;
    T.generatorsLimit := 0;
    T.lengthLimit := infinity;
    T.loopLimit := infinity;
    T.printLevel := printlevel;
    T.saveLimit := 10;
    T.searchSimultaneous := 20;

    # print the status line.
    if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;

    # handle relators of length 1 or 2, but do not eliminate generators.
    T.protected := Length( gens );
    TzHandleLength1Or2Relators( T );
    T.protected := 0;

    # sort the relators and print the status line.
    TzSort( T );
    if T.printLevel >= 2 then  TzPrintStatus( T, true );  fi;

    # return the Tietze record.
    return T;
end;


#############################################################################
##
#M  PresentationOps.Print( <T> )  . . . .  pretty print a presentation record
##
PresentationOps.Print := function ( T )

    local numgens, numrels, tietze, total;

    # get number of generators, number of relators, and total length.
    tietze := T.tietze;
    numgens := tietze[TZ_NUMGENS] - tietze[TZ_NUMREDUNDS];
    numrels := tietze[TZ_NUMRELS];
    total := tietze[TZ_TOTAL];

    # print the Tietze status line.
    Print( "<< presentation with ", numgens, " gens and ", numrels,
        " rels of total length ", total, " >>" );

end;


#############################################################################
##
#M  PresentationViaCosetTable(<G>)  . . . . . . . .  construct a presentation
#M  PresentationViaCosetTable(<G>,<F>,<words>) . . . . .  for the given group
##
##  'PresentationViaCosetTable'   constructs   a  presentation  for  a  given
##  concrete  group.  It applies  John  Cannon's  relations finding algorithm
##  which has been described in
##
##    John J. Cannon:  Construction of  defining relators  for  finte groups.
##    Discrete Math. 5 (1973), 105-129, and in
##
##    Joachim Neubueser: An elementary introduction to coset table methods in
##    computational  group theory.  Groups-St. Andrews 1981,  edited by C. M.
##    Campbell and E. F. Robertson, pp. 1-45.  London Math. Soc. Lecture Note
##    Series no. 71, Cambridge Univ. Press, Cambridge, 1982.
##
##  If only a group  <G>  has been  specified,  the single stage algorithm is
##  applied.
##
##  If the  two stage algorithm  is to  be used,  'PresentationViaCosetTable'
##  expects a subgroup <H> of <G> to be described by two additional arguments
##  <F>  and  <words>,  where  <F>  is a  free group  with the same number of
##  generators as  <G>,  and  <words> is a list of words in the generators of
##  <F>  which supply  a list of generators of  <H>  if they are evaluated as
##  words in the corresponding generators of <G>.
##
PresentationViaCosetTable := function ( arg )
    local   G,          # given group
            F,          # given or constructed free group
            fgens,      # generators of F
            words,      # words (in the generators of F) defing H
            twords,     # tidied up list of words
            H,          # subgroup
            elts,       # elements of G or H
            cosets,     # right cosets of G with respect to H
            R1,         # record containing an fp group isomorphic to H
            R2,         # record containing an fp group isomorphic to G
            P,          # resulting presentation
            ggens,      # concrete generators of G
            hgens,      # concrete generators of H
            thgens,     # tidied up list of generators of H
            ngens,      # number of generators of G
            one,        # identity element of G
            F1,         # free group with same number of generators as H
            FP2,        # fp group isomorphic to G
            i, w;       # loop variables

    # check the first argument to be a group
    G := arg[1];
    if not IsGroup( G ) then
        Error( "first argument must be a group" );
    fi;
    ggens := GeneratorsOfGroup( G );
    ngens := Length( ggens );

    # check if a subgroup has been specified
    if Length( arg ) = 1 then

        # apply the single stage algorithm
        Info( InfoFpGroup, 1,
            "calling the single stage relations finding algorithm" );
        elts := AsListSorted( G );
        F := FreeGroup( ngens );
        R2 := RelsViaCosetTable( G, elts, F );

    else

        # check the second argument to be an fp group.
        F := arg[2];
        if not IsFreeGroup( F ) then
            Error( "second argument must be a free group" );
        fi;

        # check F for having the same number of generators as G
        fgens := GeneratorsOfGroup( F );
        if Length( fgens ) <> ngens then
            Error( "the given groups have different number of generators" );
        fi;

        # get the subgroup H
        words := arg[3];
        hgens := List( words, w -> MappedWord( w, fgens, ggens ) );
        H := Subgroup( G, hgens );

        if Size( H ) = 1 or Size( H ) = Size( G ) then

            # apply the single stage algorithm
            Info( InfoFpGroup, 1,
                "calling the single stage relations finding algorithm" );
            elts := AsListSorted( G );
            R2 := RelsViaCosetTable( G, elts, F );

        else

            # apply the two stage algorithm
            Info( InfoFpGroup, 1,
                "calling the two stage relations finding algorithm" );
            Info( InfoFpGroup, 1,
                "using a subgroup of size ", Size( H ), " and index ",
                Size( G ) / Size( H ) );
            # eliminate words which define the identity of G
            one := One( ggens[1] );
            thgens := [];
            twords := [];
            for i in [ 1 .. Length( hgens ) ] do
                if hgens[i] <> one and not hgens[i] in thgens
                    and not hgens[i]^-1 in thgens then
                    Add( thgens, hgens[i] );
                    Add( twords, words[i] );
                fi;
            od;
            hgens := thgens;
            words := twords;

            # construct a presentation for the subgroup H
            elts := AsListSorted( H );
            F1 := FreeGroup( Length( hgens ) );
            R1 := RelsViaCosetTable( H, elts, F1, hgens );

            # construct a presentation for the group G
            cosets := RightCosets( G, H );
            R2 := RelsViaCosetTable( G, cosets, F, words, H, R1 );

        fi;
    fi;

    # simplify the resulting presentation by Tietze transformations,
    # but do not eliminate any generators
    FP2 := R2.fpGroup;
    P := PresentationFpGroup( FP2, 0 );
    P.generatorsLimit := ngens;
    TzGoGo( P );
    P.generatorsLimit := 0;
    P.printLevel := 1;

    # return the resulting presentation
    return P;
end;


#############################################################################
##
#M  RelsViaCosetTable(<G>,<cosets>,<F>)  . . . . . construct relators for the
#M  RelsViaCosetTable(<G>,<cosets>,<F>,<ggens>)  . . . . . . . given concrete
#M  RelsViaCosetTable(<G>,<cosets>,<F>,<words>,<H>,<R1>)  . . . . . . . group
##
##  'RelsViaCosetTable'  constructs a defining set of relators  for the given
##  concrete group using John Cannon's relations finding algrotithm.
##
##  It is a  subroutine  of function  'PresentationViaCosetTable'.  Hence its
##  input and output are specifically designed only for this purpose,  and it
##  does not check the arguments.
##
RelsViaCosetTable := function ( arg )
    local   G,            # given group
            cosets,       # right cosets of G with respect to H
            F,            # given free group
            words,        # given words for the generators of H
            H,            # subgroup, if specified
            fam,          # family of H
            F1,           # free group associated to H
            R1,           # record containing an fp group isomorphic to H
            R2,           # record containing an fp group isomorphic to G
            FP1,          # fp group isomorphic to H
            fhgens,       # generators of F1
            hrels,        # relators of F1
            helts,        # list of elements of H
            idword,       # identity element of F
            perms,        # permutations induced by the gens on the cosets
            stage,        # 1 or 2
            table,        # columns in the table for gens
            rels,         # representatives of the relators
            relsGen,      # relators sorted by start generator
            subgroup,     # rows for the subgroup gens
            i, j,         # loop variables
            gen,          # loop variables for generator
            gen0, inv0,   # loop variables for generator cols
            g, g1,        # loop variables for generator cols
            c,            # loop variable for coset
            rel,          # loop variables for relator
            app,          # arguments list for 'MakeConsequences'
            index,        # index of the table
            col,          # generator col in auxiliary table
            perm,         # permutations induced by a generator on the cosets
            fgens,        # generators of F
            gens2,        # the above abstract gens and their inverses
            ggens,        # concrete generators of G
            ngens,        # number of generators of G
            ngens2,       # twice the above number
            order,        # order of a generator
            actcos,       # part 1 of Schreier vector of G by H
            actgen,       # part 2 of Schreier vector of G by H
            tab0,         # auxiliary table in parallel to table <table>
            cosRange,     # range from 1 to index (= number of cosets)
            genRange,     # range of the odd integers from 1 to 2*ngens-1
            geners,       # order in which the table cols are worked off
            next,         # local coset number
            w,            # loop variable
            left1,        # part 1 of Schreier vector of H by trivial group
            right1,       # part 2 of Schreier vector of H by trivial group
            n,            # number of subgroup element
            words2,       # words for the generators of H and their inverses
            h;            # subgroup element

    # get the arguments, and initialize some local variables

    G := arg[1];
    cosets := arg[2];
    F := arg[3];
    if Length( arg ) = 4 then
        ggens := arg[4];
    else
        ggens := GeneratorsOfGroup( G );
    fi;
    ngens := Length( ggens );
    ngens2 := ngens * 2;
    index := Length( cosets );
    tab0 := [];
    table := [];
    subgroup := [];
    cosRange := [ 1 .. index ];
    genRange := List( [ 1 .. ngens ], i -> 2*i-1 );

    if Length( arg ) < 5 then
        stage := 1;
        rels := [];
    else
        stage := 2;
        words := arg[4];
        H := arg[5];
        helts := AsListSorted( H );
        R1 := arg[6];
        FP1 := R1.fpGroup;
        fam := ElementsFamily( FamilyObj( FP1 ) );
        F1 := fam!.freeGroup;
        fhgens := GeneratorsOfGroup( F1 );
        hrels := fam!.relators;
        # initialize the relators of F2 by the rewritten relators of F1
        rels := List( hrels, rel -> MappedWord( rel, fhgens, words ) );
        # get the Schreier vector for the elements of H
        left1 := R1.actcos;
        right1 := R1.actgen;
        # extend the list of the generators of F1 as words in the abstract
        # generators of F2 by their inverses
        words2 := [];
        for i in [ 1 .. Length( words ) ] do
            Add( words2, words[i] );
            Add( words2, words[i]^-1 );
        od;
    fi;

    fgens := GeneratorsOfGroup( F );
    gens2 := [];
    idword := One( fgens[1] );

    # get the permutations induced by the generators of G on the given
    # cosets
    perms := List( ggens, gen -> Permutation( gen, cosets, OnRight ) );

    # get a coset table from the permutations,
    # and introduce appropriate relators for the involutory generators
    for i in [ 1 .. ngens ] do
        Add( gens2, fgens[i] );
        Add( gens2, fgens[i]^-1 );
        perm := perms[i];
        col := OnTuples( cosRange, perm );
        gen := ListWithIdenticalEntries( index, 0 );
        Add( tab0, col );
        Add( table, gen );
        order := Order( ggens[i] );
        if order = 2 then
            Add( rels, fgens[i]^2 );
        else
            col := OnTuples( cosRange, perm^-1 );
            gen := ListWithIdenticalEntries( index, 0 );
        fi;
        Add( tab0, col );
        Add( table, gen );
    od;

    # define an appropriate ordering of the cosets,
    # enter the definitions in the table,
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
            next := tab0[g][c];
            if next > 0 and actcos[next] = 0 then
                g1 := g + 2*(g mod 2) - 1;
                table[g][c] := next;
                table[g1][next] := c;
                tab0[g][c] := 0;
                tab0[g1][next] := 0;
                actcos[next] := c;
                actgen[next] := g;
                j := j + 1;
                cosets[j] := next;
                if j = index then
                    g := ngens2;
                    i := index;
                fi;
            fi;
        od;
    od;

    # compute the representatives for the relators
    rels := RelatorRepresentatives( rels );

    # make the structure that is passed to 'MakeConsequences'
    app := ListWithIdenticalEntries( 11, 0 );
    app[1] := table;
    app[5] := subgroup;

    # in case stage = 2 we have to handle subgroup relators
    if stage = 2 then

        # make the rows for the relators and distribute over relsGen
        relsGen := RelsSortedByStartGen( fgens, rels, table );
        app[4] := relsGen;

        # start the enumeration and find all consequences
        for g in genRange do
            gen0 := tab0[g];
            for c in cosRange do
                if gen0[c] = 0 then
                    app[10] := g;
                    app[11] := c;
                    n := MakeConsequences( app );
                fi;
            od;
        od;
    fi;

    # run through the coset table and find the next zero entry
    geners := [ 1 .. ngens2 ];
    for i in cosets do
        for j in geners do
            if table[j][i] = 0 then

                # define the entry appropriately,
                g := j + 2*(j mod 2) - 1;
                c := tab0[j][i];
                table[j][i] := c;
                table[g][c] := i;
                tab0[j][i] := 0;
                tab0[g][c] := 0;

                # construct the associated relator
                rel := idword;
                while c <> 1 do
                    g := actgen[c];
                    rel := rel * gens2[g]^-1;
                    c := actcos[c];
                od;
                rel := rel^-1 * gens2[j]^-1;
                c := i;
                while c <> 1 do
                    g := actgen[c];
                    rel := rel * gens2[g]^-1;
                    c := actcos[c];
                od;
                if stage = 2 then
                    h := MappedWord( rel, fgens, ggens );
                    n := PositionSorted( helts, h );
                    while n <> 1 do
                        g := right1[n];
                        rel := rel * words2[g]^-1;
                        n := left1[n];
                    od;
                fi;

                # compute its representative,
                # and add it to the set of relators
                rels := Concatenation(
                    rels, RelatorRepresentatives( [ rel ] ) );

                # make the rows for the relators and distribute over relsGen
                relsGen := RelsSortedByStartGen( fgens, rels, table );
                app[4] := relsGen;

                # mark all already defined entries of table by a zero in
                # tab0
                for g in genRange do
                    gen := table[g];
                    gen0 := tab0[g];
                    inv0 := tab0[g+1];
                    for c in cosRange do
                        if gen[c] > 0 then
                            gen0[c] := 0;
                            inv0[gen[c]] := 0;
                        fi;
                    od;
                od;

                # continue the enumeration and find all consequences
                for g in genRange do
                    gen0 := tab0[g];
                    for c in cosRange do
                        if gen0[c] = 0 then
                            app[10] := g;
                            app[11] := c;
                            n := MakeConsequences( app );
                        fi;
                    od;
                od;
            fi;
        od;
    od;

    # construct a finitely presented group from the relations,
    # add the Schreier vector to its components, and return it
    R2 := rec( );
    R2.fpGroup := F / rels;
    R2.actcos := actcos;
    R2.actgen := actgen;
    return R2;
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
#M  SimplifiedFpGroup( <FpGroup> ) . . . . . . . . .  sinplify the FpGroup by
#M                                                     Tietze transformations
##
##  'SimplifiedFpGroup'  returns a group  isomorphic to the given one  with a
##  presentation which has been tried to simplify via Tietze transformations.
##
SimplifiedFpGroup := function ( G )

    local H, T;

    # check the given argument to be a finitely presented group.
    if not ( IsSubgroupFpGroup( G ) and IsWholeFamily( G ) ) then
        Error( "argument must be a finitely presented group" );
    fi;

    # convert the given group presentation to a Tietze presentation.
    T := PresentationFpGroup( G, 0 );

    # perform Tietze transformations.
    TzGo( T );

    # reconvert the Tietze presentation to a group presentation.
    H := FpGroupPresentation( T );

    # return the resulting group record.
    return H;
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
        if pos = fail then
            pos := Position( generators, gen^-1 );
            if pos = fail then
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
#M  TzEliminate( <Tietze record> ) . . . . . . . . . . eliminates a generator
#M  TzEliminate( <Tietze record>, <gen> )  . . . . . eliminates generator gen
#M  TzEliminate( <Tietze record>, <n> ) . . . . . . . eliminates n generators
##
##  If a generator has been specified,  then  'TzEliminate'  eliminates it if
##  possible, i. e. if it can be isolated in some appropriate relator.  If no
##  generator  has  been  specified ,   then  'TzEliminate'  eliminates  some
##  appropriate  generator  if possible  and if the resulting total length of
##  the relators will not exceed the parameter T.lengthLimit.
##
TzEliminate := function ( arg )

    local eliminations, gennum, n, numgens, numgenslimit, T, tietze;

    # check the number of arguments.
    if Length( arg ) > 2 or Length( arg ) < 1 then
        Error( "usage: TzEliminate( <Tietze record> [, <generator> ] )" );
    fi;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );
    tietze := T.tietze;

    # get the arguments.
    gennum := 0;
    n := 1;
    if Length( arg ) = 2 then
        if IsInt( arg[2] ) then
            n := arg[2];
        else
            gennum := Position( tietze[TZ_GENERATORS], arg[2] );
            if gennum = fail then  Error(
                "usage: TzEliminate( <Tietze record> [, <generator> ] )" );
            fi;
        fi;
    fi;

    if n = 1 then

        # call the appropriate routine to eliminate one generator.
        if gennum = 0 then  TzEliminateGen1( T );
        else  TzEliminateGen( T, gennum );  fi;
        if tietze[TZ_NUMREDUNDS] > 0 then  TzRemoveGenerators( T );  fi;

        # handle relators of length 1 or 2.
        TzHandleLength1Or2Relators( T );

        # sort the relators and print the status line.
        TzSort( T );
        if T.printLevel >= 1 then  TzPrintStatus( T, true );  fi;

    else

        # eliminate n generators.
        numgens := tietze[TZ_NUMGENS];
        eliminations := T.eliminationsLimit;
        numgenslimit := T.generatorsLimit;
        T.eliminationsLimit := n;
        T.generatorsLimit := numgens - n;
        TzEliminateGens( T );
        T.eliminationsLimit := eliminations;
        T.generatorsLimit := numgenslimit;
    fi;
end;


#############################################################################
##
#M  TzEliminateFromTree( <Tietze record> ) . .  eliminates the last generator
#M                                                              from the tree
##
##  'TzEliminateFromTree'  eliminates  the  last  Tietze  generator.  If that
##  generator cannot be isolated in any Tietze relator,  then it's definition
##  is  taken  from  the tree  and added  as an  additional  Tietze  relator,
##  extending  the  set  of  Tietze generators  appropriately,  if necessary.
##  However,  the elimination  will not be  performed  if the resulting total
##  length of the relators  cannot be guaranteed  to not exceed the parameter
##  T.lengthLimit.
##
TzEliminateFromTree := function ( T )

    local exp, factor, flags, gen, gens, i, invnum, invs, leng, length,
          lengths, num, numgens, numrels, occRelNum, occur, occTotal, pair,
          pair1, pointers, pos, pptrtr, primary, ptr, rel, rels, space,
          spacelimit, tietze, tree, treelength, treeNums, trlast, word;

    # check the first argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;

    # get some local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    invs := tietze[TZ_INVERSES];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    flags := tietze[TZ_FLAGS];
    lengths := tietze[TZ_LENGTHS];

    # get some more local variables.
    tree := T.tree;
    treelength := tree[TR_TREELENGTH];
    primary := tree[TR_PRIMARY];
    trlast := tree[TR_TREELAST];
    treeNums := tree[TR_TREENUMS];
    pointers := tree[TR_TREEPOINTERS];

    spacelimit := T.lengthLimit;
    tietze[TZ_MODIFIED] := false;
    occTotal := 0;

    # get the number of the last occurring generator.
    while occTotal = 0 do

        # get the number of the last generator.
        while trlast > primary and pointers[trlast] <= treelength do
            trlast := trlast - 1;
        od;
        tree[TR_TREELAST] := trlast;
        if trlast <= primary then  return;  fi;

        # determine the number of occurrences of the last generator.
        num := pointers[trlast] - treelength;
        occur := TzOccurrences( tietze, num );
        occTotal := occur[1][1];

        # if the last generator does not occur in the relators, mark it to
        # be redundant.
        if occTotal = 0 then
            invs[numgens+1-num] := 0;
            tietze[TZ_NUMREDUNDS] := tietze[TZ_NUMREDUNDS] + 1;
            trlast := trlast - 1;
        fi;
    od;

    if occur[3][1] > 1 then

        # print a message.
        if T.printLevel >= 2 then
            Print( "#I  adding relator from tree position ", trlast, "\n" );
        fi;

        # get the defining word from the tree.
        pair := [ 0, 0 ];
        for i in [ 1 .. 2 ] do

            exp := 1;
            ptr := tree[i][trlast];
            if ptr < 0 then
                exp := - exp;
                ptr := - ptr;
            fi;

            if pointers[ptr] = ptr then
                # add this tree generator to the list of generators.
                gen := TzNewGenerator( T );
                numgens := tietze[TZ_NUMGENS];
                gens := tietze[TZ_GENERATORS];
                invs := tietze[TZ_INVERSES];
                treeNums[numgens] := ptr;
                pointers[ptr] := treelength + numgens;
                if T.printLevel >= 2 then
                    Print( "#I  adding generator ", gens[numgens],
                    " from tree position ", ptr, "\n" );
                fi;
            else
                # find this tree generator in the list of generators.
                while ptr > 0 and pointers[ptr] <= treelength do
                    ptr := pointers[ptr];
                    if ptr < 0 then
                        exp := - exp;
                        ptr := - ptr;
                    fi;
                od;
            fi;

            # now get the generator number of the current factor.
            if ptr = 0 then
                factor := 0;
            else
                factor := pointers[ptr] - treelength;
                if treeNums[factor] < 0 then  exp := - exp;  fi;
                if exp < 0 then  factor := invs[numgens+1+factor];  fi;
            fi;
            pair[i] := factor;
        od;

        # invert the defining word, if necessary.
        if treeNums[num] < 0 then
            pair1 := pair[1];
            pair[1] := invs[numgens+1+pair[2]];
            pair[2] := invs[numgens+1+pair1];
        fi;

        # add the correponding relator to the set of relators.
        invnum := invs[numgens+1+num];
        if pair[1] = invs[numgens+1+pair[2]] then
            rel := [ invnum ];  leng := 1;
        elif pair[1] = 0 then
            rel := [ invnum, pair[2] ];  leng := 2;
        elif pair[2] = 0 then
            rel := [ invnum, pair[1] ];  leng := 2;
        else
            rel := [ invnum, pair[1], pair[2] ];  leng := 3;
        fi;
        numrels := numrels + 1;
        rels[numrels] := rel;
        lengths[numrels] := leng;
        flags[numrels] := 1;
        tietze[TZ_NUMRELS] := numrels;
        tietze[TZ_TOTAL] := tietze[TZ_TOTAL] + leng;
        tietze[TZ_MODIFIED] := true;

        # if the new relator has length at most 2, handle it by calling the
        # appropriate subroutine, and then return.
        if leng <= 2 then
            TzHandleLength1Or2Relators( T );
            trlast := trlast - 1;
            while trlast > primary and pointers[trlast] <= treelength do
                trlast := trlast - 1;
            od;
            tree[TR_TREELAST] := trlast;
            return;
        fi;

        # else update the number of occurrences of the last generator, and
        # continue.
        occTotal := occTotal + 1;
        occur[1][1] := occTotal;
        occur[2][1] := numrels;
        occur[3][1] := 1;
    fi;

    occRelNum := occur[2][1];

    length := lengths[occRelNum];
    space := (occTotal - 1) * (length - 1) - length;

    if tietze[TZ_TOTAL] + space <= spacelimit then

        # find the substituting word.
        gen := num;
        rel := rels[occRelNum];
        length := lengths[occRelNum];
        pos := Position( rel, gen );
        if pos = fail then
            gen := -gen;
            pos := Position( rel, gen );
        fi;
        word := Concatenation( rel{ [pos+1..length] }, rel{ [1..pos-1] } );

        # replace all occurrences of gen by word^-1.
        if T.printLevel >= 2 then
            Print( "#I  eliminating ", gens[num], " = " );
            if gen > 0 then
                Print( AbstractWordTietzeWord( word, gens )^-1, "\n");
            else
                Print( AbstractWordTietzeWord( word, gens ), "\n" );
           fi;
        fi;
        TzSubstituteGen( tietze, -gen, word );

        # mark gen to be redundant.
        invs[numgens+1-num] := 0;
        tietze[TZ_NUMREDUNDS] := tietze[TZ_NUMREDUNDS] + 1;
        tietze[TZ_MODIFIED] := true;
        trlast := trlast - 1;
        while trlast > primary and pointers[trlast] <= treelength do
            trlast := trlast - 1;
        od;
        tree[TR_TREELAST] := trlast;
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
            if pos = fail then
                gen := -gen;
                pos := Position( rel, gen );
            fi;
            word := Concatenation( rel{ [pos+1..length] },
                rel{ [1..pos-1] } );

            # replace all occurrences of gen by word^-1.
            if T.printLevel >= 2 then
                Print( "#I  eliminating ", gens[num], " = " );
                if gen > 0 then
                    Print( AbstractWordTietzeWord( word, gens )^-1, "\n" );
                else
                    Print( AbstractWordTietzeWord( word, gens ), "\n" );
                fi;
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
        if pos = fail then
            gen := -gen;
            pos := Position( rel, gen );
        fi;
        word := Concatenation( rel{ [pos+1..length] }, rel{ [1..pos-1] } );

        # replace all occurrences of gen by word^-1.
        if T.printLevel >= 2 then
            Print( "#I  eliminating ", gens[num], " = " );
            if gen > 0 then
                Print( AbstractWordTietzeWord( word, gens )^-1, "\n" );
            else
                Print( AbstractWordTietzeWord( word, gens ), "\n" );
            fi;
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
                            rel, ListWithIdenticalEntries( e[1], fac[1] ) );
                         fi;
                         if e[2] > 0 then  rel := Concatenation(
                            rel, ListWithIdenticalEntries( e[2], fac[2] ) );
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
    exponents := ListWithIdenticalEntries( numgens, 0 );

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
                    rels[i] := List( rel, num -> -num );
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
#M  TzHandleLength1Or2Relators( <Tietze record> ) . . . handle short relators
##
##  'TzHandleLength1Or2Relators'  searches for  relators of length 1 or 2 and
##  performs suitable Tietze transformations for each of them:
##
##  Generators occurring in relators of length 1 are eliminated.
##
##  Generators  occurring  in square relators  of length 2  are marked  to be
##  involutions.
##
##  If a relator  of length 2  involves two  different  generators,  then the
##  generator with the  larger number is substituted  by the other one in all
##  relators and finally eliminated from the set of generators.
##
TzHandleLength1Or2Relators := function ( T )

    local absrep2, done, flags, gens, i, idword, invs, j, length, lengths,
          numgens, numgens1, numrels, pointers, protected, ptr, ptr1, ptr2,
          redunds, rels, rep, rep1, rep2, tietze, tracingImages, tree,
          treelength, treeNums;

    if T.printLevel >= 3 then  Print( "#I  handling short relators\n" );  fi;

    # check the given argument to be a Tietze record.
    if not ( IsBound( T.isTietze ) and T.isTietze ) then
        Error( "argument must be a Tietze record" );
    fi;
    tietze := T.tietze;
    protected := T.protected;
    tracingImages := IsBound( T.imagesOldGens );

    gens := tietze[TZ_GENERATORS];
    invs := tietze[TZ_INVERSES];
    rels := tietze[TZ_RELATORS];
    lengths := tietze[TZ_LENGTHS];
    flags := tietze[TZ_FLAGS];
    numgens := tietze[TZ_NUMGENS];
    numrels := tietze[TZ_NUMRELS];
    redunds := tietze[TZ_NUMREDUNDS];
    numgens1 := numgens + 1;
    done := false;
    idword := One( gens[1] );

    tree := 0;
    if IsBound( T.tree ) then
        tree := T.tree;
        treelength := tree[TR_TREELENGTH];
        pointers := tree[TR_TREEPOINTERS];
        treeNums := tree[TR_TREENUMS];
    fi;

    while not done do

        done := true;

        # loop over all relators and find those of length 1 or 2.
        i := 0;
        while i < numrels do
            i := i + 1;
            length := lengths[i];
            if length <= 2 and length > 0 and flags[i] <= 2 then

                # find the current representative of the first factor.
                rep1 := rels[i][1];
                while invs[numgens1-rep1] <> rep1 do
                    rep1 := invs[numgens1-rep1];
                od;

                if length = 1 then

                    # handle a relator of length 1.
                    rep1 := AbsInt( rep1 );
                    if rep1 > protected then
                        # eliminate generator rep1.
                        invs[numgens1-rep1] := 0;
                        invs[numgens1+rep1] := 0;
                        if tree <> 0 then
                            ptr1 := AbsInt( treeNums[rep1] );
                            pointers[ptr1] := 0;
                            treeNums[rep1] := 0;
                        fi;
                        if T.printLevel >= 2 then
                            Print( "#I  eliminating ", gens[rep1],
                                " = idword\n" );
                        fi;
                        # update the generator images, if available.
                        if tracingImages then
                            TzUpdateGeneratorImages( T, rep1, [] );
                        fi;
                        redunds := redunds + 1;
                        done := false;
                    fi;
                else

                    # find the current representative of the second factor.
                    rep2 := rels[i][2];
                    while invs[numgens1-rep2] <> rep2 do
                        rep2 := invs[numgens1-rep2];
                    od;

                    # handle a relator of length 2.
                    if AbsInt( rep2 ) < AbsInt( rep1 ) then
                        rep := rep1;  rep1 := rep2;  rep2 := rep;
                    fi;
                    if rep1 < 0 then  rep1 := - rep1;  rep2 := - rep2;  fi;
                    if rep1 = 0 then

                        # the relator is in fact of length at most 1.
                        rep2 := AbsInt( rep2 );
                        if rep2 > protected then
                            # eliminate generator rep1.
                            invs[numgens1-rep2] := 0;
                            invs[numgens1+rep2] := 0;
                            if tree <> 0 then
                                ptr2 := AbsInt( treeNums[rep2] );
                                pointers[ptr2] := 0;
                                treeNums[rep2] := 0;
                            fi;
                            if T.printLevel >= 2 then
                                Print( "#I  eliminating ", gens[rep2],
                                    " = idword\n" );
                            fi;
                            # update the generator images, if available.
                            if tracingImages then
                                TzUpdateGeneratorImages( T, rep2, [] );
                            fi;
                            redunds := redunds + 1;
                            done := false;
                        fi;

                    elif rep1 <> - rep2 then

                        if rep1 <> rep2 then

                          # handle a non-square relator of length 2.
                          if invs[numgens1-rep2] = invs[numgens1+rep2]
                              and invs[numgens1+rep1] < 0 then
                              # add a new square relator for rep1.
                              numrels := numrels + 1;
                              rels[numrels] := [ rep1, rep1 ];
                              lengths[numrels] := 2;
                              flags[numrels] := 1;
                              tietze[TZ_NUMRELS] := numrels;
                              tietze[TZ_TOTAL] := tietze[TZ_TOTAL] + 2;
                          fi;

                          absrep2 := AbsInt( rep2 );
                          if absrep2 > protected then
                             invs[numgens1-rep2] := invs[numgens1+rep1];
                             invs[numgens1+rep2] := rep1;
                             if tree <> 0 then

                                ptr1 := AbsInt( treeNums[rep1] );
                                ptr2 := AbsInt( treeNums[absrep2] );
                                if ptr2 < ptr1 then
                                    ptr := ptr2;
                                    if treeNums[rep1] * treeNums[absrep2]
                                        * rep2 > 0 then
                                        ptr := - ptr;
                                        treeNums[rep1] := ptr;
                                        pointers[ptr2] := treelength + rep1;
                                    fi;
                                    ptr2 := ptr1;
                                    ptr1 := AbsInt( ptr );
                                fi;
                                if rep2 > 0 then
                                    ptr1 := - ptr1;
                                fi;
                                pointers[ptr2] := ptr1;
                                treeNums[absrep2] := 0;
                             fi;
                             if tracingImages or T.printLevel >= 2 then
                                if rep2 > 0 then
                                    rep1 := invs[numgens1+rep1];
                                fi;
                                if T.printLevel >= 2 then
                                    Print( "#I  eliminating ", gens[absrep2],
                                        " = ", AbstractWordTietzeWord(
                                        [ rep1 ], gens ), "\n");
                                fi;
                                # update the generator images, if available.
                                if tracingImages then
                                    TzUpdateGeneratorImages( T, absrep2,
                                        [ rep1 ] );
                                fi;
                             fi;
                             redunds := redunds + 1;
                             done := false;
                          fi;

                        else

                            # handle a square relator.
                            if invs[numgens1+rep1] < 0 then
                                # make the relator a square relator, ...
                                rels[i][1] := rep1;
                                rels[i][2] := rep1;
                                # ... mark it appropriately, ...
                                flags[i] := 3;
                                # ... and mark rep1 to be an involution.
                                invs[numgens1+rep1] := rep1;
                                done := false;
                            fi;

                        fi;

                    fi;
                fi;
            fi;
        od;

        if not done then

            # for each generator determine its current representative.
            for i in [ 1 .. numgens ] do
                if invs[numgens1-i] <> i then
                    rep := invs[numgens1-i];
                    invs[numgens1-i] := invs[numgens1-rep];
                    invs[numgens1+i] := invs[numgens1+rep];
                fi;
            od;

            # perform the replacements.
            TzReplaceGens( tietze );
        fi;
    od;

    # tidy up the Tietze generators.
    tietze[TZ_NUMREDUNDS] := redunds;
    if redunds > 0 then  TzRemoveGenerators( T );  fi;

    # Print( "#I  total length = ", tietze[TZ_TOTAL], "\n" );
end;


#############################################################################
##
#M  TzInitGeneratorImages( T )  . . . . . . . initialize the generator images
#M                                               under Tietze transformations
##
##  'TzInitGeneratorImages'  expects  T  to  be  a  presentation  record.  It
##  defines the current generators to be the "old" generators and initializes
##  two components T.imagesOldGens and T.preImagesNewGens which, at any time,
##  will contain a list of the images  of the old generators  as Tietze words
##  in the new ones  or a list of the  preimages of the new generators in the
##  old ones,  respectively,  under the  isomorphism  defined  by all  Tietze
##  transformations which then will have been applied to T.
##
##  Note:  A subsequent call of the  function DecodeTree  will imply that the
##  images and preimages  are deleted  and reinitializeed  after decoding the
##  tree.
##
TzInitGeneratorImages := function ( T )

    local numgens;

    # check the argument to be a Tietze record.
    TzCheckRecord( T );

    # initialize the lists.
    numgens := Length( T.generators );
    T.oldGenerators := ShallowCopy( T.generators );
    T.imagesOldGens := List( [ 1 .. numgens ], i -> [i] );
    T.preImagesNewGens := List( [ 1 .. numgens ], i -> [i] );

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
#M  TzPrintOptions( <Tietze record> )  . . . . .  print Tietze record options
##
##  'TzPrintOptions'  prints the  components of a Tietze record,  suppressing
##  all those components  which are not options of the Tietze transformations
##  routines.
##
TzPrintOptions := function ( T )

    local i, len, lst, nam;

    # check the argument to be a Tietze record.
    TzCheckRecord( T );

    # determine the maximal name length of the option compoents.
    len  := 0;
    for nam in RecNames( T )  do
        if nam in TzOptionNames  then
            if len < Length( nam )  then
                len := Length( nam );
            fi;
            lst := nam;
        fi;
    od;

    # now print all components of T which are options.
    for nam  in RecNames( T )  do
        if nam in TzOptionNames  then
            Print( "#I  ", nam );
            for i  in [Length(nam)..len]  do
                Print( " " );
            od;
            Print( "= ", T.(nam), "\n" );
        fi;
    od;

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
#M  TzPrintRelators( <Tietze record> [,<list>] ) . . . . . . . print relators
##
##  'TzPrintRelators'  prints the relators of the given  Tietze presentation.
##  The optional second parameter  can be used to specify the  numbers of the
##  relators to be printed.  Default: all relators are printed.
##
TzPrintRelators := function ( arg )

    local gens, i, list, numrels, rels, T, tietze;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # initailize the local variables.
    tietze := T.tietze;
    gens := tietze[TZ_GENERATORS];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];

    # if the relators list is empty, print an appropriate message.
    if numrels = 0 then
        Print( "#I  there are no relators\n" );
        return;
    fi;

    # else print the relators.
    if Length( arg ) = 1 then
        for i in [1 .. numrels] do
            Print( "#I  ", i, ". ",
                AbstractWordTietzeWord( rels[i], gens ), "\n" );
        od;
    else
        list := arg[2];
        for i in list do
            if 1 <= i and i <= numrels then
                Print( "#I  ", i, ". ",
                    AbstractWordTietzeWord( rels[i], gens ), "\n" );
            fi;
        od;
    fi;
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
#M  TzRelator( <Tietze record>, <word> ) . . . . . . convert an abstract word
#M                                                        to a Tietze relator
##
##  'TzRelator' assumes <word> to be an abstract word in the group generators
##  associated  to the  given  Tietze record,  and  converts it  to a  Tietze
##  relator, i.e. a free and cyclically reduced Tietze word.
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
#M  TzSubstitute( <Tietze record>, <word> [, <gen> ] )  . . . . .  substitute
#M  TzSubstitute( <Tietze record> [, <n> [,<elim> ] ] ) . . . a new generator
##
##  In   its   first   form,   'TzSubstitute'   just   calls   the   function
##  'TzSubstituteWord'.
##
##  In its second form, 'TzSubstitute' first determines the n most frequently
##  occurring  relator  subwords  of the form  g1 * g2,  where g1 and g2  are
##  different generators  or  their inverses,  and sorts  them by  decreasing
##  numbers of occurrences.
##
##  Let  a * b  be the  last word  in that list,  and let  i  be the smallest
##  positive integer for which there is no component  T.i so far in the given
##  Tietze record T, then 'TzSubstitute' adds to the given presentation a new
##  generator  T.i  and a new relator  T.i^-1 * a * b,  and it  replaces  all
##  occurrences of  a * b  in the relators by  T.i.  Finally,  if elim = 1 or
##  elim = 2, it eliminates the generator a or b, respectively.  Otherwise it
##  eliminates some generator  by just calling  subroutine 'TzEliminateGen1'.
##
##  The two arguments are optional. If they are specified, then n is expected
##  to be a positive integer,  and  elim  is expected to be  0, 1, or 2.  The
##  default values are n = 1 and elim = 0.
##

TzSubstitute := function ( arg )

    local elim, gen, gens, i, invs, j, k, n, narg, numgens, pair, pairs,
          printlevel, T, tietze, word;

    # just call 'TzSubstituteWord' if the second argument is a word.
    narg := Length( arg );
    if ( narg = 2 or narg = 3 ) and
        ( IsList( arg[2] ) or IsWord( arg[2] ) ) then
        if narg = 2 then
            TzSubstituteWord( arg[1], arg[2] );
        else
            TzSubstituteWord( arg[1], arg[2], arg[3] );
        fi;
        return;
    fi;

    # check the number of arguments.
    if narg < 1 or narg > 3 then  Error(
       "usage: TzSubstitute( <Tietze record> [, <n> [, <elim> ] ] )" );
    fi;

    # check the first argument to be a Tietze record.
    T := arg[1];
    TzCheckRecord( T );

    # get the second argument, and check it to be a positive integer.
    n := 1;
    if narg >= 2 then
        n := arg[2];
        if not IsInt( n ) or n < 1 then
            Error( "second argument must be a positive integer" );
        fi;
    fi;

    # get the third argument, and check it to be 0,  1, or 2.
    elim := 0;
    if narg = 3 then
        elim := arg[3];
        if not IsInt( elim ) or elim < 0 or elim > 2 then
            Error( "third argument must be 0, 1, or 2" );
        fi;
    fi;

    # check the number of generators to be at least 2.
    tietze := T.tietze;
    numgens := tietze[TZ_NUMGENS];
    if numgens < 2 then  return;  fi;

    # initialize some local variables.
    gens := tietze[TZ_GENERATORS];
    invs := tietze[TZ_INVERSES];
    printlevel := T.printLevel;

    # determine the n most frequently occurring relator subwords of the form
    # g1 * g2, where g1 and g2 are different generators or their inverses,
    # and sort them  by decreasing numbers of occurrences.
    pairs := TzMostFrequentPairs( T, n );
    if Length( pairs ) < n then
        if narg > 1 and printlevel >= 1 then
            Print( "#I  TzSubstitute: second argument is out of range\n" );
        fi;
        return;
    fi;

    # get the nth pair [ a, b ], say, from the list.
    i := pairs[n][2];
    j := pairs[n][3];
    k := pairs[n][4];
    if k > 1 then  i := invs[numgens+1+i];  fi;
    if k mod 2 = 1 then  j := invs[numgens+1+j];  fi;
    pair := [i, j];

    # add the word a * b as a new generator.
    gen := TzNewGenerator( T );
    word := AbstractWordTietzeWord( pair, gens );
    if T.printLevel >= 1 then  Print(
        "#I  substituting new generator ",gen," defined by ",word,"\n" );
    fi;
    AddRelator( T, gen^-1 * word );

    # if there is a tree of generators, delete it.
    if IsBound( T.tree ) then  Unbind( T.tree );  fi;

    # update the generator preimages, if available.
    if IsBound( T.imagesOldGens ) then
        TzUpdateGeneratorImages( T, 0, pair );
    fi;

    # replace all relator subwords of the form a * b by the new generator.
    T.printLevel := 0;
    TzSearch( T );
    T.printLevel := printlevel;

    #  eliminate a generator.
    if printlevel = 1 then  T.printLevel := 2;  fi;
    if elim > 0 then
        TzEliminateGen( T, AbsInt( pair[elim] ) );
    else
        TzEliminateGen1( T );
    fi;
    T.printLevel := printlevel;
    if tietze[TZ_MODIFIED] then  TzSearch( T );  fi;
    if tietze[TZ_NUMREDUNDS] > 0 then  TzRemoveGenerators( T );  fi;

    if T.printLevel >= 1 then  TzPrintStatus( T, true );  fi;
end;


#############################################################################
##
#M  TzSubstituteCyclicJoins( <Tietze record> ) . . common roots of generators
##
##  'TzSubstituteCyclicJoins'  tries to find pairs of  commuting generators a
##  and b, say, such that exponent(a) is prime to exponent(b).  For each such
##  pair, their product a * b is substituted as a new generator,  and a and b
##  are eliminated.
##
TzSubstituteCyclicJoins := function ( T )

    local exp, exp1, exp2, exponents, gen, gen2, gens, i, invs, lengths, n2,
          next, num, num1, num2, numgens, numrels, printlevel, rel, rels,
          tietze;

    # check the given argument to be a Tietze record.
    TzCheckRecord( T );

    if T.printLevel >= 3 then
        Print( "#I  substituting cyclic joins\n" );
    fi;

    # Try to find exponents for the generators.
    exponents := TzGeneratorExponents( T );
    tietze := T.tietze;
    tietze[TZ_MODIFIED] := false;

    if Sum( exponents ) = 0 then  return;  fi;

    # sort the relators by their lengths.
    TzSort( T );

    # initialize some local variables.
    gens := tietze[TZ_GENERATORS];
    numgens := tietze[TZ_NUMGENS];
    rels := tietze[TZ_RELATORS];
    numrels := tietze[TZ_NUMRELS];
    lengths := tietze[TZ_LENGTHS];
    invs := tietze[TZ_INVERSES];
    printlevel := T.printLevel;

    # Now work off all commutator relators of length 4.
    i := 1;
    while i <= numrels and lengths[i] <= 4 do

        rel := rels[i];
        if lengths[i] = 4 and rel[1] = invs[numgens+1+rel[3]] and
            rel[2] = invs[numgens+1+rel[4]] then

            # There is a commutator relator of the form [a,b]. Check if
            # there are also power relators of the form a^m or b^n.

            num1 := AbsInt( rel[1] );  exp1 := exponents[num1];
            num2 := AbsInt( rel[2] );  exp2 := exponents[num2];

            # If there are relators a^m and b^n with m prime to n, then
            # a = (a*b)^n,  b = (a*b)^m,  and  (a*b)^(m*n) = 1.  Hence we
            # may define a new generator g, say, by a*b together with the
            # two relations  a = g^n  and  b = g^m,  and then eliminate a
            # and b.  (Note that we can take a^-1 instead of a or b^-1
            # instead of b.)

            if exp1 > 0 and exp2 > 0 and GcdInt( exp1, exp2 ) = 1 then

                gen := TzNewGenerator( T );
                numgens := tietze[TZ_NUMGENS];
                invs := tietze[TZ_INVERSES];

                if printlevel >= 1 then
                    Print( "#I  substituting new generator ",gen,
                        " defined by ",gens[num1]*gens[num2],"\n" );
                fi;

                AddRelator( T, gens[num1] * gen^-exp2 );
                AddRelator( T, gens[num2] * gen^-exp1 );

                # if there is a tree of generators, delete it.
                if IsBound( T.tree ) then  Unbind( T.tree );  fi;

                # update the generator preimages, if available.
                if IsBound( T.imagesOldGens ) then
                    TzUpdateGeneratorImages( T, 0, [ num1, num2 ] );
                fi;

                # save gens[num2] before eliminating gens[num1] because
                # its number may change.
                gen2 := gens[num2];
                if printlevel = 1 then  T.printLevel := 2;  fi;
                TzEliminate( T, gens[num1] );
                num2 := Position( gens, gen2 );
                TzEliminate( T, gens[num2] );
                T.printLevel := printlevel;
                numgens := tietze[TZ_NUMGENS];
                numrels := tietze[TZ_NUMRELS];
                invs := tietze[TZ_INVERSES];
                tietze[TZ_MODIFIED] := true;
                i := 0;
            fi;
        fi;
        i := i + 1;
    od;

    if tietze[TZ_MODIFIED] then
        # handle relators of length 1 or 2.
        TzHandleLength1Or2Relators( T );
        # sort the relators and print the status line.
        TzSort( T );
        if printlevel >= 1 then  TzPrintStatus( T, true );  fi;
    fi;
end;


#############################################################################
##
#M  TzSubstituteWord( <Tietze record>, <word> ) . . . substitute a given word
#M                                                         as a new generator
##
##  'TzSubstituteWord'  expects <T> to be a Tietze record  and <word> to be a
##  word in the generators of <T>.  It adds a new generator,  gen say,  and a
##  new relator of the form  gen^-1 * <Word>  to <T>.
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
##  The  essential  difference  is,  that  'TzSubstituteWord',  as  a  Tietze
##  transformation of T,  saves and updates the lists of generator images and
##  preimages, in case they are being traced under the Tietze transformations
##  applied to T,  whereas a call of the function 'AddGenerator' (which  does
##  not perform a Tietze transformation)  will delete  these lists  and hence
##  terminate the tracing.
##
TzSubstituteWord := function ( T, word )

    local aword, gen, gens, images, tzword;

    # check the first argument to be a Tietze record.
    TzCheckRecord( T );

    # check the second argument to be an abstract word or a Tietze word in
    # the generators.
    gens := T.generators;
    if IsList( word ) then
        tzword := ReducedRrsWord( word );
        aword := AbstractWordTietzeWord( tzword, gens );
    else
        aword := word;
        tzword := TietzeWordAbstractWord( aword, gens );
    fi;

    # if generator images and preimages are being traced through the Tietze
    # transformations of T, save them from being deleted by 'AddGenerator'.
    images := 0;
    if IsBound( T.imagesOldGens ) then
        images := T.imagesOldGens;
        Unbind( T.imagesOldGens );
    fi;

    # add a new generator.
    AddGenerator( T );
    gen := T.generators[Length( T.generators )];

    # add the corresponding relator.
    if T.printLevel >= 1 then  Print(
        "#I  substituting new generator ",gen," defined by ",aword,"\n" );
    fi;
    AddRelator( T, gen^-1 * aword );

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
#M  TzUpdateGeneratorImage( T, n, word )  . . . . update the generator images
#M                                              after a Tietze transformation
##
##  'TzUpdateGeneratorImages'  assumes  that it is called  by a function that
##  performs  Tietze transformations  to a presentation record  <T>  in which
##  images of the old generators  are being traced as Tietze words in the new
##  generators  as well as preimages of the new generators as Tietze words in
##  the old generators.
##
##  If  <n>  is zero,  it assumes that  a new generator defined by the Tietze
##  word <word> has just been added to the presentation.  It converts  <word>
##  from a  Tietze word  in the new generators  to a  Tietze word  in the old
##  generators and adds that word to the list of preimages.
##
##  If  <n>  is greater than zero,  it assumes that the  <n>-th generator has
##  just been eliminated from the presentation.  It updates the images of the
##  old generators  by replacing each occurrence of the  <n>-th  generator by
##  the given Tietze word <word>.
##
##  If <n> is less than zero,  it terminates the tracing of generator images,
##  i. e., it deletes the corresponding record components of <T>.
##
##  Note: 'TzUpdateGeneratorImages' is considered to be an internal function.
##  Hence it does not check the arguments.
##
TzUpdateGeneratorImages := function ( T, n, word )
    
    local i, image, invword, j, newim, num, oldnumgens;

    if n = 0 then

        # update the preimages of the new generators.
        newim := [];
        for num in word do
            if num > 0 then
                Append( newim, T.preImagesNewGens[num] );
            else
                Append( newim, -1 * Reversed( T.preImagesNewGens[-num] ) );
            fi;
        od;
        Add( T.preImagesNewGens, ReducedRrsWord( newim ) );

    elif n > 0 then

        # update the images of the old generators:
        # run through all images and replace the n-th generator by word.
        invword := -1 * Reversed( word );
        oldnumgens := Length( T.imagesOldGens );
        for i in [ 1 .. oldnumgens ] do
            image := T.imagesOldGens[i];
            newim := [];
            for j in [ 1 .. Length( image ) ] do
                if image[j] = n then
                    Append( newim, word );
                elif image[j] = -n then
                    Append( newim, invword );
                else
                    Add( newim, image[j] );
                fi;
            od;
            T.imagesOldGens[i] := ReducedRrsWord( newim );
        od;

    else

        # terminate the tracing of generator images.
        Unbind( T.imagesOldGens );
        Unbind( T.preImagesNewGens );
        if IsBound( T.oldGenerators ) then
            Unbind( T.oldGenerators );
        fi;
        if T.printLevel >= 1 then
            Print( "#I  terminated the tracing of generator images\n" );
        fi;

    fi;
end;


#############################################################################
##
#E  tietze.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .. ends here

