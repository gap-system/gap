#############################################################################
##
#W  grpfp.gi                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for finitely presented groups (fp groups).
##
##  1. methods for elements of f.p. groups
##  2. methods for f.p. groups
##
Revision.grpfp_gi :=
    "@(#)$Id$";


#############################################################################
##
##  1. methods for elements of f.p. groups
##

#############################################################################
##
#R  IsPackedWordDefaultRep
##
#T replace 'ElementByRWSDefaultRep'?
##
IsPackedWordDefaultRep := NewRepresentation(
    "IsPackedWordDefaultRep",
    IsPositionalObjectRep, [ 1 ] );


#############################################################################
##
#M  ElementOfFpGroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpGroup,
    "method for a family of f.p. group elements, and an assoc. word",
    true,
    [ IsFamilyOfFpGroupElements, IsAssocWordWithInverse ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( PrintObj,
    "method for an element of an f.p. group (default repres.)",
    true,
    [ IsPackedWordDefaultRep ],
    0,
    function( obj )
    Print( obj![1] );
    end );


#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . . . . . for element of f.p. group
##
InstallMethod( UnderlyingElement,
    "method for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( ExtRepOfObj,
    "method for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> ExtRepOfObj( obj![1] ) );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( Inverse,
    "method for an element of an f.p. group",
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> ElementOfFpGroup( FamilyObj( obj ),
                             Inverse( UnderlyingElement( obj ) ) ) );


#############################################################################
##
#M  One( <fam> )  . . . . . . . . . . . . . for family of f.p. group elements
##
InstallOtherMethod( One,
    "method for a family of f.p. group elements",
    true,
    [ IsFamilyOfFpGroupElements ],
    0,
    fam -> ElementOfFpGroup( fam, One( fam!.freeGroup ) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( One,
    "method for an f.p. group element",
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> One( FamilyObj( obj ) ) );


#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \*,
    "method for two f.p. group elements",
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    local fam;
    fam:= FamilyObj( left );
    return ElementOfFpGroup( fam,
               UnderlyingElement( left ) * UnderlyingElement( right ) );
    end );


#############################################################################
##
#M  \=( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \=,
    "method for two f.p. group elements",
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  \<( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \<,
    "method for two f.p. group elements",
    IsIdentical,
    [ IsElementOfFpGroup,
      IsElementOfFpGroup ],
    0,
    function( left, right )
    Error( "not yet implemented" );
    end );


#############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . . . . .  for a f.p. group
##
InstallMethod( GeneratorsOfGroup,
    "method for whole family f.p. group",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,
    function( F )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( F ) );
    return List( GeneratorsOfGroup( Fam!.freeGroup ),
                 g -> ElementOfFpGroup( Fam, g ) );
    end );


#############################################################################
##
##  2. methods for f.p. groups
##

#############################################################################
##
#M  FactorFreeGroupByRelators(<F>,<rels>) .  factor of free group by relators
##
FactorFreeGroupByRelators := function( F, rels )
    local G, fam;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpGroup", IsElementOfFpGroup );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam, IsPackedWordDefaultRep );

    fam!.freeGroup := F;
    fam!.relators := Immutable( rels );

    # Create the group.
    G := Objectify(
        NewType( CollectionsFamily( fam ),
            IsSubgroupFpGroup and IsWholeFamily and IsAttributeStoringRep ),
        rec() );

    return G;
end;


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . . . . for free group and list of relators
##
InstallOtherMethod( \/,
    "method for free groups and relators",
    IsIdentical,
    [ IsFreeGroup, IsCollection ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . for free group and empty list of relators
##
InstallOtherMethod( \/,
    "method for a free group and an empty list of relators",
    true,
    [ IsFreeGroup, IsEmpty ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  AbelianInvariants(<G>) . . . .  abelian invariants of an abelian fp group
##
InstallMethod( AbelianInvariants,
    "method for ablian invariants of an abelian finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )
    local   Fam,        # elements family of <G>
            mat,        # relator matrix of <G>
            gens,       # generators of free group
            row,        # a row of <mat>
            rel,        # a relator of <G>
            g,          # a letter of <rel>
            p,          # position of <g> or its inverse in <gens>
            i;          # loop variable

    Fam := ElementsFamily( FamilyObj( G ) );
    gens := GeneratorsOfGroup( Fam!.freeGroup );

    # handle groups with no relators
    if IsEmpty( Fam!.relators ) then
        return [ 1 .. Length( gens ) ] * 0;
    fi;

    # make the relator matrix
    mat := [];
    for rel  in Fam!.relators  do
        row := [];
        for i  in [ 1 .. Length( gens ) ]  do
            row[i] := 0;
        od;
        for i  in [ 1 .. LengthWord( rel ) ]  do
            g := Subword( rel, i, i );
            p := Position( gens, g );
            if p <> fail  then
                row[p] := row[p] + 1;
            else
                p := Position( gens, g^-1 );
                row[p] := row[p] - 1;
            fi;
        od;
        Add( mat, row );
    od;

    # diagonalize the matrix
    DiagonalizeMat( mat );

    # return the abelian invariants
    return AbelianInvariantsOfList( DiagonalOfMat( mat ) );
end );


#############################################################################
##
#M  CommutatorFactorGroup( <G> )  . .  commutator factor group of an fp group
##
InstallMethod( CommutatorFactorGroup,
    "method for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )
    local   C,          # commutator factor group of <G>, result
            Fam,        # elements family of <G>
            F,          # associated free group
            gens,       # generators of <F>
            grels,      # relators of <G>
            rels,       # relators of <C>
            g, h,       # two generators of <F>
            i, k;       # loop variables

    # get the arguments
    Fam := ElementsFamily( FamilyObj( G ) );
    F := Fam!.freeGroup;
    gens := GeneratorsOfGroup( F );
    grels := Fam!.relators;

    # copy the relators of <G> and add the commutator relators
    rels := ShallowCopy( grels );
    for i in [ 1 .. Length( gens ) - 1 ] do
        g := gens[i];
        for k in [ i + 1 .. Length( gens ) ] do
            h := gens[k];
            if not ( Comm( g, h ) in rels or Comm( h, g ) in rels ) then
                Add( rels, Comm( g, h ) );
            fi;
        od;
    od;

    # make the commutator factor group and return it
    C := F / rels;
    SetIsCommutative( C, true );
    return C;

end );


#############################################################################
##
#M  CosetTableFpGroup( <G>, <H> ) . . . . . . . . . .  do a coset enumeration
##
##  'CosetTableFpGroup'   applies   a  Felsch  strategy   Todd-Coxeter  coset
##  enumeration to construct a coset table of H in G.
##
CosetTableFpGroup := function ( G, H )
    local   Fam,                    # elements family of <G>
            fgens,                  # generators of asscociated free group
            grels,                  # relators of G
            sgens,                  # subgroup generators of H
            fsgens,                 # preimages of subgroup generators in F
            next,  prev,            # next and previous coset on lists
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
            firstCoinc, lastCoinc,  # first and last coincidence coset
            table,                  # columns in the table for gens
            rels,                   # representatives of the relators
            relsGen,                # relators sorted by start generator
            subgroup,               # rows for the subgroup gens
            deductions,             # deduction queue
            i, gen, inv,            # loop variables for generator
            g,                      # loop variable for generator col
            rel,                    # loop variables for relation
            p, p1, p2,              # generator position numbers
            app,                    # arguments list for 'MakeConsequences'
            limit,                  # limit of the table
            maxlimit,               # maximal size of the table
            j,                      # integer variable
            length, length2,        # length of relator (times 2)
            cols,
            nums,
            l,
            nrdef,                  # number of defined cosets
            nrmax,                  # maximal value of the above
            nrdel,                  # number of deleted cosets
            nrinf;                  # number for next information message

    # check the arguments
    if not ( IsSubgroupFpGroup( G ) and IsWholeFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # get some local variables
    Fam := ElementsFamily( FamilyObj( G ) );
    fgens := GeneratorsOfGroup( Fam!.freeGroup );
    grels := Fam!.relators;
    sgens := GeneratorsOfGroup( H );
    fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

#@@ # check if the coset table is already available
#@@ if IsBound( H.cosetTable ) then return H.cosetTable; fi;

    # give some information
    Info( InfoFpGroup, 1, "CosetTableFromGensAndRels called:" );
    Info( InfoFpGroup, 2, "    defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    nrinf := 1000;

    # initialize size of the table
    limit    := CosetTableDefaultLimit;
    maxlimit := CosetTableDefaultMaxLimit;

    # define one coset (1)
    firstDef  := 1;  lastDef  := 1;
    firstFree := 2;  lastFree := limit;

    # make the lists that link together all the cosets
    next := [ 2 .. limit + 1 ];  next[1] := 0;  next[limit] := 0;
    prev := [ 0 .. limit - 1 ];  prev[2] := 0;

    # compute the representatives for the relators
    rels := RelatorRepresentatives( grels );

    # make the columns for the generators
    table := [];
    for gen  in fgens  do
        g := 0 * [ 1 .. limit ];
        Add( table, g );
        if not (gen^2 in rels or gen^-2 in rels) then
            g := 0 * [ 1 .. limit ];
        fi;
        Add( table, g );
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fsgens  do
        length := LengthWord( rel );
        length2 := 2 * length;
        nums := 0 * [ 1 .. length2 ];
        cols := 0 * [ 1 .. length2 ];

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

    # add an empty deduction list
    deductions := [];

    # make the structure that is passed to 'MakeConsequences'
    app := [ table, next, prev, relsGen, subgroup ];

    # run over all the cosets
    while firstDef <> 0  do

        # run through all the rows and look for undefined entries
        for i  in [ 1 .. Length( table ) ]  do
            gen := table[i];

            if gen[firstDef] = 0  then

                inv := table[i + 2*(i mod 2) - 1];

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
                    for g  in table  do g[2*limit] := 0;  od;
                    for l  in [ limit+2 .. 2*limit-1 ]  do
                        next[l] := l+1;
                        prev[l] := l-1;
                        for g  in table  do g[l] := 0;  od;
                    od;
                    next[limit+1] := limit+2;
                    prev[limit+1] := 0;
                    for g  in table  do g[limit+1] := 0;  od;
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
                gen[firstDef]   := firstFree;
                inv[firstFree]  := firstDef;
                next[lastDef]   := firstFree;
                prev[firstFree] := lastDef;
                lastDef         := firstFree;
                firstFree       := next[firstFree];
                next[lastDef]   := 0;

                # set up the deduction queue and run over it until it's empty
                app[6] := firstFree;
                app[7] := lastFree;
                app[8] := firstDef;
                app[9] := lastDef;
                app[10] := i;
                app[11] := firstDef;
                nrdel := nrdel + MakeConsequences( app );
                firstFree := app[6];
                lastFree := app[7];
                firstDef := app[8];
                lastDef  := app[9];

                # give some information
                while nrinf <= nrdef+nrdel  do
                    Info( InfoFpGroup, 2, "\t", nrdef, "\t", nrinf-nrdef,
                          "\t", 2*nrdef-nrinf, "\t", nrmax );
                    nrinf := nrinf + 1000;
                od;

            fi;
        od;

        firstDef := next[firstDef];
    od;

    Info( InfoFpGroup, 1, "\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel, "\t",
          nrmax );

    # standardize the table
    StandardizeTable( table );

    # return the table
#@@ H.cosetTable := table;
#@@ return H.cosetTable;
    return table;
end;


#############################################################################
##
#M  CosetTableFromGensAndRels( <gens>, <rels>, <sgens> )  . . . . . . . . . .
#M                                                     do a coset enumeration
##
##  'CosetTableFromGensAndRels'  applies a Felsch strategy Todd-Coxeter coset
##  enumeration to construct a coset table of H in G.
##
CosetTableFromGensAndRels := function ( fgens, grels, sgens )
    local   next,  prev,            # next and previous coset on lists
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
            firstCoinc, lastCoinc,  # first and last coincidence coset
            table,                  # columns in the table for gens
            rels,                   # representatives of the relators
            relsGen,                # relators sorted by start generator
            subgroup,               # rows for the subgroup gens
            deductions,             # deduction queue
            i, gen, inv,            # loop variables for generator
            g,                      # loop variable for generator col
            rel,                    # loop variables for relation
            p, p1, p2,              # generator position numbers
            app,                    # arguments list for 'MakeConsequences'
            limit,                  # limit of the table
            maxlimit,               # maximal size of the table
            j,                      # integer variable
            length, length2,        # length of relator (times 2)
            cols,
            nums,
            l,
            nrdef,                  # number of defined cosets
            nrmax,                  # maximal value of the above
            nrdel,                  # number of deleted cosets
            nrinf;                  # number for next information message

    # give some information
    Info( InfoFpGroup, 1, "CosetTableFromGensAndRels called:" );
    Info( InfoFpGroup, 2, "    defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    nrinf := 1000;

    # initialize size of the table
    limit    := CosetTableDefaultLimit;
    maxlimit := CosetTableDefaultMaxLimit;

    # define one coset (1)
    firstDef  := 1;  lastDef  := 1;
    firstFree := 2;  lastFree := limit;

    # make the lists that link together all the cosets
    next := [ 2 .. limit + 1 ];  next[1] := 0;  next[limit] := 0;
    prev := [ 0 .. limit - 1 ];  prev[2] := 0;

    # compute the representatives for the relators
    rels := RelatorRepresentatives( grels );

    # make the columns for the generators
    table := [];
    for gen  in fgens  do
        g := 0 * [ 1 .. limit ];
        Add( table, g );
        if not (gen^2 in rels or gen^-2 in rels) then
            g := 0 * [ 1 .. limit ];
        fi;
        Add( table, g );
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in sgens  do
        length := LengthWord( rel );
        length2 := 2 * length;
        nums := 0 * [ 1 .. length2 ];
        cols := 0 * [ 1 .. length2 ];

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

    # add an empty deduction list
    deductions := [];

    # make the structure that is passed to 'MakeConsequences'
    app := [ table, next, prev, relsGen, subgroup ];

    # run over all the cosets
    while firstDef <> 0  do

        # run through all the rows and look for undefined entries
        for i  in [ 1 .. Length( table ) ]  do
            gen := table[i];

            if gen[firstDef] = 0  then

                inv := table[i + 2*(i mod 2) - 1];

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
                    for g  in table  do g[2*limit] := 0;  od;
                    for l  in [ limit+2 .. 2*limit-1 ]  do
                        next[l] := l+1;
                        prev[l] := l-1;
                        for g  in table  do g[l] := 0;  od;
                    od;
                    next[limit+1] := limit+2;
                    prev[limit+1] := 0;
                    for g  in table  do g[limit+1] := 0;  od;
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
                gen[firstDef]   := firstFree;
                inv[firstFree]  := firstDef;
                next[lastDef]   := firstFree;
                prev[firstFree] := lastDef;
                lastDef         := firstFree;
                firstFree       := next[firstFree];
                next[lastDef]   := 0;

                # set up the deduction queue and run over it until it's empty
                app[6] := firstFree;
                app[7] := lastFree;
                app[8] := firstDef;
                app[9] := lastDef;
                app[10] := i;
                app[11] := firstDef;
                nrdel := nrdel + MakeConsequences( app );
                firstFree := app[6];
                lastFree := app[7];
                firstDef := app[8];
                lastDef  := app[9];

                # give some information
                while nrinf <= nrdef+nrdel  do
                    Info( InfoFpGroup, 2, "\t", nrdef, "\t", nrinf-nrdef,
                          "\t", 2*nrdef-nrinf, "\t", nrmax );
                    nrinf := nrinf + 1000;
                od;

            fi;
        od;

        firstDef := next[firstDef];
    od;

    Info( InfoFpGroup, 1, "\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel, "\t",
          nrmax );

    # standardize the table
    StandardizeTable( table );

    # return the table
#@@ H.cosetTable := table;
#@@ return H.cosetTable;
    return table;
end;


#############################################################################
##
#M  Display( <G> ) . . . . . . . . . . . . . . . . . . .  display an fp group
##
InstallMethod( Display,
    "method for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )
    local   Fam,        # elements family of <G>
            gens,       # generators o the free group
            rels,       # relators of <G>
            nrels,      # number of relators
            i;          # loop variable

    Fam := ElementsFamily( FamilyObj( G ) );
    gens := GeneratorsOfGroup( Fam!.freeGroup );
    rels := Fam!.relators;
    Print( "generators = ", gens, "\n" );
    nrels := Length( rels );
    Print( "relators = [" );
    if nrels > 0 then
        Print( "\n ", rels[1] );
        for i in [ 2 .. nrels ] do
            Print( ",\n ", rels[i] );
        od;
    fi;
    Print( " ]\n" );
end );


#############################################################################
##
#M  FactorGroup( <G>, <H> ) . . . . . . . . . . . . . . . make a factor group
##
##  Returns the factor group G/N of G by the normal closure N of the subgroup
##  H of G.
##
InstallMethod( FactorGroup,
    "method for a finitely presented group with a subgroup",
    IsIdentical,
    [ IsSubgroupFpGroup and IsWholeFamily, IsSubgroupFpGroup ],
    0,

function( G, H )
    # compute the factor group G/N and return it
    return FactorGroup( G, GeneratorsOfGroup( H ) );
end );


#############################################################################
##
#M  FactorGroup( <G>, <elts> ) . . . . . . . . . . . . .  make a factor group
##
##  Returns the factor group G/N of G by the normal closure N of <elts> where
##  <elts> is expected to be a list of elements of G.
##
InstallOtherMethod( FactorGroup,
    "method for a finitely presented group with a list of elements",
    IsIdentical,
    [ IsSubgroupFpGroup and IsWholeFamily, IsHomogeneousList ],
    0,

function( G, elts )
    local   Fam,        # elements family of G
            F,          # free group associated to G and to G/N
            grels,      # relators of G
            words,      # representative words in F for the elements in elts
            rels,       # relators of G/N
            g;          # loop variable

    # get some local variables
    Fam := ElementsFamily( FamilyObj( G ) );
    F := Fam!.freeGroup;
    grels := Fam!.relators;
    words := List( elts, g -> UnderlyingElement( g ) );

    # get relators for G/N
    rels := Concatenation( grels, words );

    # return the resulting factor group G/N
    return F / rels;
end );


#############################################################################
##
#F FreeGeneratorsOfFpGroup( F )
##
FreeGeneratorsOfFpGroup := function( F )
  return GeneratorsOfGroup(ElementsFamily( FamilyObj( F ) )!.freeGroup);
end;


#############################################################################
##
#F FreeGroupOfFpGroup( F )
##
FreeGroupOfFpGroup := function( F )
    return ElementsFamily( FamilyObj( F ) )!.freeGroup;
end;


#############################################################################
##
#M  IsAbelian( <G> )  . . . . . . . . . . . .  test if an fp group is abelian
##
InstallMethod( IsAbelian,
    "method for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )
    local   isAbelian,  # result
            Fam,        # elements family of <G>
            gens,       # generators of <G>
            fgens,      # generators of the associated free group
            rels,       # relators of <G>
            one,        # identity element of <G>
            g, h,       # two generators of <G>
            i, k;       # loop variables

    Fam := ElementsFamily( FamilyObj( G ) );
    gens := GeneratorsOfGroup( G );
    fgens := GeneratorsOfGroup( Fam!.freeGroup );
    rels := Fam!.relators;
    one := One( G );
    isAbelian := true;
    for i  in [ 1 .. Length( gens ) - 1 ]  do
        g := fgens[i];
        for k  in [ i + 1 .. Length( fgens ) ]  do
            h := fgens[k];
            isAbelian := isAbelian and (
                           Comm( g, h ) in rels
                           or Comm( h, g ) in rels
                           or Comm( gens[i], gens[k] ) = one
                          );
        od;
    od;
    return isAbelian;

end );


#############################################################################
##
#M  IsTrivial( <G> ) . . . . . . . . . . . . . . . . . test if <G> is trivial
##
InstallMethod( IsTrivial,
    "method for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )

    if 0 = Length( GeneratorsOfGroup( G ) )  then
        return true;
    else
        return Size( G ) = 1;
    fi;

end );


#############################################################################
##
#M  IsomorphismFpGroup( G )
##
InstallMethod( IsomorphismFpGroup, 
               "method for perm groups",
               true,
               [IsPermGroup], 
               0, 
function( G ) 
    return IsomorphismFpGroupByCompositionSeries( G, "F" );
end );


#############################################################################
##
#M  IsomorphismFpGroupByCompositionSeries( G, str )
##
InstallMethod( IsomorphismFpGroupByCompositionSeries,
               "method for permutation groups",
               true,
               [IsPermGroup, IsString],
               0,
function( G, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j, series; 

    # the solvable case
    if IsSolvableGroup( G ) then
        return IsomorphismFpGroupByPcgs( Pcgs(G), str );
    fi;

    # compute composition series
    series := CompositionSeries( G );
    l      := Length( series );

    # set up 
    H := series[l-1];
    if IsPrime( Size( H ) ) then
        gensH := Filtered( GeneratorsOfGroup( H ), 
                           x -> Order(x)=Size(H) ){[1]};
    else
        gensH := Set( GeneratorsOfGroup( H ) );
        gensH := Filtered( gensH, x -> x <> One(H) );
    fi;
    iso := IsomorphismFpGroupByGenerators( H, gensH, str );
    F := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := iso!.generators;
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free := GroupHomomorphismByImages( F, series[l-1], gensF, imgsF );
    n := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];  
        hom := NaturalHomomorphismByNormalSubgroupInParent( M );
        H := Image( hom );
        if IsPrime( Size( H ) ) then
            gensH := Filtered( GeneratorsOfGroup( H ), 
                               x -> Order(x)=Size(H) ){[1]};
        else
            gensH := Set( GeneratorsOfGroup( H ) );
            gensH := Filtered( gensH, x -> x <> One(H) );
        fi;
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        new := IsomorphismFpGroupByGenerators( H, "g", gensH );
        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );    
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;
 
        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImages( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up 
    F := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso := GroupHomomorphismByImages( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByCompositionSeries,
                    "method for perm groups",
                    true,
                    [IsPermGroup],
                    0,
function( G )
    return IsomorphismFpGroupByCompositionSeries( G, "F" );
end );


#############################################################################
##
#M  IsomorphismFpGroupByGenerators( G, gens, str )
##
InstallMethod( IsomorphismFpGroupByGenerators,
               "method for perm groups",
               true,
               [IsPermGroup, IsList, IsString],
               0,

function( G, gens, str )
    local F, gensF, hom, relators, S, gensS, iso;

    # check trivial case
    if Length( gens ) = 0 then 
        S := FreeGroup( 0 );
    elif Length( gens ) = 1 then
        F := FreeGroup( 1 );
        gensF := GeneratorsOfGroup( F );
        relators := [gensF[1]^Size(G)];
        S := F/relators;
    else
        F := FreeGroup( Length( gens ), str );
        gensF := GeneratorsOfGroup( F );
        hom := GroupHomomorphismByImages( G, F, gens, gensF );
        relators := CoKernelGensPermHom( hom );
        S := F / relators;
    fi;
    gensS := GeneratorsOfGroup( S );
    iso := GroupHomomorphismByImages( G, S, gens, gensS );
    SetIsSurjective( iso, true );
    SetIsInjective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ));
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByGenerators,
               "method for perm groups",
               true,
               [IsPermGroup, IsList],
               0,
function( G, gens )
    return IsomorphismFpGroupByGenerators( G, gens, "F" );
end );

               
#############################################################################
##
#M  IsomorphismFpGroupBySubnormalSeries( G, series, str )
##
InstallMethod( IsomorphismFpGroupBySubnormalSeries,
               "method for groups",
               true,
               [IsPermGroup, IsList, IsString],
               0,
function( G, series, str )
    local l, H, gensH, iso, F, gensF, imgsF, relatorsF, free, n, k, N, M,
          hom, preiH, c, new, T, gensT, E, gensE, imgsE, relatorsE, rel,
          w, t, i, j; 

    # set up with smallest subgroup of series
    l      := Length( series );
    H := series[l-1];
    gensH := Set( GeneratorsOfGroup( H ) );
    gensH := Filtered( gensH, x -> x <> One(H) );
    iso   := IsomorphismFpGroupByGenerators( H, gensH, str );
    F     := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := iso!.generators;
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free  := GroupHomomorphismByImages( F, series[l-1], gensF, imgsF );
    n     := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];  
        hom   := NaturalHomomorphismByNormalSubgroup( N, M );
        H     := Image( hom );
        gensH := Set( GeneratorsOfGroup( H ) );
        gensH := Filtered( gensH, x -> x <> One(H) );
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        new := IsomorphismFpGroupByGenerators( H, "g", gensH );
        T   := Image( new );
        gensT := GeneratorsOfGroup( FreeGroupOfFpGroup( T ) );

        # create new free group
        E     := FreeGroup( n+c, str );
        gensE := GeneratorsOfGroup( E );
        imgsE := Concatenation( preiH, imgsF );
        relatorsE := [];

        # modify presentation of H
        for rel in RelatorsOfFpGroup( T ) do
            w := MappedWord( rel, gensT, gensE{[1..c]} );    
            t := MappedWord( rel, gensT, imgsE{[1..c]} );
            if not t = One( G ) then
                t := PreImagesRepresentative( free, t );
                t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
            else
                t := One( E );
            fi;
            Add( relatorsE, w/t );
        od;

        # add operation of T on F
        for i in [1..c] do
            for j in [1..n] do
                w := Comm( gensE[c+j], gensE[i] );
                t := Comm( imgsE[c+j], imgsE[i] );
                if not t = One( G ) then
                    t := PreImagesRepresentative( free, t );
                    t := MappedWord( t, gensF, gensE{[c+1..n+c]} );
                else
                    t := One( E );
                fi;
                Add( relatorsE, w/t );
            od;
        od;
 
        # append relators of F
        for rel in relatorsF do
            w := MappedWord( rel, gensF, gensE{[c+1..c+n]} );
            Add( relatorsE, w );
        od;

        # iterate
        F := E;
        gensF := gensE;
        imgsF := imgsE;
        relatorsF := relatorsE;
        free :=  GroupHomomorphismByImages( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up 
    F     := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso   := GroupHomomorphismByImages( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end);

InstallOtherMethod( IsomorphismFpGroupBySubnormalSeries,
               "method for groups",
               true,
               [IsPermGroup, IsList],
               0,
function( G, series )
    return IsomorphismFpGroupBySubnormalSeries( G, series, "F" );
end);


#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallMethod( MappedWord, true,
    [ IsElementOfFpGroup, IsList, IsList ], 0,
    function( x, gens1, gens2 )
    local i, mapped, exp;

    gens1:= List( gens1, x -> ExtRepOfObj( x )[1] );
    x:= ExtRepOfObj( x );
    if Length( x ) = 0 then
      mapped:= gens2[1] ^ 0;
    else
      mapped:= gens2[ Position( gens1, x[1] ) ] ^ x[2];
      for i in [ 2 .. Length( x )/2 ] do
        exp:= x[ 2*i ];
        if exp <> 0 then
          mapped:= mapped * gens2[ Position( gens1, x[ 2*i-1 ] ) ] ^ exp;
        fi;
      od;
    fi;

    return mapped;
    end );


#############################################################################
##
#F  MostFrequentGeneratorFpGroup( <G> ) . . . . . . . most frequent generator
##
##  'MostFrequentGeneratorFpGroup'  returns the  first of those generators of
##  the given finitely  presented group  which occurs most frequently  in the
##  relators.
##
MostFrequentGeneratorFpGroup := function ( G )

    local altered, Fam, gens, gens2, i, i1, i2, k, max, j, num, numgens,
          numrels, occur, power, rel, relj, rels, set;

#@@ # check the first argument to be a finitely presented group.
#@@ if not ( IsRec( G ) and IsBound( G.isFpGroup ) and G.isFpGroup ) then
#@@     Error( "argument must be a finitely presented group" );
#@@ fi;

    # Get some local variables.
    Fam := ElementsFamily( FamilyObj( G ) );
    gens := GeneratorsOfGroup( Fam!.freeGroup );
    rels := Fam!.relators;
    numgens := Length( gens );
    numrels := Length( rels );

    # Initialize a counter.
    occur := 0 * [ 1 .. numgens ];
    power := 0 * [ 1 .. numgens ];

    # initialize a list of the generators and their inverses
    gens2 := 0 * [ 1 .. 2 * numgens ];
    for i in [ 1 .. numgens ] do
        gens2[i] := gens[i];
        gens2[numgens+i] := gens[i]^-1;
    od;

    # convert the relators to vectors of generator numbers and count their
    # occurrences.
    for j in [ 1 .. numrels ] do
        # convert the j-th relator to a Tietze relator
        relj := rels[j];
        i1 := 1;
        i2 := LengthWord( relj );
        while i1 < i2 and
            Subword( relj, i1, i1 ) = Subword( relj, i2, i2 )^-1 do 
            i1 := i1 + 1;
            i2 := i2 - 1;
        od;
        rel := List( [ i1 .. i2 ],
            i -> Position( gens2, Subword( relj, i, i ) ) );
        # count the occurrences of the generators in rel
        for i in [ 1 .. Length( rel ) ] do
            k := rel[i];
            if k = fail then
                Error( "given relator is not a word in the generators" );
            elif k <= numgens then
                occur[k] := occur[k] + 1;
            else
                k := k - numgens;
                rel[i] := -k;
                occur[k] := occur[k] + 1;
            fi;
        od;
        # check the current relator for being a power relator.
        set := Set( rel );
        if Length( set ) = 2 then
            num := [ 0, 0 ];
            for i in rel do
                if i = set[1] then num[1] := num[1] + 1;
                else num[2] := num[2] + 1; fi;
            od;
            if num[1] = 1 then
                power[AbsInt( set[2] )] := AbsInt( set[1] );
            elif num[2] = 1 then
                power[AbsInt( set[1] )] := AbsInt( set[2] );
            fi;
        fi;
    od;

    # increase the occurrences numbers of generators which are roots of
    # other ones, but avoid infinite loops.
    i := 1;
    altered := true;
    while altered do
        altered := false;
        for j in [ i .. numgens ] do
            if power[j] > 0 and power[power[j]] = 0 then
                occur[j] := occur[j] + occur[power[j]];
                power[j] := 0;
                altered := true;
                if i = j then i := i + 1; fi;
            fi;
        od;
    od;

    # find the most frequently occurring generator and return it.
    i := 1;
    max := occur[1];
    for j in [ 2 .. numgens ] do
        if occur[j] > max then
            i := j;
            max := occur[j];
        fi;
    od;
    gens := GeneratorsOfGroup( G );
    return gens[i];
end;


#############################################################################
##
#M  PreImagesRepresentative
##
InstallMethod( PreImagesRepresentative,
  "hom. to standard generators of fp group, using 'MappedWord'",
  FamRangeEqFamElm,
  [IsToFpGroupHomomorphismByImages,IsMultiplicativeElementWithInverse],0,
function(hom,elm)
  if not IsIdentical(hom!.genimages,GeneratorsOfGroup(Range(hom))) then
    # check, whether we map to the standard generators
    TryNextMethod();
  fi;
  return MappedWord(elm,hom!.genimages,hom!.generators);
end);


#############################################################################
##
#M  RelatorRepresentatives(<rels>) . set of representatives of a list of rels
##
##  'RelatorRepresentatives' returns a set of  relators,  that  contains  for
##  each relator in the list <rels> its minimal cyclical  permutation  (which
##  is automatically cyclically reduced).
##
RelatorRepresentatives := function ( rels )
    local   cyc, i, length, min, rel, reps;

    reps := [];

    # loop over all nontrivial relators
    for rel in rels  do
        length := LengthWord(rel);
        if length > 0  then

            # find the minimal cyclic permutation
            cyc := rel;
            min := cyc;
            for i  in [ 1 .. length - 1 ]  do
                cyc := cyc ^ Subword( rel, i, i );
                if cyc    < min  then min := cyc;     fi;
                if cyc^-1 < min  then min := cyc^-1;  fi;
            od;

            # if the relator is new, add it to the representatives
            if not min in reps  then
                AddSet( reps, min );
            fi;

        fi;
    od;

    # return the representatives
    return reps;
end;


#############################################################################
##
#F RelatorsOfFpGroup( F )
##
RelatorsOfFpGroup := function( F )
    return ElementsFamily( FamilyObj( F ) )!.relators;
end;


#############################################################################
##
#M  RelsSortedByStartGen( <gens>, <rels>, <table> [, <ignore> ] )
#M                                         relators sorted by start generator
##
##  'RelsSortedByStartGen'  is a  subroutine of the  Felsch Todd-Coxeter  and
##  the  Reduced Reidemeister-Schreier  routines. It returns a list which for
##  each  generator or  inverse generator  contains a list  of all cyclically
##  reduced relators,  starting  with that element,  which can be obtained by
##  conjugating or inverting given relators.  The relators are represented as
##  lists of the coset table columns corresponding to the generators and,  in
##  addition, as lists of the respective column numbers.
##
##  Square relators  will be ignored  if ignore = true.  The default value of
##  ignore is true.
##
RelsSortedByStartGen := function ( arg )
    local   gens,                       # group generators
            rels,                       # relators
            table,                      # coset table
            ignore,                     # if true, ignore square relators
            relsGen,                    # resulting list
            rel, cyc,                   # one relator and cyclic permutation
            length, extleng,            # length and extended length of rel
            base, base2,                # base length of rel
            gen,                        # one generator in rel
            nums, invnums,              # numbers list and inverse
            cols, invcols,              # columns list and inverse
            p, p1, p2,                  # positions of generators
            i, j, k;                    # loop variables

    # get the arguments
    gens := arg[1];
    rels := arg[2];
    table := arg[3];
    ignore := true;
    if  Length( arg ) > 3 then  ignore := arg[4];  fi;

    # check that the table has the right number of columns
    if 2 * Length(gens) <> Length(table) then
        Error( "table length is inconsistent with number of generators" );
    fi;

    # check that involutory generators have identical table columns
    if ignore then
        for i  in [ 1 .. Length(gens) ]  do
            if    (    (gens[i]^2 in rels or gens[i]^-2 in rels)
                and not IsIdentical( table[2*i-1], table[2*i] ))
               or (not (gens[i]^2 in rels or gens[i]^-2 in rels)
                and     IsIdentical( table[2*i-1], table[2*i] ))
            then
                Error( "table inconsistent with square relators" );
            fi;
        od;
    fi;

    # initialize the list to be constructed
    relsGen := 0 * [ 1 .. 2*Length(gens) ];
    for i  in [ 1 .. Length(gens) ]  do
        relsGen[ 2*i-1 ] := [];
        if not IsIdentical( table[ 2*i-1 ], table[ 2*i ] )  then
            relsGen[ 2*i ] := [];
        else
            relsGen[ 2*i ] := relsGen[ 2*i-1 ];
        fi;
    od;

    # now loop over all parent group relators
    for rel  in rels  do

        # get the length and the basic length of relator rel
        length := LengthWord( rel );
        base := 1;
        cyc := rel ^ Subword( rel, base, base );
        while cyc <> rel do
            base := base + 1;
            cyc := cyc ^ Subword( rel, base, base );
        od;

        # ignore square relators
        if length <> 2 or base <> 1 or not ignore then

            # initialize the columns and numbers lists corresponding to the
            # current relator
            base2 := 2 * base;
            extleng := 2 * ( base + length ) - 1;
            nums := 0 * [1 .. extleng];  invnums := 0 * [1 .. extleng];
            cols := 0 * [1 .. extleng];  invcols := 0 * [1 .. extleng];

            # compute the lists
            i := 0;  j := 1;  k := base2 + 3;
            while i < base do
                i := i + 1;  j := j + 2;  k := k - 2;
                gen := Subword( rel, i, i );
                p := Position( gens, gen );
                if p = fail then
                    p := Position( gens, gen^-1 );
                    p1 := 2 * p;
                    p2 := 2 * p - 1;
                else
                    p1 := 2 * p - 1;
                    p2 := 2 * p;
                fi;
                nums[j]   := p1;         invnums[k-1] := p1;
                nums[j-1] := p2;         invnums[k]   := p2;
                cols[j]   := table[p1];  invcols[k-1] := table[p1];
                cols[j-1] := table[p2];  invcols[k]   := table[p2];
                Add( relsGen[p1], [ nums, cols, j ] );
                Add( relsGen[p2], [ invnums, invcols, k ] );
            od;

            while j < extleng do
                j := j + 1;
                nums[j] := nums[j-base2];  invnums[j] := invnums[j-base2];
                cols[j] := cols[j-base2];  invcols[j] := invcols[j-base2];
            od;

            nums[1] := length;          invnums[1] := length;
            cols[1] := 2 * length - 3;  invcols[1] := cols[1];
        fi;
    od;

    # return the list
    return relsGen;
end;


#############################################################################
##
#M  Size( <G> )  . . . . . . . . . . . . . size of a finitely presented group
##
InstallMethod( Size,
    "method for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsWholeFamily ],
    0,

function( G )
    local   Fam,        # elements family of <G>
            fgens,      # generators of the free group
            rels,       # relators of <G>
            H,          # subgroup of <G>
            T;          # coset table of <G> by <H>

        Fam := ElementsFamily( FamilyObj( G ) );
        fgens := GeneratorsOfGroup( Fam!.freeGroup );
        rels := Fam!.relators;
    
        # handle free and trivial group
        if 0 = Length( fgens ) then
            return 1;
        elif 0 = Length(rels) then
            return infinity;
    
        # handle nontrivial fp group by computing the index of its trivial
        # subgroup
        else
            H := Subgroup( G, [ MostFrequentGeneratorFpGroup( G ) ] );
            T := AugmentedCosetTableMtc( G, H, -1, "_x" );
            if T.exponent = infinity then
                return infinity;
            else
                return T.index * T.exponent;
            fi;
        fi;

end );


#############################################################################
##
#E  grpfp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

