#############################################################################
##
#W  sgpres.gi                  GAP library                     Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains  the methods for  subgroup presentations  in finitely
##  presented groups (fp groups).
##
Revision.sgpres_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  AugmentedCosetTableMtc( <G>, <H>, <type>, <string> )  . . . . . . . . . .
#F  . . . . . . . . . . . . .  do an MTC and return the augmented coset table
##
##  'AugmentedCosetTableMtc' applies a Modified Todd-Coxeter coset represent-
##  ative  enumeration  to construct  an augmented coset table  for the given
##  subgroup  H  of  G.  The  subgroup generators  will be  named  <string>1,
##  <string>2, ... .
##
##  Valid types are  1 (for the one generator case),  0 (for the  abelianized
##  case),  and  2 (for the general case).  A type value of  -1 is handled in
##  the same way as the case type = 1,  but the function will just return the
##  index H.index of the given cyclic subgroup, and its exponent aug.exponent
##  as the only component of the resulting record aug.
##
AugmentedCosetTableMtc := function ( G, H, ttype, string )

    local   Fam,                    # elements family of <G>
            fgens,                  # generators of asscociated free group
            grels,                  # relators of G
            sgens,                  # subgroup generators of H
            fsgens,                 # preimages of subgroup generators in F
            next,  prev,            # next and previous coset on lists
            fact,                   # factor to previous coset rep
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
            firstCoinc, lastCoinc,  # first and last coincidence coset
            table,                  # coset table to be built up
            coFacTable,             # coset factor table
            rels,                   # representatives for the relators
            relsGen,                # relators sorted by start generator
            subgroup,               # rows for the subgroup gens
            tree,                   # tree of generators
            tree1, tree2,           # components of tree of generators
            treelength,             # number of gens (primary + secondary)
            type,                   # type
            deductions,             # deduction queue
            i, gen, inv,            # loop variables for generators
            g, f,                   # loop variables for generator cols
            rel,                    # loop variables for relation
            p, p1, p2,              # generator position numbers
            app,                    # arguments list for 'MakeConsequences2'
            limit,                  # limit of the table
            maxlimit,               # maximal size of the table
            j,                      # integer variable
            length, length2,        # length of relator
            cols,                   #
            nums,                   #
            l,                      #
            nrdef,                  # number of defined cosets
            nrmax,                  # maximal value of the above
            nrdel,                  # number of deleted cosets
            nrinf,                  # number for next information message
            numgens,                # number of generators
            F,                      # a new free group
            gens,                   # new generators
            ngens,                  # number of new generators
            defs,                   # definitions of primary subgroup gens
            index,                  # index of H in G
            genname,                # name string
            numcols,                # number of columns in the tables
            numoccs,                # number of gens which occur in the table
            occur,                  #
            treeNums,               #
            exponent,               # order of subgroup in case type = 1
            convert,                # conversion list for subgroup generators
            aug;                    # augmented coset table

    # check the arguments
    if not ( IsSubgroupFpGroup( G ) and IsWholeFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # get some local variables
    Fam := ElementsFamily( FamilyObj( G ) );
    fgens := GeneratorsOfGroup( Fam!.freeGroup );
    grels := Fam!.relators;
    sgens := GeneratorsOfGroup( H );
    fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

    # check the given type for being -1, 0, 1, or 2.
    if ttype < -1 or ttype > 2 then
        Error( "invalid type value; it should be -1, 0, 1, or 2" );
    fi;
    type := ttype;
    if type = -1 then type := 1; fi;

    # check the number of generators and the type for being consistent.
    numgens := Length( sgens );
    if type = 1 and numgens > 1 then
        Error( "type 1 is illegal for more than 1 generators" );
    fi;

    # give some information
    Info( InfoFpGroup, 2, "#I  ", "AugmentedCosetTableMtc called:" );
    Info( InfoFpGroup, 2, "#I      defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    nrinf := 1000;

    # initialize size of the table
    limit := CosetTableDefaultLimit;
    maxlimit := CosetTableDefaultMaxLimit;

    # define one coset (1)
    firstDef  := 1;  lastDef  := 1;
    firstFree := 2;  lastFree := limit;

    # make the lists that link together all the cosets
    next := [ 2 .. limit+1 ];  next[1] := 0;  next[limit] := 0;
    prev := [ 0 .. limit-1 ];  prev[2] := 0;
    fact := [ 1 .. limit ];  fact[1] := 0;  fact[2] := 0;

    # get the representatives of the relators
    rels := RelatorRepresentatives( grels );

    # make the columns for the generators
    table := [ ];
    coFacTable := [ ];
    for gen  in fgens  do
        g := 0 * [ 1 .. limit ];
        f := 0 * [ 1 .. limit ];
        Add( table, g );
        Add( coFacTable, f );
        if not (gen^2 in rels or gen^-2 in rels)  then
            g := 0 * [ 1 .. limit ];
            f := 0 * [ 1 .. limit ];
        fi;
        Add( table, g );
        Add( coFacTable, f );
    od;

    # construct the list relsGen which for each generator or inverse
    # generator contains a list of all cyclically reduced relators,
    # starting with that element, which can be obtained by conjugating or
    # inverting given relators. The relators in relsGen are represented as
    # lists of the coset table columns corresponding to the generators and,
    # in addition, as lists of the respective column numbers.
    relsGen := RelsSortedByStartGen( fgens, rels, table );

    # make the rows for the subgroup generators
    subgroup := [ ];
    for rel  in fsgens  do
        length := LengthWord( rel );
        length2 := 2 * length;
        nums := 0 * [1 .. length2];
        cols := 0 * [1 .. length2];

        # compute the lists.
        i := 0;  j := 0;
        while i < length do
            i := i + 1;  j := j + 2;
            gen := Subword( rel, i, i );
            p := Position( fgens, gen );
            if p = fail then
                p := Position( fgens, gen^-1 );
                p1 := 2 * p;
                p2 := 2 * p - 1;
            else
                p1 := 2 * p - 1;
                p2 := 2 * p;
            fi;
            nums[j]   := p1;  cols[j]   := table[p1];
            nums[j-1] := p2;  cols[j-1] := table[p2];
        od;
        Add( subgroup, [ nums, cols ] );
    od;

    # define the primary subgroup generators.
    ngens := numgens;
    defs := fsgens;

    # initialize the tree of secondary generators.
    if type = 1 then
###     treelength := 0;
###     tree1 := 0;
###     tree2 := 0;
        treelength := 1;
        tree1 := [ 1 ];
        tree2 := [ 0 ];
    elif type = 0 then
        treelength := numgens;
        length := treelength + 100;
        tree1 := 0 * [ 1 .. length ];
        for i in [ 1 .. numgens ] do
            tree1[i] := 0 * [ 1 .. i ];
            tree1[i][i] := 1;
        od;
        tree2 := 0 * [ 1 .. numgens ];
    else
        treelength := numgens;
        length := treelength + 100;
        tree1 := 0 * [ 1 .. length ];
        tree2 := 0 * [ 1 .. length ];
    fi;
    tree := [ tree1, tree2, treelength, numgens, type ];

    # add an empty deduction list
    deductions := [ ];

    # initialize the subgroup exponent (which is needed in case type = 1)
    exponent := 0;
    if type = 1 then
        i := Position( fgens, fsgens[1] );
        if i <> fail then
            if IsIdentical( table[2*i-1], table[2*i] ) then
                exponent := 2;
            fi;
        fi;
    fi;

    # make the structure that is passed to 'MakeConsequences2'
    app := 0 * [ 1 .. 16 ];
    app[1] := table;
    app[2] := next;
    app[3] := prev;
    app[4] := relsGen;
    app[5] := subgroup;
    app[12] := coFacTable;
    app[13] := fact;
    app[14] := tree;
    app[15] := numgens;
    app[16] := exponent;

    # run over all the cosets
    while firstDef <> 0  do

        # run through all the rows and look for undefined entries
        for i  in [ 1 .. Length( table ) ]  do
            gen := table[i];

            if gen[firstDef] = 0  then

                inv := i + 2*(i mod 2) - 1;

                # if necessary expand the table
                if firstFree = 0  then
                    if 0 < maxlimit and  maxlimit <= limit  then
                        maxlimit := Maximum(maxlimit*2,limit*2);
                        Error( "the coset enumeration has defined more ",
                               "than ", limit, " cosets:\ntype 'return;' ",
                               "if you want to continue with a new limit ",
                               "of ", maxlimit, " cosets,\ntype 'quit;' ",
                               "if you want to quit the coset ",
                               "enumeration,\ntype 'maxlimit := 0; return;'",
                               " in order to continue without a limit,\n" );
                    fi;
                    next[2*limit] := 0;
                    prev[2*limit] := 2*limit-1;
                    fact[2*limit] := 0;
                    for g  in table  do g[2*limit] := 0;  od;
                    for g  in coFacTable  do g[2*limit] := 0;  od;
                    for l  in [ limit+2 .. 2*limit-1 ]  do
                        next[l] := l+1;
                        prev[l] := l-1;
                        fact[l] := 0;
                        for g  in table  do g[l] := 0;  od;
                        for g  in coFacTable  do g[l] := 0;  od;
                    od;
                    next[limit+1] := limit+2;
                    prev[limit+1] := 0;
                    fact[limit+1] := 0;
                    for g  in table  do g[limit+1] := 0;  od;
                    for g  in coFacTable  do g[limit+1] := 0;  od;
                    firstFree := limit+1;
                    limit := 2*limit;
                    lastFree := limit;
                fi;

                # update the debugging information
                nrdef := nrdef + 1;
                if nrmax <= firstFree  then
                    nrmax := firstFree;
                fi;

                # define a new coset
                gen[firstDef]              := firstFree;
                coFacTable[i][firstDef]    := 0;
                table[inv][firstFree]      := firstDef;
                coFacTable[inv][firstFree] := 0;
                next[lastDef]              := firstFree;
                prev[firstFree]            := lastDef;
                fact[firstFree]            := 0;
                lastDef                    := firstFree;
                firstFree                  := next[firstFree];
                next[lastDef]              := 0;

                # set up the deduction queue and run over it until it's empty
                app[6]  := firstFree;
                app[7]  := lastFree;
                app[8]  := firstDef;
                app[9]  := lastDef;
                app[10] := i;
                app[11] := firstDef;
### Print( "calling MakeConsequences2 for\n" );
### Print( "  type = ", type, "\n" );
### Print( "  tree = ", tree, "\n" );
                nrdel := nrdel + MakeConsequences2( app );
### Print( "returned from MakeConsequences2\n" );
                firstFree := app[6];
                lastFree  := app[7];
                firstDef  := app[8];
                lastDef   := app[9];

                # give some information
                while nrinf <= nrdef+nrdel  do
                    Info( InfoFpGroup, 2, "#I\t", nrdef, "\t", nrinf-nrdef,
                        "\t", 2*nrdef-nrinf, "\t", nrmax );
                    nrinf := nrinf + 1000;
                od;

            fi;
        od;

        firstDef := next[firstDef];
    od;

    Info( InfoFpGroup, 2, "#I\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel,
        "\t", nrmax );

    # In case of type = -1 return just index and exponent of the given cyclic
    # subroup.
    if ttype = -1 then
#@@     H.index := nrdef - nrdel;
index := nrdef - nrdel;
        Info( InfoFpGroup, 1, "#I  index = ", index, "  total = ", nrdef,
            "  max = ", nrmax );
        aug := rec( );
aug.index := index;
        exponent := app[16];
        if exponent = 0 then
            exponent := "infinity";
        elif exponent < 0 then
            exponent := - exponent;
        fi;
        aug.exponent := exponent;
        return aug;
    fi;

    # standardize the table
    StandardizeTable2( table, coFacTable );

#@@ # save coset table and index in the group record of H.
#@@ if not IsBound( H.cosetTable ) then
#@@     H.cosetTable := table;
#@@ fi;
    index := Length( table[1] );
#@@ if not IsBound( H.index ) then
#@@     H.index := index;
#@@     Info( InfoFpGroup, 1, "#I  index = ", index, "  total = ", nrdef,
#@@         "  max = ", nrmax );
#@@ fi;
#@@ if H.index <> index then
#@@     Error( "inconsistent values for the index of H in G" );
#@@ fi;

    if type = 2 then

        # reduce the tree to its proper length.
        treelength := tree[3];
        length := Length( tree1 );
        while length > treelength do
            Unbind( tree1[length] );
            Unbind( tree2[length] );
            length := length - 1;
        od;

        # determine which generators occur in the augmented table.
        occur := 0 * [ 1 .. treelength ];
        for i in [ 1 .. numgens ] do
            occur[i] := 1;
        od;
        numcols := Length( coFacTable );
        numoccs := numgens;
        i := 1;
        while i < numcols do
            for next in coFacTable[i] do
                if next <> 0 then
                    j := AbsInt( next );
                    if occur[j] = 0 then
                        occur[j] := 1;  numoccs := numoccs + 1;
                    fi;
                fi;
            od;
            i := i + 2;
        od;

        # build up a list of pointers from the occurring generators to the
        # tree, and define names for the occurring secondary generators.
        treeNums := [ 1 .. numoccs ];
        for j in [ ngens+1 .. treelength ] do
            if occur[j] <> 0 then
                ngens := ngens + 1;
                treeNums[ngens] := j;
            fi;
        od;
    fi;

    # get ngens new generators
    F := FreeGroup( ngens, string );
    gens := GeneratorsOfGroup( F );

    # create the augmented coset table record.
    aug := rec( );
    aug.isAugmentedCosetTable := true;
    aug.type := type;
    aug.groupGenerators := fgens;
    aug.groupRelators := grels;
    aug.cosetTable := table;
    aug.cosetFactorTable := coFacTable;
    aug.primaryGeneratorWords := defs;
    aug.subgroupGenerators := gens;
    aug.tree := tree;

    if type = 1 then
        exponent := app[16];
        if exponent = 0 then
            aug.exponent := "infinity";
            aug.subgroupRelators := [ [ ] ];
        else
            if exponent < 0 then  exponent := - exponent;  fi;
            aug.exponent := exponent;
            aug.subgroupRelators := [ 0 * [ 1 .. exponent ] + 1 ];
        fi;

    elif type = 2 then
        aug.treeNumbers := treeNums;

        # prepare a conversion list for the subgroup generator numbers if
        # they do not all occur in the subgroup relators.
        numgens := Length( gens );
        if numgens < treelength then
            convert := 0 * [ 1 .. treelength ];
            for i in [ 1 .. numgens ] do
                convert[treeNums[i]] := i;
            od;
            aug.conversionList := convert;
        fi;
    fi;

    # display a message
    if treelength > 0 then
        numgens := Length( defs );
        Info( InfoFpGroup, 1, "#I  MTC defined ", numgens, " primary and ",
            treelength - numgens, " secondary subgroup generators" );
    fi;

    # return the augmented coset table.
    return aug;
end;


#############################################################################
##
#E  sgpres.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .. ends here

