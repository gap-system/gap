#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Volkmar Felsch.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains  the methods for  subgroup presentations  in finitely
##  presented groups (fp groups).
##


#############################################################################
##
#M  AbelianInvariantsNormalClosureFpGroupRrs( <G>, <H> )  . . . . . . . . . .
#M  . . . . . abelian invariants of the normal closure of the subgroup H of G
##
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of the normal closure of a subgroup <H> of a finitely
##  presented group <G>.
##
InstallGlobalFunction( AbelianInvariantsNormalClosureFpGroupRrs,
function ( G, H )
local M;
  M:=RelatorMatrixAbelianizedNormalClosureRrs( G, H );
  if Length(M)=0 then
    return [];
  else
    M:=ReducedRelationMat(M);
    DiagonalizeMat( Integers, M );
    return AbelianInvariantsOfList(DiagonalOfMat(M));
  fi;
end );


#############################################################################
##
#M  AbelianInvariantsSubgroupFpGroupMtc( <G>, <H> ) . . . . . . . . . . . . .
#M  . . . . . abelian invariants of the normal closure of the subgroup H of G
##
##  uses the Modified Todd-Coxeter method to compute the abelian
##  invariants of a subgroup <H> of a finitely presented group <G>.
##
InstallGlobalFunction( AbelianInvariantsSubgroupFpGroupMtc,
function ( G, H )
local M;
  M:=RelatorMatrixAbelianizedSubgroupMtc( G, H );
  if Length(M)=0 then
    return [];
  else
    M:=ReducedRelationMat(M);
    DiagonalizeMat( Integers, M );
    return AbelianInvariantsOfList(DiagonalOfMat(M));
  fi;
end );


#############################################################################
##
#M  AbelianInvariantsSubgroupFpGroupRrs( <G>, <H> ) . . . . . . . . . . . . .
#M  AbelianInvariantsSubgroupFpGroupRrs( <G>, <costab> ) . . .  . . . . . . .
#M  . . . . . abelian invariants of the normal closure of the subgroup H of G
##
##  uses the Reduced Reidemeister-Schreier method to compute the abelian
##  invariants of a subgroup <H> of a finitely presented group <G>.
##
##  Alternatively to the subgroup <H>, its coset table <table> in <G> may be
##  given as second argument.
##
InstallGlobalFunction( AbelianInvariantsSubgroupFpGroupRrs,
function ( G, H )
local M;
  M:=RelatorMatrixAbelianizedSubgroupRrs( G, H );
  if M=fail then
    if ValueOption("cheap")=true then return fail;fi;
    Info(InfoWarning,1,
      "exponent too large, abelianized coset enumeration aborted");
    Info(InfoWarning,1,"calculation will be slow");
    M:=MaximalAbelianQuotient(H); # this is in the library, so no overflow
    return AbelianInvariants(Range(M));
  elif Length(M)=0 then
    return [];
  else
    M:=ReducedRelationMat(M);
    DiagonalizeMat( Integers, M );
    return AbelianInvariantsOfList(DiagonalOfMat(M));
  fi;
end );


#############################################################################
##
#M  AugmentedCosetTableInWholeGroup
##
InstallGlobalFunction(AugmentedCosetTableInWholeGroup,
function(arg)
local aug,H,wor,w;
  H:=arg[1];
  if Length(arg)=1 then
    return AugmentedCosetTableRrsInWholeGroup(H);
  fi;
  wor:=List(arg[2],UnderlyingElement); # words for given elements
  # is there an MTc table we can use?
  if HasAugmentedCosetTableMtcInWholeGroup(H) then
    aug := AugmentedCosetTableMtcInWholeGroup( H );
    if IsSubset(aug.primaryGeneratorWords,wor) or
       IsSubset(SecondaryGeneratorWordsAugmentedCosetTable(aug),wor) then
      return aug;
    fi;
  fi;
  # try the Rrs table
  aug := AugmentedCosetTableRrsInWholeGroup( H );
  if IsSubset(aug.primaryGeneratorWords,wor) or
      IsSubset(SecondaryGeneratorWordsAugmentedCosetTable(aug),wor) then
    return aug;
  fi;

  # still not: need completely new table
  w:=FamilyObj(H)!.wholeGroup;
  aug:=AugmentedCosetTableMtc(w,SubgroupNC(w,arg[2]),2,"y" );

  return aug;
end);


#############################################################################
##
#M  AugmentedCosetTableMtcInWholeGroup
##
InstallMethod( AugmentedCosetTableMtcInWholeGroup,
  "subgroup of fp group", true, [IsSubgroupFpGroup], 0,
function( H )
  local G, aug;
  G := FamilyObj( H )!.wholeGroup;
  aug := AugmentedCosetTableMtc( G, H, 2, "y" );
  return aug;
end);


#############################################################################
##
#M  AugmentedCosetTableRrsInWholeGroup
##
InstallMethod( AugmentedCosetTableRrsInWholeGroup,
  "subgroup of fp group", true, [IsSubgroupFpGroup], 0,
function( H )
  local G, costab, fam, aug, gens;
  G := FamilyObj( H )!.wholeGroup;
  costab := CosetTableInWholeGroup( H );
  aug := AugmentedCosetTableRrs( G, costab, 2, "y" );

  # if H has not yet any generators, we store them (and then also can store
  # the coset table as Mtc table)
  if not (HasGeneratorsOfGroup(H)
          or HasAugmentedCosetTableMtcInWholeGroup(H)) then
    SetAugmentedCosetTableMtcInWholeGroup(H,aug);
    gens := aug.primaryGeneratorWords;
    # do we need to wrap?
    if not IsFreeGroup( G ) then
      fam := ElementsFamily( FamilyObj( H ) );
      gens := List( gens, i -> ElementOfFpGroup( fam, i ) );
    fi;
    SetGeneratorsOfGroup( H, gens );
  fi;

  return aug;
end);

#############################################################################
##
#M  AugmentedCosetTableNormalClosureInWholeGroup( <H> ) . . . augmented coset
#M           table of the normal closure of an fp subgroup in its whole group
##
##  is equivalent to `AugmentedCosetTableNormalClosure( <G>, <H> )' where <G>
##  is the  (unique) finitely presented group  such that <H> is a subgroup of
##  <G>.
##
InstallMethod( AugmentedCosetTableNormalClosureInWholeGroup,
  "subgroup of fp group", true, [IsSubgroupFpGroup], 0,
function( H )
  local G, costab, aug;

  # get the whole group G of H
  G := FamilyObj( H )!.wholeGroup;

  # compute a coset table of the normal closure N of H in G
  costab := CosetTableNormalClosureInWholeGroup( H );

  # apply the Reduced Reidemeister-Schreier method to construct an
  # augmented coset table of N in G
  aug := AugmentedCosetTableRrs( G, costab, 2, "%" );

  return aug;
end );


#############################################################################
##
#M  AugmentedCosetTableMtc( <G>, <H>, <type>, <string> )  . . . . . . . . . .
#M  . . . . . . . . . . . . .  do an MTC and return the augmented coset table
##
##  is an internal function used by the subgroup presentation functions
##  described in "Subgroup Presentations". It applies a Modified Todd-Coxeter
##  coset representative enumeration to construct an augmented coset table
##  (see "Subgroup presentations") for the given subgroup <H> of <G>. The
##  subgroup generators will be named <string>1, <string>2, ... .
##
##  Valid types are 1 (for the one generator case), 0 (for the abelianized
##  case), and 2 (for the general case). A type value of -1 is handled in
##  the same way as the case type = 1, but the function will just return the
##  the exponent <aug>.exponent of the given cyclic subgroup <H> and its
##  index <aug>.index in <G> as the only components of the resulting record
##  <aug>.
##
InstallGlobalFunction( AugmentedCosetTableMtc,
    function ( G, H, ttype, string )

    # check the arguments
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    return NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(G),
            RelatorsOfFpGroup(G),GeneratorsOfGroup(H),true);
end );





#############################################################################
##
#M  AugmentedCosetTableRrs( <G>, <coset table>, <type>, <string> )  . . . . .
#M                              do a RRS and return the augmented coset table
##
##  'AugmentedCosetTableRrs' applies the Reduced Reidemeister-Schreier method
##  to construct an  augmented coset table  for the  subgroup of  G  which is
##  defined by the  given coset table.  The new  subgroup generators  will be
##  named  <string>1, <string>2, ... .
##
InstallGlobalFunction( AugmentedCosetTableRrs,
    function ( G, table, type, string )

    local   fgens,                  # generators of associated free group
            grels,                  # relators of G
            involutions,            # indices of involutory gens of G
            index,                  # index of the group in the parent group
            cosTable,               # coset table
            negTable,               # coset table to be built up
            coFacTable,             # coset factor table
            numcols,                # number of columns in the tables
            numgens,                # number of generators
            F,                      # a new free group
            span,                   # spanning tree
            ggens,                  # parent group gens prallel to columns
            gens,                   # new generators
            ngens,                  # number of new generators
            defs,                   # definitions of primary subgroup gens
            tree,                   # tree of generators
            tree1, tree2,           # components of tree of generators
            treelength,             # number of gens (primary + secondary)
            rels,                   # representatives for the relators
            relsGen,                # relators beginning with a gen
            deductions,             # deduction queue
            ded,                    # index of current deduction in above
            nrdeds,                 # current number of deductions in above
            i, ii, gen, inv,        # loop variables for generator
            triple,                 # loop variable for relators as triples
            word, factors,          # words defining subgroup generators
            app,                    # application stack for 'ApplyRel'
            app2,                   # application stack for 'ApplyRel2'
            j, k,                   # loop variables
            fac,                    # tree entry
            count,                  # number of negative table entries
            next,                   #
            numoccs,                # number of gens which occur in the table
            occur,                  #
            treeNums,               #
            convert,                # conversion list for subgroup generators
            aug,                    # augmented coset table
            field,                  # loop variable for record field names
            EnterDeduction,         # subroutine
            LoopOverAllCosets;      # subroutine


  EnterDeduction := function ( )

    # a deduction has been found, check the current coset table entry.
    # if triple[2][app[1]][app[2]] <> -app[4] or
    #     triple[2][app[3]][app[4]] <> -app[2] then
    #     Error( "unexpected coset table entry" );
    # fi;

    # compute the corresponding factors in "factors".
    app2[1] := triple[3];
    app2[2] := deductions[ded][2];
    app2[3] := -1;
    app2[4] := app2[2];
    if not ApplyRel2( app2, triple[2], triple[1] ) then
      return fail; # rewriting failed b/c too large exponent
    fi;
    factors := app2[7];
#if Length(factors)>0 then Print(Length(factors)," ",Maximum(factors)," ",Minimum(factors),"\n");fi;

    # ensure that the scan provided a deduction.
    # if app2[1] - 1 <> app2[3]
    # or triple[2][app2[1]][app2[2]] <> - app2[4]
    # or triple[2][app2[3]][app2[4]] <> - app2[2]
    # then
    #     Error( "the given scan does not provide a deduction" );
    # fi;

    # extend the tree to define a proper factor, if necessary.
    fac := TreeEntry( tree, factors );

    # now enter the deduction to the tables.
    triple[2][app2[1]][app2[2]] := app2[4];
    coFacTable[triple[1][app2[1]]][app2[2]] := fac;
    triple[2][app2[3]][app2[4]] := app2[2];
    coFacTable[triple[1][app2[3]]][app2[4]] := - fac;
    nrdeds := nrdeds + 1;
    deductions[nrdeds] := [ triple[1][app2[1]], app2[2] ];
    treelength := tree[3];
    count := count - 2;
  end;

  LoopOverAllCosets:=function()
    # loop over all the cosets
    for j in [ 1 .. index ] do
      CompletionBar(InfoFpGroup,2,"Coset Loop: ",j/index);

        # run through all the rows and look for negative entries
        for i  in [ 1 .. numcols ]  do
            gen := negTable[i];

            if gen[j] < 0  then

                # add the current Schreier generator to the set of new
                # subgroup generators, and add the definition as deduction.
                k := - gen[j];
                word := ggens[i];
                while k > 1 do
                   word := word * ggens[span[2][k]]^-1;  k := span[1][k];
                od;
                k := j;
                while k > 1 do
                   word := ggens[span[2][k]] * word;  k := span[1][k];
                od;
                numgens := numgens + 1;
                defs[numgens] := word;
                treelength := treelength + 1;
                tree[3] := treelength;
                tree[4] := numgens;
                if type = 0 then
                    tree1[treelength] :=
                        ListWithIdenticalEntries( numgens, 0 );
                    tree1[treelength][numgens] := 1;
                    tree2[numgens] := 0;
                else
                    tree1[treelength] := 0;
                    tree2[treelength] := 0;
                fi;

                # add the definition as deduction.
                inv := negTable[i + 2*(i mod 2) - 1];
                k := - gen[j];
                gen[j] := k;
                coFacTable[i][j] := treelength;
                if inv[k] < 0 then
                    inv[k] := j;
                    ii := i + 2*(i mod 2) - 1;
                    coFacTable[ii][k] := - treelength;
                fi;
                count := count - 2;

                # set up the deduction queue and run over it until it's empty
                deductions:=[];
                deductions[1] := [i,j];
                nrdeds := 1;
                ded := 1;
                while ded <= nrdeds  do

                    # apply all relators that start with this generator
                    for triple in relsGen[deductions[ded][1]] do
                        app[1] := triple[3];
                        app[2] := deductions[ded][2];
                        app[3] := -1;
                        app[4] := app[2];
                        if ApplyRel( app, triple[2] ) and
                            triple[2][app[1]][app[2]] < 0 and
                            triple[2][app[3]][app[4]] < 0 then
                            # a deduction has been found: compute the
                            # corresponding factor and enter the deduction to
                            # the tables and to the deductions lists.
                            EnterDeduction( );
                            if count <= 0 then
                              return;
                            fi;
                        fi;
                    od;

                    ded := ded + 1;
                od;

            fi;
        od;
    od;
  end;



    # check G to be a finitely presented group.
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;

    # check the type for being 0 or 2.
    if type <> 0 and type <> 2 then
        Error( "invalid type; it should be 0 or 2" );
    fi;

    # get some local variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );

    # check the number of columns of the given coset table to be twice the
    # number of generators of the parent group G.
    numcols := Length( table );
    if numcols <> 2 * Length( fgens ) then
        Error( "parent group and coset table are inconsistent" );
    fi;
    index  := IndexCosetTab( table );

    # get a negative copy of the coset table, and initialize the coset factor
    # table (parallel to it) by zeros.
    involutions := IndicesInvolutaryGenerators( G );
    if Length( involutions ) = 0 then
        cosTable := table;
    else
        cosTable := [ ];
        for i in [ 1 .. Length( fgens ) ] do
            cosTable[2*i-1] := table[2*i-1];
            if i in involutions then
                cosTable[2*i] := table[2*i-1];
            else
                cosTable[2*i] := table[2*i];
            fi;
        od;
    fi;
    negTable := [ ];
    coFacTable := [ ];
    for i in [ 1 .. Length( fgens ) ] do
        negTable[2*i-1] := List( cosTable[2*i-1], x -> -x );
        coFacTable[2*i-1] := ListWithIdenticalEntries( index, 0 );
        if i in involutions then
            negTable[2*i] := negTable[2*i-1];
            coFacTable[2*i] := coFacTable[2*i-1];
        else
            negTable[2*i] := List( cosTable[2*i], x -> -x );
            coFacTable[2*i] := ListWithIdenticalEntries( index, 0 );
        fi;
    od;
    count := index * ( numcols - 2 ) + 2;

    # construct the list relsGen which for each generator or inverse
    # generator contains a list of all cyclically reduced relators,
    # starting with that element, which can be obtained by conjugating or
    # inverting given relators. The relators in relsGen are represented as
    # lists of the coset table columns corresponding to the generators and,
    # in addition, as lists of the respective column numbers.
    rels := RelatorRepresentatives( grels );
    relsGen := RelsSortedByStartGen( fgens, rels, negTable, true );
    SortRelsSortedByStartGen( relsGen );

    # check the number of columns to be twice the number of generators of
    # the parent group G.
    if numcols <> 2 * Length( fgens ) then
        Error( "parent group and coset table are inconsistent" );
    fi;

    # initialize the tree of secondary generators.
    tree1 := ListWithIdenticalEntries( 100, 0 );
    if type = 0 then
        tree2 := [ ];
    else
        tree2 := ListWithIdenticalEntries( 100, 0 );
    fi;
    treelength := 0;
    tree := [ tree1, tree2, treelength, 0, type ];

    # initialize an empty deduction list
    deductions := [ ]; deductions[index] := 0;
    nrdeds := 0;

    # get a spanning tree for the cosets
    span := SpanningTree( cosTable );

    # enter the coset definitions into the coset table.
    for k in [ 2 .. index ] do

        j := span[1][k];
        i := span[2][k];
        ii := i + 2*(i mod 2) - 1;

        # check the current table entry.
        if negTable[i][j] <> - k or negTable[ii][k] <> -j then
            Error( "coset table and spanning tree are inconsistent" );
        fi;

        # enter the deduction.
        negTable[i][j] := k;
        if negTable[ii][k] < 0 then  negTable[ii][k] := j;  fi;
        nrdeds := nrdeds + 1;
        deductions[nrdeds] := [i,j];
    od;

    # make the local structures that are passed to 'ApplyRel' or, via
    # EnterDeduction, to 'ApplyRel2".
    app := ListWithIdenticalEntries( 4, 0 );
    app2 := ListWithIdenticalEntries( 9, 0 );
    if type = 0 then
        factors := tree2;
    else
        factors := [ ];
    fi;

    # set those arguments of ApplyRel2 which are global with respect to the
    # following loops.
    app2[5] := type;
    app2[6] := coFacTable;
    app2[7] := factors;
    if type = 0 then
        app2[8] := tree;
    fi;

    # set up the deduction queue and run over it until it's empty
    ded := 1;
    while ded <= nrdeds  do
      if ded mod 50=0 then
        CompletionBar(InfoFpGroup,2,"Queue: ",ded/nrdeds);
      fi;

        # apply all relators that start with this generator
        for triple in relsGen[deductions[ded][1]] do
            app[1] := triple[3];
            app[2] := deductions[ded][2];
            app[3] := -1;
            app[4] := app[2];
            if ApplyRel( app, triple[2] ) and triple[2][app[1]][app[2]] < 0
                and triple[2][app[3]][app[4]] < 0  then
                # a deduction has been found: compute the corresponding
                # factor and enter the deduction to the tables and to the
                # deductions lists.
                EnterDeduction( );
            fi;
        od;

        ded := ded + 1;
    od;
    CompletionBar(InfoFpGroup,2,"Queue: ",false);

    # get a list of the parent group generators parallel to the table
    # columns.
    ggens := [ ];
    for i in [ 1 .. numcols/2 ] do
        ggens[2*i-1] := fgens[i];
        ggens[2*i] := fgens[i]^-1;
    od;

    # initialize the list of new subgroup generators
    numgens := 0;
    defs := [ ];

    # loop over cosets
    LoopOverAllCosets();
    CompletionBar(InfoFpGroup,2,"Coset Loop: ",false);

    # save the number of primary subgroup generators and the number of all
    # subgroup generators in the tree.
    tree[3] := treelength;

    # get an immutable coset table with no two columns identical.
    if IsMutable( table ) then
        cosTable := Immutable( table );
    else
        cosTable := table;
    fi;

    # separate pairs of identical columns in the coset factor table.
    for i in [ 1 .. Length( fgens ) ] do
        if i in involutions then
            coFacTable[2*i] := StructuralCopy( coFacTable[2*i-1] );
        fi;
    od;

    # create the augmented coset table record.
    aug := rec( );
    aug.isAugmentedCosetTable := true;
    aug.type := type;
    aug.tableType := TABLE_TYPE_RRS;
    aug.groupGenerators := fgens;
    aug.groupRelators := grels;
    aug.cosetTable := cosTable;
    aug.cosetFactorTable := coFacTable;
    aug.primaryGeneratorWords := defs;
    aug.tree := tree;

    # renumber the generators such that the primary ones precede the
    # secondary ones, and sort the tree and the factor table accordingly.
    if type = 2 then
        RenumberTree( aug );

        # determine which generators occur in the augmented table.
        occur := ListWithIdenticalEntries( treelength, 0 );
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
        ngens := numgens;
        treeNums := [ 1 .. numoccs ];
        for j in [ numgens+1 .. treelength ] do
            if occur[j] <> 0 then
                ngens := ngens + 1;
                treeNums[ngens] := j;
            fi;
        od;
        aug.treeNumbers := treeNums;

        # get ngens new generators
        F := FreeGroup( ngens, string );
        gens := GeneratorsOfGroup( F );

        # prepare a conversion list for the subgroup generator numbers if
        # they do not all occur in the subgroup relators.
        numgens := Length( gens );
        if numgens < treelength then
            convert := ListWithIdenticalEntries( treelength, 0 );
            for i in [ 1 .. numgens ] do
                convert[treeNums[i]] := i;
            od;
            aug.conversionList := convert;
        fi;
        aug.numberOfSubgroupGenerators := ngens;
        aug.nameOfSubgroupGenerators := Immutable( string );
        aug.subgroupGenerators := gens;
    fi;

    # ensure that all components of the augmented coset table are immutable.
    for field in RecNames( aug ) do
      MakeImmutable( aug.(field) );
    od;

    # display a message
    numgens := Length( defs );
    Info( InfoFpGroup, 1, "RRS defined ", numgens, " primary and ",
        treelength - numgens, " secondary subgroup generators" );

    # return the augmented coset table.
    return aug;
end );


#############################################################################
##
#M  AugmentedCosetTableNormalClosure( <G>, <H> )  . . . augmented coset table
#M          of the normal closure of a subgroup in a finitely presented group
##
InstallMethod( AugmentedCosetTableNormalClosure,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
    0,
function( G, H );

    if G <> FamilyObj( H )!.wholeGroup then
        Error( "<H> must be a subgroup of <G>" );
    fi;
    return AugmentedCosetTableNormalClosureInWholeGroup( H );

end );


#############################################################################
##
#M  CosetTableBySubgroup(<G>,<H>)
##
##  returns a coset table for the action of <G> on the cosets of <H>. The
##  columns of the table correspond to the `GeneratorsOfGroup(<G>)'.
##
InstallMethod(CosetTableBySubgroup,"coset action",IsIdenticalObj,
  [IsGroup,IsGroup],0,
function ( G, H )
local column, gens, i, range, table, transversal;

  # construct a permutations representation of G on the cosets of H.
  gens := GeneratorsOfGroup(G);
  if not (IsPermGroup(G) and IsPermGroup(H) and
          IsEqualSet(Orbit(G,1),[1..NrMovedPoints(G)]) and H=Stabilizer(G,1)) then
    transversal := RightTransversal( G, H );
    gens := List( gens, gen -> Permutation( gen, transversal,OnRight ) );
    range := [ 1 .. Length( transversal ) ];
  else
    range := [ 1 .. NrMovedPoints(G) ];
  fi;

  # initialize the coset table.
  table := [];

  # construct the columns of the table from the permutations.
  for i in gens do
    column := OnTuples( range, i );
    Add( table, column );
    column:=OnTuples(range,i^-1);
    Add( table, column );
  od;

  # standardize the table and return it.
  StandardizeTable( table );
  return table;

end);

InstallMethod(CosetTableBySubgroup,"use `CosetTableInWholeGroup",
  IsIdenticalObj, [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function(G,H)
  if IndexInWholeGroup(G)>1 or not IsIdenticalObj(G,Parent(G))
      or List(GeneratorsOfGroup(G),UnderlyingElement)
         <>FreeGeneratorsOfFpGroup(Parent(G)) then
    TryNextMethod();
  fi;
  return CosetTableInWholeGroup(H);
end);


#############################################################################
##
#M  CanonicalRelator( <relator> )  . . . . . . . . . . . .  canonical relator
##
##  'CanonicalRelator'  returns the  canonical  representative  of the  given
##  relator.
##
InstallGlobalFunction( CanonicalRelator, function ( Rel )

    local i, i1, ii, j, j1, jj, k, k1, kk, length, max, min, rel;

    rel := Rel;
    length := Length( rel );
    max := Maximum( rel );
    min := Minimum( rel );

    if max < - min then
        i := 0;
    else
        i := Position( rel, max, 0 );
        k := i;
        while k <> false do
            k := Position( rel, max, k );
            if k <> false then
                ii := i;  kk := k;  k1 := k - 1;
                while kk <> k1 do
                    if ii = length then ii := 1;  else  ii := ii + 1;  fi;
                    if kk = length then kk := 1;  else  kk := kk + 1;  fi;
                    if rel[kk] > rel[ii] then  i := k;  kk := k1;
                    elif rel[kk] < rel[ii] then  kk := k1;
                    elif kk = k1 then  k := false;  fi;
                od;
            fi;
        od;
    fi;

    if - min < max then
        j := 0;
    else
        j := Position( rel, min, 0 );
        k := j;
        while k <> false do
            k := Position( rel, min, k );
            if k <> false then
                jj := j;  kk := k;  j1 := j + 1;
                while jj <> j1 do
                    if jj = 1 then jj := length;  else  jj := jj - 1;  fi;
                    if kk = 1 then kk := length;  else  kk := kk - 1;  fi;
                    if rel[kk] < rel[jj] then  j := k;  jj := j1;
                    elif rel[kk] > rel[jj] then  jj := j1;
                    elif jj = j1 then  k := false;  fi;
                od;
            fi;
        od;
    fi;

    if - min = max then
        if i = 1 then i1 := length;  else  i1 := i - 1;  fi;
        ii := i;  jj := j;
        while ii <> i1 do
            if ii = length then ii := 1;  else  ii := ii + 1;  fi;
            if jj = 1 then jj := length;  else  jj := jj - 1;  fi;
            if - rel[jj] < rel[ii] then  j := 0;  ii := i1;
            elif - rel[jj] > rel[ii] then  i := 0;  ii := i1;  fi;
        od;
    fi;

    if i = 0 then  rel := - Reversed( rel );  i := length + 1 - j;  fi;
    if i > 1 then  rel := Concatenation(
        rel{ [i..length] }, rel{ [1..i-1] } );
    fi;

    return( rel );
end );


#############################################################################
##
#M  CheckCosetTableFpGroup( <G>, <table> ) . . . . . . . checks a coset table
##
##  'CheckCosetTableFpGroup'  checks whether  table is a legal coset table of
##  the finitely presented group G.
##
InstallGlobalFunction( CheckCosetTableFpGroup, function ( G, table )

    local fgens, grels, i, id, index, ngens, perms;

    # check G to be a finitely presented group.
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;

    # check table to be a list of lists.
    if not ( IsList( table ) and ForAll( table, IsList ) ) then
        Error( "<table> must be a coset table" );
    fi;

    # get some local variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );

    # check the number of columns against the number of group generators.
    ngens := Length( fgens );
    if Length( table ) <> 2 * ngens then
        Error( "inconsistent number of group generators and table columns" );
    fi;

    # check the columns to be permutations of equal degree.
    index := IndexCosetTab( table );
    perms := [ ]; perms[ngens] := 0;
    for i in [ 1 .. ngens ] do
        if Length( table[2*i-1] ) <> index then
            Error( "table has columns of different length" );
        fi;
        perms[i] := PermList( table[2*i-1] );
        if PermList( table[2*i] ) <> perms[i]^-1 then
            Error( "table has inconsistent inverse columns" );
        fi;
    od;

    # check the permutations to act transitively.
    id := perms[1]^0;
    if not IsTransitive( GroupByGenerators( perms, id ), [ 1 .. index ] ) then
        Error( "table does not act transitively" );
    fi;

    # check the permutations to satisfy the group relators.
    if not ForAll( grels, rel -> MappedWord( rel, fgens, perms )
        = id ) then
        Error( "table columns do not satisfy the group relators" );
    fi;

end );


#############################################################################
##
#M  IsStandardized( <costab> ) . . . . .  test if coset table is standardized
##
InstallGlobalFunction( IsStandardized, function ( table )

    local i, index, j, next;

    index := IndexCosetTab( table );
    j := 1;
    next := 2;
    while next < index do
        for i in [ 1, 3 .. Length( table ) - 1 ] do
            if table[i][j] >= next then
                if table[i][j] > next then  return false;  fi;
                next := next + 1;
            fi;
        od;
        j := j + 1;
    od;
    return true;

end );


#############################################################################
##
#R  IsPresentationDefaultRep( <pres> )
##
##  is the default representation of presentations.
##  `IsPresentationDefaultRep' is a subrepresentation of
##  `IsComponentObjectRep'.
##
DeclareRepresentation( "IsPresentationDefaultRep",
    IsComponentObjectRep and IsAttributeStoringRep, [] );
#T eventually the admissible component names should be listed here


#############################################################################
##
#M  \.( <pres>, <nam> )  . . . . . . . . . . . . . . . . . for a presentation
##
InstallMethod( \.,
    "for a presentation in default representation",
    true,
    [ IsPresentation and IsPresentationDefaultRep, IsPosInt ], 0,
    function( pres, nam )
Error("still record access");
    return pres!.( NameRNam( nam ) );
    end );


#############################################################################
##
#M  IsBound\.( <pres>, <nam> ) . . . . . . . . . . . . . . for a presentation
##
InstallMethod( IsBound\.,
    "for a presentation in default representation",
    true,
    [ IsPresentation and IsPresentationDefaultRep, IsPosInt ], 0,
    function( pres, nam )
Error("still record access");
    return IsBound( pres!.( NameRNam( nam ) ) );
    end );


#############################################################################
##
#M  \.\:\=( <pres>, <nam>, <val> ) . . . . . . . . . . . . for a presentation
##
InstallMethod( \.\:\=,
    "for a mutable presentation in default representation",
    true,
    [ IsPresentation and IsPresentationDefaultRep and IsMutable,
      IsPosInt, IsObject ], 0,
    function( pres, nam, val )
Error("still record access");
    pres!.( NameRNam( nam ) ):= val;
    end );


#############################################################################
##
#M  Unbind\.( <pres>, <nam> )  . . . . . . . . . . . . . . for a presentation
##
InstallMethod( Unbind\.,
    "for a mutable presentation in default representation",
    true,
    [ IsPresentation and IsPresentationDefaultRep and IsMutable,
      IsPosInt ], 0,
    function( pres, nam )
Error("still record access");
    Unbind( pres!.( NameRNam( nam ) ) );
    end );


#############################################################################
##
#M  PresentationAugmentedCosetTable( <aug>, <string> [,<print level>] ) . . .
#M                                                     create a Tietze record
##
##  'PresentationAugmentedCosetTable'  creates a presentation,  i.e. a Tietze
##  record, from the given augmented coset table. It assumes that <aug> is an
##  augmented coset table of type 2.  The generators will be named <string>1,
##  <string>2, ... .
##
InstallGlobalFunction( PresentationAugmentedCosetTable,
    function ( arg )

    local aug, coFacTable, comps, F, fgens, gens, i, invs, lengths, numgens,
          numrels, pointers, printlevel, rels, string, T, tietze, total,
          tree, treelength, treeNums;

    # check the first argument to be an augmented coset table.
    aug := arg[1];
    if not ( IsRecord( aug ) and IsBound( aug.isAugmentedCosetTable ) and
        aug.isAugmentedCosetTable ) then
        Error( "first argument must be an augmented coset table" );
    fi;

    # get the generators name.
    string := arg[2];
    if not IsString( string ) then
        Error( "second argument must be a string" );
    fi;

    # check the third argument to be an integer.
    printlevel := 1;
    if Length( arg ) >= 3 then  printlevel := arg[3];  fi;
    if not IsInt( printlevel ) then
        Error ("third argument must be an integer" );
    fi;

    # initialize some local variables.
    coFacTable := aug.cosetFactorTable;
    tree := ShallowCopy( aug.tree );
    treeNums := ShallowCopy( aug.treeNumbers );
    treelength := Length( tree[1] );
    F := FreeGroup(IsLetterWordsFamily, infinity, string );
    fgens := GeneratorsOfGroup( F );
    gens := ShallowCopy(aug.subgroupGenerators);
    rels := List(aug.subgroupRelators,ShallowCopy);
    numrels := Length( rels );
    numgens := Length( gens );

    # create the Tietze object.
    T := Objectify( NewType( PresentationsFamily,
                                 IsPresentationDefaultRep
                             and IsPresentation
                             and IsMutable ),
                    rec() );

    # construct the relator lengths list.
    lengths := List( [ 1 .. numrels ], i -> Length( rels[i] ) );
    total := Sum( lengths );

    # initialize the Tietze stack.
    tietze := ListWithIdenticalEntries( TZ_LENGTHTIETZE, 0 );
    tietze[TZ_NUMRELS] := numrels;
    tietze[TZ_RELATORS] := rels;
    tietze[TZ_LENGTHS] := lengths;
    tietze[TZ_FLAGS] := ListWithIdenticalEntries( numrels, 1 );
    tietze[TZ_TOTAL] := total;

    # construct the generators and the inverses list, and save the generators
    # as components of the Tietze record.
    invs := [ ]; invs[2*numgens+1] := 0;
    pointers := [ 1 .. treelength ];
    for i in [ 1 .. numgens ] do
        invs[numgens+1-i] := i;
        invs[numgens+1+i] := - i;
        T!.(String( i )) := fgens[i];
        pointers[treeNums[i]] := treelength + i;
    od;
    invs[numgens+1] := 0;
    comps := [ 1 .. numgens ];

    # define the remaining Tietze stack entries.
    tietze[TZ_FREEGENS] := fgens;
    tietze[TZ_NUMGENS] := numgens;
    tietze[TZ_GENERATORS] := List( [ 1 .. numgens ], i -> fgens[i] );
    tietze[TZ_INVERSES] := invs;
    tietze[TZ_NUMREDUNDS] := 0;
    tietze[TZ_STATUS] := [ 0, 0, -1 ];
    tietze[TZ_MODIFIED] := false;

    # define some Tietze record components.
    T!.generators := tietze[TZ_GENERATORS];
    T!.tietze := tietze;
    T!.components := comps;
    T!.nextFree := numgens + 1;
    T!.identity := One( fgens[1] );
    SetOne(T,One( fgens[1] ));

    # save the tree as component of the Tietze record.
    tree[TR_TREENUMS] := treeNums;
    tree[TR_TREEPOINTERS] := pointers;
    tree[TR_TREELAST] := treelength;
    T!.tree := tree;

    # save the definitions of the primary generators as words in the original
    # group generators.
    SetPrimaryGeneratorWords(T,aug.primaryGeneratorWords);

    # Since T is mutable, we must set this attribite "manually"
    SetTzOptions(T, TzOptions(T));

    # handle relators of length 1 or 2, but do not eliminate any primary
    # generators.
    TzOptions(T).protected := tree[TR_PRIMARY];
    TzOptions(T).printLevel := printlevel;
    if Length(arg)>3 and arg[4]=true then
      # the stupid Length1or2 convention might mess up the connection to the
      # coset table.
      TzInitGeneratorImages(T);
    fi;
    if numgens>0 then
      TzHandleLength1Or2Relators( T );
    fi;
    T!.hasRun1Or2:=true;
    TzOptions(T).protected := 0;

    # sort the relators.
    TzSort( T );

    TzOptions(T).printLevel := printlevel;
    # return the Tietze record.
    return T;
end );


#############################################################################
##
#M  PresentationNormalClosureRrs( <G>, <H> [,<string>] ) . . .  Tietze record
#M                                       for the normal closure of a subgroup
##
##  'PresentationNormalClosureRrs'  uses  the  Reduced  Reidemeister-Schreier
##  method  to compute a  presentation  (i.e. a presentation record)  for the
##  normal closure  N of a subgroup H of a finitely presented group G.
##  The  generators in the  resulting presentation  will be named  <string>1,
##  <string>2, ... , the default string is `\"_x\"'.
##
InstallGlobalFunction( PresentationNormalClosureRrs,
    function ( arg )

    local   G,          # given group
            H,          # given subgroup
            string,     # given string
            F,          # associated free group
            fgens,      # generators of <F>
            hgens,      # generators of <H>
            fhgens,     # their preimages in <F>
            grels,      # relators of <G>
            krels,      # relators of normal closure <N>
            K,          # factor group of F isomorphic to G/N
            cosTable,   # coset table of <G> by <N>
            i,          # loop variable
            aug,        # auxiliary coset table of <G> by <N>
            T;          # resulting Tietze record

    # check the first two arguments to be a finitely presented group and a
    # subgroup of that group.
    G := arg[1];
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    H := arg[2];
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # get the generators name.
    if Length( arg ) = 2 then
        string := "_x";
    else
        string := arg[3];
        if not IsString( string ) then
            Error( "third argument must be a string" );
        fi;
    fi;

    # get some local variables
    F     := FreeGroupOfFpGroup( G );
    fgens := GeneratorsOfGroup( F );
    grels := RelatorsOfFpGroup( G );
    hgens := GeneratorsOfGroup( H );
    fhgens := List( hgens, gen -> UnderlyingElement( gen ) );

    # construct a factor group K of F isomorphic to the factor group of G by
    # the normal closure N of H.
    krels := Concatenation( grels, fhgens );
    K := F / krels;

    # get the coset table of N in G by constructing the coset table of the
    # trivial subgroup in K.
    cosTable := CosetTable( K, TrivialSubgroup( K ) );
    Info( InfoFpGroup, 1, "index is ", Length( cosTable[1] ) );

#   # obsolete: No columns should be equal!
#   for i in [ 1 .. Length( fgens ) ] do
#   if IsIdenticalObj( cosTable[2*i-1], cosTable[2*i] ) then
#   Error( "there is a bug in PresentationNormalClosureRrs" ); fi; od;

    # apply the Reduced Reidemeister-Schreier method to construct a coset
    # table presentation of N.
    aug := AugmentedCosetTableRrs( G, cosTable, 2, string );

    # determine a set of subgroup relators.
    aug.subgroupRelators := RewriteSubgroupRelators( aug, aug.groupRelators);

    # create a Tietze record for the resulting presentation.
    T := PresentationAugmentedCosetTable( aug, string );

    # handle relators of length 1 or 2, but do not eliminate any primary
    # generators.
    TzOptions(T).protected := T!.tree[TR_PRIMARY];
    TzHandleLength1Or2Relators( T );
    T!.hasRun1Or2:=true;
    TzOptions(T).protected := 0;

    # sort the relators.
    TzSort( T );

    return T;
end );

#############################################################################
##
#M  PresentationSubgroupRrs( <G>, <H> [,<string>] ) . . . . . . Tietze record
#M  PresentationSubgroupRrs( <G>, <costab> [,<string>] )  . .  for a subgroup
##
##  'PresentationSubgroupRrs'  uses the  Reduced Reidemeister-Schreier method
##  to compute a presentation  (i.e. a presentation record)  for a subgroup H
##  of a  finitely  presented  group  G.  The  generators  in  the  resulting
##  presentation   will be  named   <string>1,  <string>2, ... ,  the default
##  string is "_x".
##
##  Alternatively to a finitely presented group, the subgroup H  may be given
##  by its coset table.
##
InstallGlobalFunction( PresentationSubgroupRrs, function ( arg )

    local aug, G, gens, H, ngens, string, T, table;

    # check G to be a finitely presented group.
    G := arg[1];
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<group> must be a finitely presented group" );
    fi;

    # get the generators name.
    if Length( arg ) = 2 then
        string := "_x";
    else
        string := arg[3];
        if not IsString( string ) then
            Error( "third argument must be a string" );
        fi;
    fi;

    # check the second argument to be a subgroup or a coset table of G, and
    # get the coset table in either case.
    H := arg[2];
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then

        # check the given table to be a legal coset table.
        table := H;
        CheckCosetTableFpGroup( G, table );
        # ensure that it is standardized.
        if not IsStandardized( table) then Print(
            "#I  Warning: the given coset table is not standardized,\n",
            "#I           a standardized copy will be used instead.\n" );
            StandardizeTable( StructuralCopy( table ) );
        fi;

        # apply the Reduced Reidemeister-Schreier method to construct an
        # augmented RRS coset table of H.
        aug := AugmentedCosetTableRrs( G, table, 2, string );

    else

        # get a copy of an augmented RRS coset table of H in G.
        aug := CopiedAugmentedCosetTable(
            AugmentedCosetTableRrsInWholeGroup( H ) );

        # insert the required subgroup generator names if necessary.
        if aug.nameOfSubgroupGenerators <> string then
            aug.nameOfSubgroupGenerators := string;
            ngens := aug.numberOfSubgroupGenerators;
            gens := GeneratorsOfGroup( FreeGroup( ngens, string ) );
            aug.subgroupGenerators := gens;
        fi;

    fi;

    # determine a set of subgroup relators.
    aug.subgroupRelators := RewriteSubgroupRelators( aug, aug.groupRelators);

    # create a Tietze record for the resulting presentation.
    T := PresentationAugmentedCosetTable( aug, string );

    return T;
end );


#############################################################################
##
#M  ReducedRrsWord( <word> ) . . . . . . . . . . . . . . freely reduce a word
##
##  'ReducedRrsWord' freely reduces the given RRS word and returns the result.
##
InstallGlobalFunction( ReducedRrsWord, function ( word )

    local i, j, reduced;

    # initialize the result.
    reduced := [];

    # run through the factors of the given word and cancel or add them.
    j := 0;
    for i in [ 1 .. Length( word ) ] do
        if word[i] <> 0 then
            if j > 0 and word[i] = - reduced[j] then  j := j-1;
            else  j := j+1;  reduced[j] := word[i];  fi;
        fi;
    od;

    if j < Length( reduced ) then
        reduced := reduced{ [1..j] };
    fi;

    return( reduced );
end );


#############################################################################
##
#M  RelatorMatrixAbelianizedNormalClosureRrs( <G>, <H> )  . .  relator matrix
#M  . . . . . . . . . . . .  for the abelianized normal closure of a subgroup
##
##  'RelatorMatrixAbelianizedNormalClosureRrs' uses the Reduced Reidemeister-
##  Schreier method  to compute a matrix of abelianized defining relators for
##  the  normal  closure of a subgroup  H  of a  finitely presented  group G.
##
InstallGlobalFunction( RelatorMatrixAbelianizedNormalClosureRrs,
    function ( G, H )

    local   F,          # associated free group
            fgens,      # generators of <F>
            hgens,      # generators of <H>
            fhgens,     # their preimages in <F>
            grels,      # relators of <G>
            krels,      # relators of normal closure <N>
            K,          # factor group of F isomorphic to G/N
            cosTable,   # coset table of <G> by <N>
            i,          # loop variable
            aug;        # auxiliary coset table of <G> by <N>

    # check the arguments to be a finitely presented group and a subgroup of
    # that group.
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # get some local variables
    F     := FreeGroupOfFpGroup( G );
    fgens := GeneratorsOfGroup( F );
    grels := RelatorsOfFpGroup( G );
    hgens := GeneratorsOfGroup( H );
    fhgens := List( hgens, gen -> UnderlyingElement( gen ) );

    # construct a factor group K of F isomorphic to the factor group of G by
    # the normal closure N of H.
    krels := Concatenation( grels, fhgens );
    K := F / krels;

    # get the coset table of N in G by constructing the coset table of the
    # trivial subgroup in K.
    cosTable := CosetTable( K, TrivialSubgroup( K ) );
    Info( InfoFpGroup, 1, "index is ", Length( cosTable[1] ) );

#   # obsolete: No columns should be equal!
#   for i in [ 1 .. Length( fgens ) ] do
#   if IsIdenticalObj( cosTable[2*i-1], cosTable[2*i] ) then
#   Error( "there is a bug in RelatorMatrixAbelianizedNormalClosureRrs" );
#   fi; od;

    # apply the Reduced Reidemeister-Schreier method to construct a coset
    # table presentation of N.
    aug := AugmentedCosetTableRrs( G, cosTable, 0, "_x" );

    # determine a set of abelianized subgroup relators.
    aug.subgroupRelators := RewriteAbelianizedSubgroupRelators( aug,
                             aug.groupRelators);

    return aug.subgroupRelators;

end );

RelatorMatrixAbelianizedNormalClosure :=
    RelatorMatrixAbelianizedNormalClosureRrs;



#############################################################################
##
#M  RelatorMatrixAbelianizedSubgroupRrs( <G>, <H> ) . . .  relator matrix for
#M  RelatorMatrixAbelianizedSubgroupRrs( <G>, <costab> )  . .  an abelianized
#M  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .  subgroup
##
##  'RelatorMatrixAbelianizedSubgroupRrs'   uses  the   Reduced Reidemeister-
##  Schreier method  to compute a matrix of abelianized defining relators for
##  a subgroup H of a finitely presented group G.
##
##  Alternatively to a finitely presented group, the subgroup H  may be given
##  by its coset table.
##
InstallGlobalFunction( RelatorMatrixAbelianizedSubgroupRrs, function ( G, H )

    local aug, table,i,j,vec,pres;

    # check G to be a finitely presented group.
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<group> must be a finitely presented group" );
    fi;


    # check the second argument to be a subgroup or a coset table of G, and
    # get the coset table in either case.
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        # check the given table to be a legal coset table.
        table := H;
        CheckCosetTableFpGroup( G, table );
        # ensure that it is standardized.
        if not IsStandardized( table) then Print(
            "#I  Warning: the given coset table is not standardized,\n",
            "#I           a standardized copy will be used instead.\n" );
            StandardizeTable( StructuralCopy( table ) );
        fi;
    else
        # construct the coset table of H in G if it is not yet available.
        if not HasCosetTableInWholeGroup( H ) then
            Info( InfoFpGroup, 1, "index is ", IndexInWholeGroup( H ) );
        fi;
        table := CosetTableInWholeGroup( H );
    fi;

    # apply the Reduced Reidemeister-Schreier method to construct an
    # augmented coset table of H.
    aug := AugmentedCosetTableRrs( G, table, 0, "_x" );

    # determine a set of abelianized subgroup relators.
    aug.subgroupRelators := RewriteAbelianizedSubgroupRelators( aug,
                             aug.groupRelators);
    if aug.subgroupRelators=fail then
      # the abelianized rewriting in the kernel failed because the
      # coefficients were to large.
      return fail;

    fi;

    return aug.subgroupRelators;

end );


#############################################################################
##
#M  RenumberTree( <augmented coset table> ) . . . . .  renumber generators in
#M                                                      augmented coset table
##
##  'RenumberTree'  is  a  subroutine  of  the  Reduced Reidemeister-Schreier
##  routines.  It renumbers the generators  such that the  primary generators
##  precede the secondary ones.
##
InstallGlobalFunction( RenumberTree, function ( aug )

    local coFacTable, column, convert, defs, i, index, j, k, null, numcols,
          numgens, tree, tree1, tree2, treelength, treesize;

    # get factor table, generators, and tree.
    coFacTable := aug.cosetFactorTable;
    defs := aug.primaryGeneratorWords;
    tree := aug.tree;

    #  truncate the tree, if necessary.
    treelength := tree[3];
    treesize := Length( tree[1] );
    if treelength < treesize then
        tree[1] := tree[1]{ [ 1 .. treelength ] };
        tree[2] := tree[2]{ [ 1 .. treelength ] };
    fi;

    # initialize some local variables.
    numcols := Length( coFacTable );
    index := Length( coFacTable[1] );
    numgens := Length( defs );

    # establish a local renumbering list.
    convert := ListWithIdenticalEntries( 2 * treelength + 1, 0 );
    null := treelength + 1;
    j := treelength + 1;  k := numgens + 1;
    i := treelength;
    while i >= 1 do
        if tree[1][i] = 0 then
            k := k - 1;  convert[null+i] := k;  convert[null-i] := - k;
        else
            j := j - 1;  convert[null+i] := j;  convert[null-i] := - j;
            tree[1][j] := tree[1][i];  tree[2][j] := tree[2][i];
        fi;
        i := i - 1;
    od;

    if convert[null+numgens] <> numgens then

        # change the tree entries accordingly.
        for i in [1..numgens] do
            tree[1][i] := 0;  tree[2][i] := 0;
        od;
        tree1 := tree[1];  tree2 := tree[2];
        for j in [numgens+1..treelength] do
            tree1[j] := convert[null+tree1[j]];
            tree2[j] := convert[null+tree2[j]];
        od;

        # change the factor table entries accordingly.
        for i in [1..numcols] do
# --------------
# obsolete condition: columns should never be equal.
#            if i mod 2 = 1 or
#                not IsIdenticalObj( coFacTable[i], coFacTable[i-1] ) then
if i > 1 and IsIdenticalObj( coFacTable[i], coFacTable[i-1] ) then
Error( "there is a bug in RenumberTree" ); fi;
# --------------
            column := coFacTable[i];
            for j in [1..index] do
                column[j] := convert[null+column[j]];
            od;
        od;

    fi;
end );


#############################################################################
##
#M  RewriteAbelianizedSubgroupRelators( <aug>,<prels> ) . rewrite abelianized
#M  . . . . . . . . . . . . . subgroup relators from an augmented coset table
##
##  'RewriteAbelianizedSubgroupRelators'  is  a  subroutine  of  the  Reduced
##  Reidemeister-Schreier and the Modified Todd-Coxeter routines. It computes
##  a set of subgroup relators  from the  coset factor table  of an augmented
##  coset table of type 0 and the relators <prels> of the parent group.
##
InstallGlobalFunction( RewriteAbelianizedSubgroupRelators,
    function ( aug,prels )

    local app2, coFacTable, cols, cosTable, factor, ggensi, grel,greli, i,
          index, j, length, nums, numgens, numrels, p, rels, total, tree,
          treelength, type,si,ei,nneg,word;

    # check the type for being zero.
    type := aug.type;
    if type <> 0 then
        Error( "type of augmented coset table is not zero" );
    fi;

    # initialize some local variables.
    ggensi := List(aug.groupGenerators,i->AbsInt(LetterRepAssocWord(i)[1]));
    cosTable := aug.cosetTable;
    coFacTable := aug.cosetFactorTable;
    index := Length( cosTable[1] );
    tree := aug.tree;
    treelength := tree[3];
    numgens := tree[4];
    total := numgens;
    rels := List( [ 1 .. total ],
        i -> ListWithIdenticalEntries( numgens, 0 ) );
    numrels := 0;

    # display some information.
    Info( InfoFpGroup, 2, "index is ", index );
    Info( InfoFpGroup, 2, "number of generators is ", numgens );
    Info( InfoFpGroup, 2, "tree length is ", treelength );

    # initialize the structure that is passed to 'ApplyRel2'
    app2 := ListWithIdenticalEntries( 9, 0 );
    app2[5] := type;
    app2[6] := coFacTable;
    app2[8] := tree;

    # loop over all group relators
    for greli in [1..Length(prels)] do
      CompletionBar(InfoFpGroup,2,"Relator Loop:",greli/Length(prels));
      grel:=prels[greli];

      # get two copies of the group relator, one as a list of words in the
      # factor table columns and one as a list of words in the coset table
      # column numbers.
      length := Length( grel );
      if length>0 then

        nums := [ ]; nums[2*length] := 0;
        cols := [ ]; cols[2*length] := 0;

        i:=0;
#        for si in [ 1 .. NrSyllables(grel) ]  do
#         p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#         nneg:=ExponentSyllable(grel,si)>0;
#         for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#           i:=i+1;
#           if nneg then
#             nums[2*i]   := p-1;
#             nums[2*i-1] := p;
#             cols[2*i]   := cosTable[p-1];
#             cols[2*i-1] := cosTable[p];
#           else
#             nums[2*i]   := p;
#             nums[2*i-1] := p-1;
#             cols[2*i]   := cosTable[p];
#             cols[2*i-1] := cosTable[p-1];
#           fi;
#         od;
#       od;
        word:=LetterRepAssocWord(grel);
        for si in [1..Length(word)] do
          p:=2*Position(ggensi,AbsInt(word[si]));
          i:=i+1;
          if word[si]>0 then
            nums[2*i]:=p-1;
            nums[2*i-1]:=p;
            cols[2*i]:=cosTable[p-1];
            cols[2*i-1]:=cosTable[p];
          else
            nums[2*i]:=p;
            nums[2*i-1]:=p-1;
            cols[2*i]:=cosTable[p];
            cols[2*i-1]:=cosTable[p-1];
          fi;
        od;

        # loop over all cosets and determine the subgroup relators which are
        # induced by the current group relator.
        for i in [ 1 .. index ] do

            # scan the ith coset through the current group relator and
            # collect the factors of its invers (!) in rel.
            numrels := numrels + 1;
            if numrels > total then
                total := total + 1;
                rels[total] := ListWithIdenticalEntries( numgens, 0 );
            fi;
            app2[7] := rels[numrels];
            app2[1] := 2;
            app2[2] := i;
            app2[3] := 2 * length - 1;
            app2[4] := i;
            if not ApplyRel2( app2, cols, nums ) then
              return fail;
            fi;

            # add the resulting subgroup relator to rels.
            numrels := AddAbelianRelator( rels, numrels );
        od;
      fi;
    od;
    CompletionBar(InfoFpGroup,2,"Relator Loop:",false);

    # loop over all primary subgroup generators.
    for j in [ 1 .. numgens ] do
      CompletionBar(InfoFpGroup,2,"Generator Loop:",j/numgens);

      # get two copies of the subgroup generator, one as a list of words in
      # the factor table columns and one as a list of words in the coset
      # table column numbers.
      grel := aug.primaryGeneratorWords[j];
      length := Length( grel );

      if length>0 then

        nums := [ ]; nums[2*length] := 0;
        cols := [ ]; cols[2*length] := 0;

        i:=0;
#        for si in [ 1 .. NrSyllables(grel) ]  do
#         p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#         nneg:=ExponentSyllable(grel,si)>0;
#         for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#           i:=i+1;
#           if nneg then
#             nums[2*i]   := p-1;
#             nums[2*i-1] := p;
#             cols[2*i]   := cosTable[p-1];
#             cols[2*i-1] := cosTable[p];
#           else
#             nums[2*i]   := p;
#             nums[2*i-1] := p-1;
#             cols[2*i]   := cosTable[p];
#             cols[2*i-1] := cosTable[p-1];
#           fi;
#         od;
#        od;
        word:=LetterRepAssocWord(grel);
        for si in [1..Length(word)] do
          p:=2*Position(ggensi,AbsInt(word[si]));
          i:=i+1;
          if word[si]>0 then
            nums[2*i]:=p-1;
            nums[2*i-1]:=p;
            cols[2*i]:=cosTable[p-1];
            cols[2*i-1]:=cosTable[p];
          else
            nums[2*i]:=p;
            nums[2*i-1]:=p-1;
            cols[2*i]:=cosTable[p];
            cols[2*i-1]:=cosTable[p-1];
          fi;
        od;

        # scan coset 1 through the current subgroup generator and collect the
        # factors of its invers (!) in rel.
        numrels := numrels + 1;
        if numrels > total then
            total := total + 1;
            rels[total] := ListWithIdenticalEntries( numgens, 0 );
        fi;
        app2[7] := rels[numrels];
        app2[1] := 2;
        app2[2] := 1;
        app2[3] := 2 * length - 1;
        app2[4] := 1;
        if not ApplyRel2( app2, cols, nums ) then
          return fail;
        fi;

      else
        # trivial generator
        numrels := numrels + 1;
        if numrels > total then
            total := total + 1;
            rels[total] := ListWithIdenticalEntries( numgens, 0 );
        fi;
      fi;

      # add as last factor the generator number j.
      rels[numrels][j] := rels[numrels][j] + 1;

      # add the resulting subgroup relator to rels.
      numrels := AddAbelianRelator( rels, numrels );
    od;

    # reduce the relator list to its proper size.
    if numrels < numgens then
        for i in [ numrels + 1 .. numgens ] do
            rels[i] := ListWithIdenticalEntries( numgens, 0 );
        od;
        numrels := numgens;
    fi;
    for i in [ numrels + 1 .. total ] do
        Unbind( rels[i] );
    od;
    CompletionBar(InfoFpGroup,2,"Generator Loop:",false);

    return rels;
end );


#############################################################################
##
#M  RewriteSubgroupRelators( <aug>, <prels> [,<indices>] )
##
##  'RewriteSubgroupRelators'  is a subroutine  of the  Reduced Reidemeister-
##  Schreier and the  Modified Todd-Coxeter  routines.  It computes  a set of
##  subgroup relators from the coset factor table of an augmented coset table
##  and the  relators <prels> of the  parent  group.  It assumes  that  <aug>
##  is an augmented coset table of type 2.
##  If <indices> are given only those cosets are used
##
InstallGlobalFunction( RewriteSubgroupRelators,
function (arg)

    local app2, coFacTable, cols, convert, cosTable, factor, ggensi,
          greli,grel, i, index, j, last, length, nums, numgens, p, rel, rels,
          treelength, type,si,nneg,ei,word,aug,prels,indices;

    aug:=arg[1];
    prels:=arg[2];
    # check the type.
    type := aug.type;
    if type <> 2 then  Error( "invalid type; it should be 2" );  fi;

    # initialize some local variables.
    ggensi := List(aug.groupGenerators,i->AbsInt(LetterRepAssocWord(i)[1]));
    cosTable := aug.cosetTable;
    coFacTable := aug.cosetFactorTable;
    index := Length( cosTable[1] );
    if Length(arg)=2 then
      indices:=[1..index];
    else
      indices:=arg[3];
    fi;
    rels := [ ];

    # initialize the structure that is passed to 'ApplyRel2'
    app2 := ListWithIdenticalEntries( 9, 0 );
    app2[5] := type;
    app2[6] := coFacTable;
    app2[7] := [ ]; app2[7][100] := 0;

    # loop over all group relators
    for greli in [1..Length(prels)] do
      CompletionBar(InfoFpGroup,2,"Relator Loop:",greli/Length(prels));
      grel:=prels[greli];
      length := Length( grel );
      if length > 0 then

        # get two copies of the group relator, one as a list of words in the
        # factor table columns and one as a list of words in the coset table
        # column numbers.
        nums := [ ]; nums[2*length] := 0;
        cols := [ ]; cols[2*length] := 0;

        i:=0;
#        for si in [ 1 .. NrSyllables(grel) ]  do
#         p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#         nneg:=ExponentSyllable(grel,si)>0;
#         for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#           i:=i+1;
#           if nneg then
#             nums[2*i]   := p-1;
#             nums[2*i-1] := p;
#             cols[2*i]   := cosTable[p-1];
#             cols[2*i-1] := cosTable[p];
#           else
#             nums[2*i]   := p;
#             nums[2*i-1] := p-1;
#             cols[2*i]   := cosTable[p];
#             cols[2*i-1] := cosTable[p-1];
#           fi;
#         od;
#       od;
        word:=LetterRepAssocWord(grel);
        for si in [1..Length(word)] do
          p:=2*Position(ggensi,AbsInt(word[si]));
          i:=i+1;
          if word[si]>0 then
            nums[2*i]:=p-1;
            nums[2*i-1]:=p;
            cols[2*i]:=cosTable[p-1];
            cols[2*i-1]:=cosTable[p];
          else
            nums[2*i]:=p;
            nums[2*i-1]:=p-1;
            cols[2*i]:=cosTable[p];
            cols[2*i-1]:=cosTable[p-1];
          fi;
        od;

        # loop over all cosets and determine the subgroup relators which are
        # induced by the current group relator.
        for i in indices do

            # scan the ith coset through the current group relator and
            # collect the factors of its inverse (!) in rel.
            app2[1] := 2;
            app2[2] := i;
            app2[3] := 2 * length - 1;
            app2[4] := i;
            ApplyRel2( app2, cols, nums );

            # add the resulting subgroup relator to rels.
            rel := app2[7];
            last := Length( rel );
            if last > 0 then
                MakeCanonical( rel );
                if Length( rel ) > 0 and not rel in rels then
                    AddSet( rels, Immutable(CopyRel( rel ) ));
                fi;
            fi;
        od;
      fi;
    od;
    CompletionBar(InfoFpGroup,2,"Relator Loop:",false);

    # loop over all primary subgroup generators.
    numgens := Length( aug.primaryGeneratorWords );
    for j in [ 1 .. numgens ] do
      CompletionBar(InfoFpGroup,2,"Generator Loop:",j/numgens);

      # get two copies of the subgroup generator, one as a list of words in
      # the factor table columns and one as a list of words in the coset
      # table column numbers.
      grel := aug.primaryGeneratorWords[j];
      length := Length( grel );

      if length>0 then
        nums := [ ]; nums[2*length] := 0;
        cols := [ ]; cols[2*length] := 0;

        i:=0;
#        for si in [ 1 .. NrSyllables(grel) ]  do
#         p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#         nneg:=ExponentSyllable(grel,si)>0;
#         for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#           i:=i+1;
#           if nneg then
#             nums[2*i]   := p-1;
#             nums[2*i-1] := p;
#             cols[2*i]   := cosTable[p-1];
#             cols[2*i-1] := cosTable[p];
#           else
#             nums[2*i]   := p;
#             nums[2*i-1] := p-1;
#             cols[2*i]   := cosTable[p];
#             cols[2*i-1] := cosTable[p-1];
#           fi;
#         od;
#        od;
        word:=LetterRepAssocWord(grel);
        for si in [1..Length(word)] do
          p:=2*Position(ggensi,AbsInt(word[si]));
          i:=i+1;
          if word[si]>0 then
            nums[2*i]:=p-1;
            nums[2*i-1]:=p;
            cols[2*i]:=cosTable[p-1];
            cols[2*i-1]:=cosTable[p];
          else
            nums[2*i]:=p;
            nums[2*i-1]:=p-1;
            cols[2*i]:=cosTable[p];
            cols[2*i-1]:=cosTable[p-1];
          fi;
        od;

        # scan coset 1 through the current subgroup generator and collect the
        # factors of its inverse (!) in rel.
        app2[1] := 2;
        app2[2] := 1;
        app2[3] := 2 * length - 1;
        app2[4] := 1;
        ApplyRel2( app2, cols, nums );

        # add as last factor the generator number j.
        rel := app2[7];
        last := Length( rel );
        if last > 0 and rel[last] = - j then
            last := last - 1;
            rel := rel{ [1 .. last] };
        else
            last := last + 1;
            rel[last] := j;
        fi;
        # add the resulting subgroup relator to rels.
        if last > 0 then
            MakeCanonical( rel );
            if Length( rel ) > 0 and not rel in rels then
                AddSet( rels, Immutable(CopyRel(rel)));
            fi;
        fi;
      else
        # trivial generator
        AddSet(rels,[j]);
      fi;
    od;
    CompletionBar(InfoFpGroup,2,"Generator Loop:",false);

    # make mutable again to overwrite
    rels:=List(rels,ShallowCopy);

    # renumber the generators in the relators, if necessary.
    numgens := Length( aug.subgroupGenerators );
    treelength := Length( aug.tree[1] );
    if numgens < treelength then
        convert := aug.conversionList;
        for rel in rels do
            for i in [ 1 .. Length( rel ) ] do
                if rel[i] > 0 then
                    rel[i] := convert[rel[i]];
                else
                    rel[i] := - convert[-rel[i]];
                fi;
            od;
        od;
    fi;

    return rels;
end );


#############################################################################
##
#M  SortRelsSortedByStartGen(<relsGen>) sort the relators sorted by start gen
##
##  'SortRelsSortedByStartGen' sorts the relators lists  sorted  by  starting
##  generator to get better  results  of  the  Reduced  Reidemeister-Schreier
##  (this is not needed for the Felsch Todd-Coxeter).
##
InstallGlobalFunction( SortRelsSortedByStartGen,
    function ( relsGen )
    local   less, list;

    # 'less' defines an ordering on the triples [ nums, cols, startpos ]
    less := function ( triple1, triple2 )
        local diff, i, k, nums1, nums2;

        if triple1[1][1] <> triple2[1][1] then
            return triple1[1][1] < triple2[1][1];
        fi;

        nums1 := triple1[1];  nums2 := triple2[1];
        i := triple1[3];
        diff := triple2[3] - i;
        k := i + nums1[1] + 2;
        while i < k do
            if nums1[i] <> nums2[i+diff] then
                return nums1[i] < nums2[i+diff];
            fi;
            i := i + 2;
        od;

        return false;
    end;

    # sort the resulting lists
    for list  in relsGen  do
        Sort( list, less );
    od;
end );


#############################################################################
##
#M  SpanningTree( <coset table> ) . . . . . . . . . . . . . . . spanning tree
##
##  'SpanningTree'  returns a spanning tree for the given coset table.
##
InstallGlobalFunction( SpanningTree, function ( cosTable )

    local done, i, j, k, numcols, numrows, span1, span2;

    # check the given argument to be a coset table.
    if not ( IsList( cosTable ) and IsList( cosTable[1] ) ) then
        Error( "argument must be a coset table" );
    fi;
    numcols := Length( cosTable );
    numrows := Length( cosTable[1] );
    for i in [ 2 .. numcols ] do
        if not ( IsList( cosTable[i] ) and
            Length( cosTable[i] ) = numrows ) then
            Error( "argument must be a coset table" );
        fi;
    od;

    # initialize the spanning tree.
    span1 := [ -1, -2 .. -numrows ];
    span2 := ListWithIdenticalEntries( numrows, 0 );
    span1[1] := 0;
    if numrows = 1 then  return [ span1, span2 ];  fi;

    # find the first occurrence in the table of each coset > 1.
    done := [ 1 ];
    for i in done do
        for j in [ 1 .. numcols ] do
            k := cosTable[j][i];
            if span1[k] < 0 then
                span1[k] := i;  span2[k] := j;
                Add( done, k );
                if Length( done ) = numrows then
                    return [ span1, span2 ];
                fi;
            fi;
        od;
    od;

    # you should never come here, the argument is not a valid coset table.
    Error( "argument must be a coset table" );
end );

#############################################################################
##
##  Extensions for rewriting and homomorphisms
##

#############################################################################
##
#F  RewriteWord( <aug>, <word> )
##
InstallGlobalFunction(RewriteWord,function ( aug, word )
local cft, ct, w,l,c,i,g,ind;

  # check the type.
  Assert(1,aug.type=2);

  # initialize some local variables.
  ct := aug.cosetTable;
  cft := aug.cosetFactorTable;

  # translation table for group generators to numbers
  if not IsBound(aug.transtab) then
    # should do better, also cope with inverses
    aug.transtab:=List(aug.groupGenerators,i->AbsInt(LetterRepAssocWord(i)[1]));
  fi;

  w:=[];
  c:=1; # current coset

  #for i in [1..NrSyllables(word)] do
  #  g:=GeneratorSyllable(word,i);
  #  e:=ExponentSyllable(word,i);
  #  if e<0 then
  #    ind:=2*aug.transtab[g];
  #    e:=-e;
  #  else
  #    ind:=2*aug.transtab[g]-1;
  #  fi;
  #  for j in [1..e] do
  #    # apply the generator, collect cofactor
  #    if cft[ind][c]<>0 then
#       Add(w,cft[ind][c]); #cofactor
#      fi;
#      c:=ct[ind][c]; # new coset number
#    od;
#  od;
  l:=LetterRepAssocWord(word);
  for i in l do
    g:=AbsInt(i);
    if i<0 then
      ind:=2*aug.transtab[g];
    else
      ind:=2*aug.transtab[g]-1;
    fi;
    # apply the generator, collect cofactor
    if cft[ind][c]<>0 then
      Add(w,cft[ind][c]); #cofactor
    fi;
    c:=ct[ind][c]; # new coset number
  od;

  # make sure we got back to start
  if c<>1 then
    return fail;
  fi;
  return w;

end);

#############################################################################
##
#F  DecodedTreeEntry(<tree>,<imgs>,<nr>)
##
InstallGlobalFunction(DecodedTreeEntry,function(tree,imgs,nr)
local eval,t1,t2;
  if IsBound(imgs[AbsInt(nr)]) then
    if nr>0 then
      return imgs[nr];
    else
      return imgs[-nr]^-1;
    fi;
  fi;
# as we might not want to construct the full tree, we'll be more specific
  if not IsMutable(imgs) then
    imgs:=ShallowCopy(imgs); # we will add locally
  fi;
  t1:=tree[1];
  t2:=tree[2];
  eval:=function(n)
    if not IsBound(imgs[n]) then
      imgs[n]:=eval(AbsInt(t1[n]))^SignInt(t1[n])
             *eval(AbsInt(t2[n]))^SignInt(t2[n]);
    fi;
    return imgs[n];
  end;
  return eval(nr);
end);

#############################################################################
##
#F  GeneratorTranslationAugmentedCosetTable(<aug>)
##
## decode the secondary generators as words in the primary generators, using
## the `.subgroupGenerators' and their subset `.primarySubgroupGenerators'.
InstallGlobalFunction(GeneratorTranslationAugmentedCosetTable,function(aug)
local tt,i,t1,t2,tn;
  if not IsBound(aug.translationTable) then
    if not IsBound(aug.primarySubgroupGenerators) then
      aug.primarySubgroupGenerators:=
          aug.subgroupGenerators{[1..Length(aug.primaryGeneratorWords)]};
    fi;
    # now expand the tree to get words for the secondary generators.
    # the first elements are just the primary generators
    tt:=ShallowCopy(aug.primarySubgroupGenerators);
    t1:=aug.tree[1];
    t2:=aug.tree[2];
    tn:=aug.treeNumbers;
    if Length(tn)>0 then
      for i in [Length(tt)+1..Maximum(tn)] do
        tt[i]:=tt[AbsInt(t1[i])]^SignInt(t1[i])
              *tt[AbsInt(t2[i])]^SignInt(t2[i]);
      od;
    fi;
    aug.translationTable:=Immutable(tt);
  fi;
  return aug.translationTable;
end);

#############################################################################
##
#F  SecondaryGeneratorWordsAugmentedCosetTable(<aug>)
##
InstallGlobalFunction(SecondaryGeneratorWordsAugmentedCosetTable,function(aug)
  if not IsBound(aug.secondaryWords) then
    aug.secondaryWords:=Immutable(
    List(GeneratorTranslationAugmentedCosetTable(aug),i->
      MappedWord(i,aug.primarySubgroupGenerators,aug.primaryGeneratorWords)));
  fi;
  return aug.secondaryWords;
end);

#############################################################################
##
#F  CopiedAugmentedCosetTable(<aug>)
##
##  returns a new augmented coset table, equal to the old one. The
##  components of this new table are immutable, but new components may be
##  added.
##  (This function is needed to have different homomorphisms share the same
##  augmented coset table data. It must not be applied to augmented coset
##  tables which are not of type 2.)
InstallGlobalFunction(CopiedAugmentedCosetTable,function(aug)
local t,j;
  if IsBound(aug.isNewAugmentedTable) then
    t:=rec(isNewAugmentedTable:=true);
    for j in
      [ "A", "aug", "ct", "defcount", "from", "homgenims", "homgens",
      "index", "n", "offset", "primaryImages", "rels","one","useAddition",
      "secondary", "secount", "secondaryImages", "subgens" ] do
      if IsBound(aug.(j)) then
        t.(j):=aug.(j);
      fi;
    od;
  else
    # old version
    t:=rec(
            isAugmentedCosetTable:=true,
            type:=aug.type,
            tableType:=aug.tableType,
            groupGenerators:=aug.groupGenerators,
            groupRelators:=aug.groupRelators,
            cosetTable:=aug.cosetTable,
            cosetFactorTable:=aug.cosetFactorTable,
            primaryGeneratorWords:=aug.primaryGeneratorWords,
            tree:=aug.tree,
            treeNumbers:=aug.treeNumbers,
            numberOfSubgroupGenerators:=aug.numberOfSubgroupGenerators,
            nameOfSubgroupGenerators:=aug.nameOfSubgroupGenerators,
            subgroupGenerators:=aug.subgroupGenerators
          );
    if IsBound(aug.secondaryWords) then
      t.secondaryWords:=Immutable(aug.secondaryWords);
    fi;

    if IsBound(aug.conversionList) then
      t.conversionList:=aug.conversionList;
    fi;
    if IsBound(aug.primarySubgroupGenerators) then
      t.primarySubgroupGenerators:=Immutable(aug.primarySubgroupGenerators);
    fi;
    if IsBound(aug.subgroupRelators) then
      t.subgroupRelators:=Immutable(aug.subgroupRelators);
    fi;
    if IsBound(aug.translationTable) then
      t.translationTable:=Immutable(aug.translationTable);
    fi;

  fi;
  return t;
end);

# New implementation of the Modified Todd-Coxeter (MTC) algorithm, based on
# Chapter 5  of the "Handbook of Computational Group Theory", by Derek F.
# Holt (referred # to as "Handbook" from here on). Function names after the
# NEWTC_ agree with those of sections 5.2, 5.3 of the Handbook.

BindGlobal( "NEWTC_AddDeduction", function(list,ded)
  if not ded in list then
    Add(list,ded);
  fi;
end );

# the tables produced internally are indexed at rec.offset+k for generator
# number k, that is in the form ...,-2,-1,empty,1,2,...
# This avoids lots of even/od decisions and the cost of the empty list is
# neglegible.

BindGlobal( "NEWTC_Compress", function(DATA,purge)
local ct,c,a,b,offset,x,to,p,dw,doa,aug;
  doa:=DATA.augmented;
  dw:=IsBound(DATA.with);
  ct:=DATA.ct;
  if doa then
    aug:=DATA.aug;
  fi;
  p:=DATA.p;
  offset:=DATA.offset;
  c:=0;
  to:=[];

  for a in [1..DATA.n] do
    if p[a]=a then
      c:=c+1;
      to[a]:=c;
      if c<>a then
        for x in DATA.A do
          if ct[x+offset][a]<>0 then;
            b:=ct[x+offset][a];
            if b=a then b:=c;fi;
            ct[x+offset][c]:=b;
            ct[-x+offset][b]:=c;
            if doa then
              # transfer augemented entry
              aug[x+offset][c]:=aug[x+offset][a];
            fi;
          else
            # clear out
            ct[x+offset][c]:=0;
            if doa then
              Unbind(aug[x+offset][c]);
            fi;
          fi;
        od;
        if dw then
          DATA.with[c]:=DATA.with[a];
          b:=DATA.from[a];
          while b<>to[b] do
            b:=to[b];
          od;
          DATA.from[c]:=b;
        fi;
      fi;
    else
      b:=a;
      while p[b]<>b do
        b:=p[b];
      od;
      to[a]:=b;
    fi;
  od;
  if purge then
    for x in DATA.A do
      for a in [Length(ct[x+offset]),Length(ct[x+offset])-1..c+1] do
        Unbind(ct[x+offset][a]);
        if doa then
          Unbind(aug[x+offset][a]);
        fi;
      od;
    od;
    if dw then
      for a in [Length(DATA.with),Length(DATA.with)-1..c+1] do
        Unbind(DATA.with[a]);
        Unbind(DATA.from[a]);
      od;
    fi;
  fi;

  if IsBound(DATA.ds) then
    for x in DATA.ds do
      a:=to[x[1]];
        while x[1]<>a do
        x[1]:=a;
        a:=to[a];
      od;
    od;
    Assert(2,Maximum(List(DATA.ds,x->x[1]))<=c);
  fi;

  DATA.n:=c;
  DATA.p:=[1..DATA.n];
  if doa then
    DATA.pp:=ListWithIdenticalEntries(DATA.n,DATA.one);
  fi;
  DATA.dead:=0;
end );

BindGlobal( "NEWTC_Define", function(DATA,i,a)
# both augmented or not
local c,o,n,j,au;
  n:=DATA.n;
  o:=DATA.offset;
  c:=DATA.ct;
  n:=n+1;
  DATA.n:=n;
  if n>DATA.limit then
    if ValueOption("quiet")=true then return fail;fi;
    Error( "the coset enumeration has defined more ",
            "than ", DATA.limit, " cosets\n");
    DATA.limit:=DATA.limit*2;
    DATA.limtrigger:=Int(9/10*DATA.limit);
  fi;
  DATA.p[n]:=n;
  # clear out
  for j in DATA.A do
    c[j+o][n]:=0;
  od;
  c[o+a][i]:=n;
  c[o-a][n]:=i;
  if DATA.augmented then
    DATA.aug[o+a][i]:=DATA.one;
    DATA.aug[o-a][n]:=DATA.one;
    DATA.pp[n]:=DATA.one;
  fi;

  NEWTC_AddDeduction(DATA.deductions,[i,a]);
  #if IsBound(DATA.ds) then Add(DATA.ds,[i,a]); fi;
  DATA.defcount:=DATA.defcount+1;
  if IsBound(DATA.with) then
    if DATA.with[i]=-a then Error("bleh!");fi;
    DATA.with[n]:=a;
    DATA.from[n]:=i;
  fi;
  #ForAny(DATA.A,x->ForAny([1..Length(c[x+o])],y->not
  #  IsBound(c[x+o][y]))) then
  #  Error("hehe");
  #fi;
  return true; # indicating no quiet fail
end );

BindGlobal( "NEWTC_Coincidence", function(DATA,a,b)
local Rep,Merge,ct,offset,l,q,i,c,x,d,p,mu,nu;

  if a=b then return;fi;

  Rep:=function(kappa)
  local lambda,rho,mu;
    lambda:=kappa;
    rho:=p[lambda];
    while rho<>lambda do
      lambda:=rho;rho:=p[lambda];
    od;
    mu:=kappa;rho:=p[mu];
    while rho<>lambda do
      p[mu]:=lambda;mu:=rho;rho:=p[mu];
    od;
    return lambda;
  end;

  Merge:=function(k,a)
  local phi,psi,mu,nu;
    phi:=Rep(k);
    psi:=Rep(a);
    if phi<>psi then
      mu:=Minimum(phi,psi);
      nu:=Maximum(phi,psi);
      p[nu]:=mu;
      l:=l+1;
      q[l]:=nu;
      DATA.dead:=DATA.dead+1;
    fi;
  end;

  ct:=DATA.ct;
  offset:=DATA.offset;
  p:=DATA.p;
  l:=0;
  q:=[];
  Merge(a,b);i:=1;
  while i<=l do
    c:=q[i];
    i:=i+1;
    #RemoveSet(DATA.omega,c);
    for x in DATA.A do
      if ct[x+offset][c]<>0 then
        d:=ct[x+offset][c];
        ct[x+offset][c]:=0;
        ct[-x+offset][d]:=0;
        mu:=Rep(c);
        nu:=Rep(d);
        if ct[x+offset][mu]<>0 then
          Merge(nu,ct[x+offset][mu]);
        elif ct[-x+offset][nu]<>0 then
          Merge(mu,ct[-x+offset][nu]);
        else
          ct[x+offset][mu]:=nu;
          ct[-x+offset][nu]:=mu;
          NEWTC_AddDeduction(DATA.deductions,[mu,x]);
        fi;
      fi;
    od;
  od;
end );

BindGlobal( "NEWTC_ModifiedCoincidence", function(DATA,a,b,w)
local MRep,MMerge,ct,offset,l,q,i,c,x,d,p,pp,mu,nu,aug,v,Sekundant;

  # decide whether secondary generators will be introduced
  Sekundant:=function(w)
  local i,p,c,ws;
    if Length(w)<=1 or DATA.useAddition then
      return w;
    fi;
    ws:=Set(w);
    repeat
      c:=false;
      for i in [Length(DATA.subgens)+1..DATA.secount] do
        if ForAll(DATA.secondary[i],x->x in ws) then
          p:=PositionSublist(w,DATA.secondary[i]);
          while p<>fail do
            w:=WordProductLetterRep(w{[1..p-1]},
              [i],w{[p+Length(DATA.secondary[i])..Length(w)]});
            ws:=Set(w);
            c:=true;
            p:=PositionSublist(w,DATA.secondary[i],Maximum(0,p-Length(DATA.secondary[i])));
          od;
        fi;
      od;
    until c=false;

    DATA.secount:=DATA.secount+1;
    DATA.secondary[DATA.secount]:=w;
    return [DATA.secount];
  end;

  MRep:=function(kappa)
  local lambda,rho,mu,s;
    lambda:=kappa;
    rho:=p[lambda];
    if rho=lambda then return lambda; fi;

    s:=DATA.s; # re-used array to trace back compression path
    while rho<>lambda do
      s[rho]:=lambda;
      lambda:=rho;rho:=p[lambda];
    od;
    rho:=s[lambda];
    while rho<>kappa do
      mu:=rho;
      rho:=s[mu];
      p[rho]:=lambda;
      if DATA.useAddition then
        pp[rho]:=pp[rho]+pp[mu];
      else
        pp[rho]:=Sekundant(WordProductLetterRep(pp[rho],pp[mu]));
      fi;
    od;
    return lambda;
  end;

  MMerge:=function(k,a,w)
  local phi,psi;
    phi:=MRep(k);
    psi:=MRep(a);
    if phi>psi then
      p[phi]:=psi;
      if DATA.useAddition then
        pp[phi]:=-pp[k]+w+pp[a];
      else
        pp[phi]:=Sekundant(WordProductLetterRep(-Reversed(pp[k]),w,pp[a]));
      fi;
      l:=l+1;
      q[l]:=phi;
      DATA.dead:=DATA.dead+1;
    elif psi>phi then
      p[psi]:=phi;
      if DATA.useAddition then
        pp[psi]:=-pp[a]-w+pp[k];
      else
        pp[psi]:=Sekundant(WordProductLetterRep(-Reversed(pp[a]),-Reversed(w),pp[k]));
      fi;
      l:=l+1;
      q[l]:=psi;
      DATA.dead:=DATA.dead+1;
    fi;
  end;

  ct:=DATA.ct;
  aug:=DATA.aug;
  offset:=DATA.offset;
  p:=DATA.p;
  pp:=DATA.pp;
  l:=0;
  q:=[];
  MMerge(a,b,w);i:=1;
  while i<=l do
    c:=q[i];
    i:=i+1;
    for x in DATA.A do
      if ct[x+offset][c]<>0 then
        d:=ct[x+offset][c];
        ct[-x+offset][d]:=0;
        mu:=MRep(c);
        nu:=MRep(d);
        if ct[x+offset][mu]<>0 then
          if DATA.useAddition then
            v:=-pp[d]-aug[x+offset][c]+pp[c]+aug[x+offset][mu];
          else
            v:=WordProductLetterRep(-Reversed(pp[d]),-Reversed(aug[x+offset][c]),
                pp[c],aug[x+offset][mu]);
          fi;
          MMerge(nu,ct[x+offset][mu],v);
        elif ct[-x+offset][nu]<>0 then
          if DATA.useAddition then
            v:=-pp[c]+aug[x+offset][c]+pp[d]+aug[-x+offset][nu];
          else
            v:=WordProductLetterRep(-Reversed(pp[c]),aug[x+offset][c],
                  pp[d],aug[-x+offset][nu]);
          fi;
          MMerge(mu,ct[-x+offset][nu],v);
        else
          ct[x+offset][mu]:=nu;
          ct[-x+offset][nu]:=mu;
          if DATA.useAddition then
            v:=-pp[c]+aug[x+offset][c]+pp[d];
            aug[x+offset][mu]:=v;
            aug[-x+offset][nu]:=-v;
          else
            v:=WordProductLetterRep(-Reversed(pp[c]),aug[x+offset][c],pp[d]);
            aug[x+offset][mu]:=v;
            aug[-x+offset][nu]:=-Reversed(v);
          fi;
          NEWTC_AddDeduction(DATA.deductions,[mu,x]);
        fi;
      fi;
    od;
  od;
  # pp is not needed any longer
  for i in q do
    Unbind(pp[i]);
  od;
end );

# superseded by kernel function TC_QUICK_SCAN, left here for debugging purposes.
BindGlobal( "NEWTC_QuickScanLibraryVersion", function(c,offset,alpha,w)
local f,b,r,i,j;
  f:=alpha;i:=1;
  r:=Length(w);
  # forward scan
  while i<=r and c[w[i]+offset][f]<>0 do
    f:=c[w[i]+offset][f];
    i:=i+1;
  od;
  if i>r then
    if f<>alpha then
      w[1]:=i;w[2]:=f;
      return true;
    fi;
    return false;
  fi;

  #backward scan
  b:=alpha;j:=r;
  while j>=i and c[-w[j]+offset][b]<>0 do
    b:=c[-w[j]+offset][b];
    j:=j-1;
  od;
  if j<=i then
    w[1]:=i;w[2]:=f;w[3]:=j;w[4]:=b;
    return true;
  fi;
  return false;
end );

BindGlobal( "NEWTC_Scan", function(DATA,alpha,w)
local c,offset,f,b,r,i,j,t;
  c:=DATA.ct;
  offset:=DATA.offset;
  t:=TC_QUICK_SCAN(c,offset,alpha,w,DATA.scandata);

  if t=false then return; fi;

  r:=Length(w);
  i:=DATA.scandata[1]; # result of forward scan
  f:=DATA.scandata[2];
  if i>r then
    if f<>alpha then
      NEWTC_Coincidence(DATA,f,alpha);
    fi;
    return;
  fi;

  j:=DATA.scandata[3]; # result of backward scan
  b:=DATA.scandata[4];
  if j<i then
    NEWTC_Coincidence(DATA,f,b);
  elif j=i then
    # deduction
    c[w[i]+offset][f]:=b;
    c[-w[i]+offset][b]:=f;
    NEWTC_AddDeduction(DATA.deductions,[f,w[i]]);
  fi;
  return;


# the following is the original, old, code including loops. It is left here
# for debugging purposes

#  f:=alpha;i:=1;
#  r:=Length(w);
#  # forward scan
#  while i<=r and c[w[i]+offset][f]<>0 do
#    f:=c[w[i]+offset][f];
#    i:=i+1;
#  od;
#  if i>r then
#    if f<>alpha then
#      Coincidence(DATA,f,alpha);
#    fi;
#    return;
#  fi;
#
#  #backward scan
#  b:=alpha;j:=r;
#  while j>=i and c[-w[j]+offset][b]<>0 do
#    b:=c[-w[j]+offset][b];
#    j:=j-1;
#  od;
#  if j<i then
#    Coincidence(DATA,f,b);
#  elif j=i then
#    # deduction
#    c[w[i]+offset][f]:=b;
#    c[-w[i]+offset][b]:=f;
#    Add(DATA.deductions,[f,w[i]]);
#  fi;

end );

BindGlobal( "NEWTC_ModifiedScan", function(DATA,alpha,w,y)
local c,offset,f,b,r,i,j,fp,bp,t;
  #Info(InfoFpGroup,3,"MS",alpha,w,y,"\n");
  c:=DATA.ct;
  offset:=DATA.offset;
  t:=TC_QUICK_SCAN(c,offset,alpha,w,DATA.scandata);

  if t=false then return; fi;

  f:=alpha;i:=1;
  fp:=DATA.one;
  r:=Length(w);
  # forward scan
  while i<=r and c[w[i]+offset][f]<>0 do
    if DATA.useAddition then
      fp:=fp+DATA.aug[w[i]+offset][f];
    else
      fp:=WordProductLetterRep(fp,DATA.aug[w[i]+offset][f]);
    fi;
    f:=c[w[i]+offset][f];
    i:=i+1;
  od;
  if i>r then
    if f<>alpha then
      if DATA.useAddition then
        NEWTC_ModifiedCoincidence(DATA,f,alpha,-fp+y);
      else
        NEWTC_ModifiedCoincidence(DATA,f,alpha,WordProductLetterRep(-Reversed(fp),y));
      fi;
    fi;
    return;
  fi;
  #Info(InfoFpGroup,3,"MS2\n");

  #backward scan
  b:=alpha;j:=r;
  bp:=y;
  while j>=i and c[-w[j]+offset][b]<>0 do
    if DATA.useAddition then
      bp:=bp+DATA.aug[-w[j]+offset][b];
    else
      bp:=WordProductLetterRep(bp,DATA.aug[-w[j]+offset][b]);
    fi;
    b:=c[-w[j]+offset][b];
    j:=j-1;
  od;
  if j<i then
    if DATA.useAddition then
      NEWTC_ModifiedCoincidence(DATA,f,b,-fp+bp);
    else
      NEWTC_ModifiedCoincidence(DATA,f,b,WordProductLetterRep(-Reversed(fp),bp));
    fi;
  elif j=i then
    # deduction
    c[w[i]+offset][f]:=b;
    c[-w[i]+offset][b]:=f;
    if DATA.useAddition then
      DATA.aug[w[i]+offset][f]:=-fp+bp;
      DATA.aug[-w[i]+offset][b]:=-bp+fp;
    else
      DATA.aug[w[i]+offset][f]:=WordProductLetterRep(-Reversed(fp),bp);
      DATA.aug[-w[i]+offset][b]:=WordProductLetterRep(-Reversed(bp),fp);
    fi;
    NEWTC_AddDeduction(DATA.deductions,[f,w[i]]);
  fi;
end );

BindGlobal( "NEWTC_ScanAndFill", function(DATA,alpha,w)
local c,offset,f,b,r,i,j;
  c:=DATA.ct;
  offset:=DATA.offset;
  r:=Length(w);
  f:=alpha;i:=1;
  b:=alpha;j:=r;
  while i<=j do
    # forward scan
    while i<=r and c[w[i]+offset][f]<>0 do
      f:=c[w[i]+offset][f];
      i:=i+1;
    od;
    if i>r then
      if f<>alpha then
        NEWTC_Coincidence(DATA,f,alpha);
      fi;
      return;
    fi;

    #backward scan
    while j>=i and c[-w[j]+offset][b]<>0 do
      b:=c[-w[j]+offset][b];
      j:=j-1;
    od;
    if j<i then

      NEWTC_Coincidence(DATA,f,b);
    elif j=i then
      # deduction
      c[w[i]+offset][f]:=b;
      c[-w[i]+offset][b]:=f;
      NEWTC_AddDeduction(DATA.deductions,[f,w[i]]);
      return;
    else
      NEWTC_Define(DATA,f,w[i]);
    fi;
  od;
end );

BindGlobal( "NEWTC_ModifiedScanAndFill", function(DATA,alpha,w,y)
local c,offset,f,b,r,i,j,fp,bp;
  c:=DATA.ct;
  offset:=DATA.offset;
  f:=alpha;i:=1;
  fp:=DATA.one;
  r:=Length(w);
  b:=alpha;j:=r;
  bp:=y;
  while i<=j do #N
    # forward scan
    while i<=r and c[w[i]+offset][f]<>0 do
      if DATA.useAddition then
        fp:=fp+DATA.aug[w[i]+offset][f];
      else
        fp:=WordProductLetterRep(fp,DATA.aug[w[i]+offset][f]);
      fi;
      f:=c[w[i]+offset][f];
      i:=i+1;
    od;
    if i>r then
      if f<>alpha then
        if DATA.useAddition then
          NEWTC_ModifiedCoincidence(DATA,f,alpha,-fp+y);
        else
          NEWTC_ModifiedCoincidence(DATA,f,alpha,
            WordProductLetterRep(-Reversed(fp),y));
        fi;
      fi;
      return;
    fi;

    #backward scan
    while j>=i and c[-w[j]+offset][b]<>0 do
      if DATA.useAddition then
        bp:=bp+DATA.aug[-w[j]+offset][b];
      else
        bp:=WordProductLetterRep(bp,DATA.aug[-w[j]+offset][b]);
      fi;
      b:=c[-w[j]+offset][b];
      j:=j-1;
    od;
    if j<i then
      if DATA.useAddition then
        NEWTC_ModifiedCoincidence(DATA,f,b,-fp+bp);
      else
        NEWTC_ModifiedCoincidence(DATA,f,b,WordProductLetterRep(-Reversed(fp),bp));
      fi;
    elif j=i then
      # deduction
      c[w[i]+offset][f]:=b;
      c[-w[i]+offset][b]:=f;
      if DATA.useAddition then
        DATA.aug[w[i]+offset][f]:=-fp+bp;
        DATA.aug[-w[i]+offset][b]:=-bp+fp;
      else
        DATA.aug[w[i]+offset][f]:=WordProductLetterRep(-Reversed(fp),bp);
        DATA.aug[-w[i]+offset][b]:=WordProductLetterRep(-Reversed(bp),fp);
      fi;
      NEWTC_AddDeduction(DATA.deductions,[f,w[i]]);
      return;
    else
      NEWTC_Define(DATA,f,w[i]);
    fi;
  od;
end );

BindGlobal( "NEWTC_ProcessDeductions", function(DATA)
# both augmented and not
local ded,offset,pair,alpha,x,p,w;
  ded:=DATA.deductions;
  offset:=DATA.offset;
  p:=DATA.p;
  while Length(ded)>0 do
    pair:=Remove(ded);
    alpha:=pair[1];x:=pair[2];
    if p[alpha]=alpha then
      for w in DATA.ccr[x+offset] do
        if DATA.augmented then
          NEWTC_ModifiedScan(DATA,alpha,w,DATA.one);
        else
          NEWTC_Scan(DATA,alpha,w);
        fi;
        if p[alpha]<alpha then
          break; # coset has been eliminated
        fi;
      od;
    fi;
    # separate 'if' check, as the `break;` only ends innermost loop
    if p[alpha]=alpha then
      alpha:=DATA.ct[x+offset][alpha]; # beta
      if p[alpha]=alpha then
        # AH, 9/13/18: It's R^c_{x^-1}, so -x
        for w in DATA.ccr[offset-x] do
          if DATA.augmented then
            NEWTC_ModifiedScan(DATA,alpha,w,DATA.one);
          else
            NEWTC_Scan(DATA,alpha,w);
          fi;
          if p[alpha]<alpha then
            break; # coset has been eliminated
          fi;
        od;
      fi;
    fi;
  od;
end );

BindGlobal( "NEWTC_DoCosetEnum", function(freegens,freerels,subgens,aug,trace)
local m,offset,rels,ri,ccr,i,r,ct,A,a,w,n,DATA,p,dr,
  oldead,with,collapse,j,from,pp,PERCFACT,ap,ordertwo;

  # indicate at what change threshold display of coset Nr. should happen
  PERCFACT:=ValueOption("display");
  if not IsInt(PERCFACT) then PERCFACT:=100; fi;

  m:=Length(freegens);
  A:=List(freegens,LetterRepAssocWord);
  Assert(0,ForAll(A,x->Length(x)=1 and x[1]>0));
  if List(A,x->x[1])<>[1..m] then
    Error("noncanonical generator order not yet possible");
  fi;
  offset:=m+1;
  rels:=ShallowCopy(freerels);
  rels:=Filtered(freerels, x -> Length(x) > 0);
  SortBy(rels,Length);
  ri:=Union(rels,List(rels,x->x^-1));
  ri:=List(ri,LetterRepAssocWord);
  SortBy(ri,Length);
  A:=Concatenation([1..m],-[1..m]);

  # are generators known to be of order 2?
  ordertwo:=[];
  for i in [1..Length(ri)] do
    w:=ri[i];
    if Length(w)=2 and Length(Set(w))=1 then
      Unbind(ri[i]); # not needed any longer
      a:=AbsInt(w[1]);
      if not a in ordertwo then
        Info(InfoFpGroup,1,"Generator ",a," has order 2");
        AddSet(ordertwo,a);
        A:=Filtered(A,x->x<>-a);
      fi;
    fi;
  od;
  ri:=Compacted(ri);


  # cyclic conjugates, sort by first letter
  ccr:=List([1..2*m+1],x->[]);
  for i in ri do
    r:=i;
    while not r in ccr[offset+r[1]] do
      # replace order 2 gens
      for j in [1..Length(r)] do
        if -r[j] in ordertwo then r[j]:=-r[j];fi;
      od;
      AddSet(ccr[offset+r[1]],Immutable(r));
      r:=Concatenation(r{[2..Length(r)]},r{[1]});
    od;
  od;

  # coset table in slightly different format: row (offset+x) is for
  # generator x
  ct:=List([1..offset+m],x->[0]);Unbind(ct[offset]);

  n:=1;
  p:=[1];
  collapse:=[];
  DATA:=rec(ct:=ct,p:=p,ccr:=ccr,rels:=List(rels,LetterRepAssocWord),
         subgens:=subgens,
         subgword:=List(subgens,x->LetterRepAssocWord(UnderlyingElement(x))),
         n:=n,offset:=offset,A:=A,limit:=2^23,
         deductions:=[],dead:=0,defcount:=0,
         ordertwo:=ordertwo,s:=[],
         # a global list for the kernel scan function to return 4 variables
         scandata:=[0,0,0,0]);

  i:=ValueOption("limit");
  if i<>fail and Int(i)<>fail then
    DATA.limit:=i;
  fi;
  DATA.limtrigger:=Int(9/10*DATA.limit);

  if aug<>false then

    DATA.isCyclicMtcTable:=false;
    DATA.useAddition:=false;
    if ValueOption("cyclic")<>fail and Length(subgens)=1 then
      DATA.isCyclicMtcTable:=true;
      DATA.isAbelianizedMtcTable:=false;
      DATA.useAddition:=true;
      DATA.one:=0;
    elif ValueOption("abelian")<>fail then
      DATA.isAbelianizedMtcTable:=true;
      DATA.one:=ListWithIdenticalEntries(Length(subgens),0);
      DATA.useAddition:=true;
    else
      DATA.isAbelianizedMtcTable:=false;
      DATA.one:=[];
    fi;
    aug:=List([1..offset+m],x->[]);Unbind(aug[offset]);
    pp:=[DATA.one];
    DATA.aug:=aug;
    DATA.pp:=pp;
    DATA.secondary:=[];
    DATA.secount:=Length(subgens); # last to be used
    DATA.augmented:=true;

  else
    DATA.augmented:=false;
  fi;

  for a in ordertwo do
    DATA.ct[offset-a]:=DATA.ct[offset+a];
    if DATA.augmented then
      DATA.aug[offset-a]:=DATA.aug[offset+a];
    fi;
  od;

  if trace<>false then
    with:=[0]; # generator by which a coset was defined
    DATA.with:=with;
    from:=[0];
    DATA.from:=from;
  fi;
  Info( InfoFpGroup, 2, " \t defined\t deleted\t alive\t\t  maximal");

  for w in [1..Length(subgens)] do
    if DATA.augmented then
      if DATA.isCyclicMtcTable then
        NEWTC_ModifiedScanAndFill(DATA,1,DATA.subgword[w],1);
      elif DATA.isAbelianizedMtcTable then
        i:=ShallowCopy(DATA.one);
        i[w]:=1;
        NEWTC_ModifiedScanAndFill(DATA,1,DATA.subgword[w],i);
      else
        NEWTC_ModifiedScanAndFill(DATA,1,DATA.subgword[w],[w]);
      fi;
    else
      NEWTC_ScanAndFill(DATA,1,DATA.subgword[w]);
    fi;
  od;

  NEWTC_ProcessDeductions(DATA);

  # words we want to trace early (as they might reduce the number of
  # definitions
  if trace<>false then
    for w in trace do
      if IsList(w[1]) then
        w:=w[1]; # get word from value
      fi;
      repeat
        i:=1;
        ap:=1;
        while ap<=Length(w) do
          a:=w[ap];
          if ct[a+offset][i]=0 then
            dr:=NEWTC_Define(DATA,i,a);
            if dr=fail then return fail;fi;
            NEWTC_ProcessDeductions(DATA);
            #i:=p[i]; # in case there is a change
            ap:=Length(w)+10;
          fi;
          i:=ct[a+offset][i];
          ap:=ap+1;
        od;
      until ap=Length(w)+1;
    od;
  fi;

  i:=1;
  while i<=DATA.n do

    for a in A do
      if p[i]=i then
        if ct[a+offset][i]=0 then
          dr:=NEWTC_Define(DATA,i,a);
          if dr=fail then return fail;fi;
          oldead:=DATA.dead;
          NEWTC_ProcessDeductions(DATA);
          if PERCFACT*(DATA.dead-oldead)>DATA.n then
            if DATA.n>1000 then
              Info( InfoFpGroup, 2, "\t", DATA.defcount, "\t\t", DATA.dead,
              "\t\t", DATA.n-DATA.dead, "\t\t", DATA.n );
            fi;
            if IsBound(DATA.with) then
              # collapse -- find collapse word
              # in two different ways (as they can differ after compression)

              # first trace through the coset table, this uses the prior
              # reductions
              j:=i;
              while j<>p[j] do
                j:=p[j];
              od;
              w:=[a]; # last letter added
              while j<>1 do
                Assert(2,j=p[j]);
                Add(w,with[j]);
                Assert(2,0<>ct[-with[j]+offset][j]);
                j:=ct[-with[j]+offset][j]; # unapply this generator
              od;

              # free reduce -- partial collapse can lead to not free cancellation
              # and fix order
              w:=Reversed(FreelyReducedLetterRepWord(w));
              #w1:=w;

              j:=PositionProperty(collapse,x->x[1]=w);
              if j=fail then
                Add(collapse,[w,DATA.dead-oldead]); # word that caused a collapse
              else
                collapse[j][2]:=Maximum(collapse[j][2],DATA.dead-oldead);
              fi;

              # now use the `from' list (which does not collapse under
              # coincidences, only under compression) and not the coset table,
              #  as it # keeps the old definition order, not yet using coincidence
              j:=i;
              w:=[a]; # last letter added
              while j<>1 do
                Add(w,with[j]);
                j:=from[j];
              od;

              # free reduce -- partial collapse can lead to not free
              # cancellation and fix order
              w:=Reversed(FreelyReducedLetterRepWord(w));

              j:=PositionProperty(collapse,x->x[1]=w);
              if j=fail then
                Add(collapse,[w,DATA.dead-oldead]); # word caused collapse
              else
                collapse[j][2]:=Maximum(collapse[j][2],DATA.dead-oldead);
              fi;

              Info(InfoFpGroup,3,"collapse ",DATA.dead-oldead);

            fi;
          fi;

        fi;
      fi;
    od;

    # conditions for compression: Over half the table used, and
    if 2*DATA.n>DATA.limit and
      # at least 33% trash (4=1+1/0.33)
      ( 4*DATA.dead>DATA.n or
      # over limtrigger and at least 2% (55=1+1/0.02) trash
      (51*DATA.dead>DATA.n and DATA.n>DATA.limtrigger) )  then

      Info( InfoFpGroup, 2, "\t", DATA.defcount, "\t\t", DATA.dead,
      "\t\t", DATA.n-DATA.dead, "\t\t", DATA.n );
      i:=Number([1..i],x->p[x]=x);
      NEWTC_Compress(DATA,false);
      p:=DATA.p;
      if DATA.augmented then
        pp:=DATA.pp;
      fi;
      if DATA.n>DATA.limtrigger then
        DATA.limtrigger:=Maximum(DATA.limit-1,DATA.n+2);
      fi;
    fi;

    i:=i+1;
  od;


  NEWTC_Compress(DATA,true); # always compress at the end
  DATA.index:=DATA.n;

  Info(InfoFpGroup,3,"found index ",DATA.index);

  if Length(collapse)>0 then
    Info(InfoFpGroup,3,DATA.defcount," definitions");
    # which collapses gave at least 1%
    collapse:=Filtered(collapse,x->x[2]*PERCFACT>DATA.n and not x in trace and
               # not prefix of any trace
               not ForAny(trace,y->y[1]{[1..Minimum(Length(x),Length(y[1]))]}=x
               # or proper prefix of another in collapse
               and not ForAny(collapse,y->Length(y)>Length(x) and
                y{[1..Length(x)]}=x)));
    if Length(collapse)>0 then
      # give list for improvement
      # type is c_ollapse
      return
      rec(type:="c",collapse:=collapse,limit:=DATA.limit,defcount:=DATA.defcount,data:=DATA);
    fi;
  fi;

  return rec(type:="t",limit:=DATA.limit,defcount:=DATA.defcount,data:=DATA);

end );

#freegens,fgreerels,subgens,doaugmented,trace
# Options: limit, quiet (return fail if run out of space)
# cyclic (if given and 1 generator do special case of cyclic rewriting)
InstallGlobalFunction(NEWTC_CosetEnumerator,function(arg)
local freegens,freerels,subgens,aug,trace,e,ldc,up,bastime,start,bl,bw,first,timerFunc,addtrace;

  timerFunc := GET_TIMER_FROM_ReproducibleBehaviour();

  freegens:=arg[1];
  freerels:=arg[2];
  subgens:=arg[3];
  aug:=IsBound(arg[4]);
  trace:=IsBound(arg[5]);
  if aug<>false then
    aug:=arg[4];
  fi;
  if aug<>false then
    # if augmented, optimize by default
    if trace=false then
      trace:=[];
    else
      trace:=arg[5];
    fi;
  elif trace<>false then
    trace:=arg[5];
  fi;
  start:=timerFunc();

  if aug and trace=false then
    e:=NEWTC_DoCosetEnum(freegens,freerels,subgens,aug,trace);
    if e=fail then return fail;fi;
  else
    e:=NEWTC_DoCosetEnum(freegens,freerels,subgens,false,trace);
    if e=fail then return fail;fi;
    bastime:=timerFunc()-start;
    bl:=e.defcount;
    bw:=[];
    ldc:=infinity;
    up:=0;
    start:=timerFunc();
    first:=true;
    while trace<>false and e.type="c" and (up<=2 or
      2*(timerFunc()-start)<=bastime) do
      #up<=2 do
      ldc:=e.defcount;
      if first=true then
        first:=e.defcount;
        Info(InfoFpGroup,1,"optimize definition sequence");
      else
        Info(InfoFpGroup,2,"Now ",e.defcount," defs");
      fi;
      addtrace:=Filtered(e.collapse,x->x[2]>2);
      Append(trace,addtrace);
      SortBy(trace,x->[Length(x[1]),-x[2]]);
      e:=NEWTC_DoCosetEnum(freegens,freerels,subgens,false,trace:
          # that's what we had last time -- no need to whine
          limit:=e.limit);
      if e=fail then return fail;fi;
      if e.defcount/bl<98/100 then
        bl:=e.defcount;
        bw:=ShallowCopy(trace);
      fi;

      # 2% improvement threshold
      if 102/100*e.defcount<=ldc then
        up:=0;
        start:=timerFunc();
      else
        up:=up+1;
      fi;
    od;
    if first<>true then
      Info(InfoFpGroup,1,"Reduced ",first," definitions to ",e.defcount);
    fi;
    if aug then
      # finally do the augmented with best
      e:=NEWTC_DoCosetEnum(freegens,freerels,subgens,true,bw:
          # that's what we had last time -- no need to whine
          limit:=e.limit);
      if e=fail then return fail;fi;
    fi;
  fi;
  if not aug then
    # return the ordinary coset table in standard formatting
    up:=[];
    for start in [1..Length(freegens)] do
      Add(up,start+e.data.offset);
      Add(up,-start+e.data.offset);
    od;
    ldc:=e.data.ct{up};
    StandardizeTable(ldc);
    return ldc;
  fi;

  aug:=rec(isNewAugmentedTable:=true,
           isCyclicMtcTable:=e.data.isCyclicMtcTable,
           isAbelianizedMtcTable:=e.data.isAbelianizedMtcTable,
           useAddition:=e.data.useAddition,
           n:=e.data.n,
           A:=e.data.A,
           index:=e.data.index,
           rels:=e.data.rels,
           ct:=e.data.ct,
           one:=e.data.one,
           aug:=e.data.aug,
           defcount:=e.data.defcount,
           secount:=e.data.secount,
           secondary:=e.data.secondary,
           subgens:=e.data.subgens,
           subgword:=e.data.subgword,
           offset:=e.data.offset
              );
  if IsBound(e.data.from) then
    aug.from:=e.data.from;
  fi;
  return aug;
end);

BindGlobal( "NEWTC_Rewrite", function(arg)
local DATA,start,w,offset,c,i,j;
  DATA:=arg[1];
  start:=arg[2];
  w:=arg[3];
  offset:=DATA.offset;
  c:=DATA.one;
  i:=start;
  for j in w do
    if DATA.useAddition then
      c:=c+DATA.aug[j+offset][i];
    else
      c:=WordProductLetterRep(c,DATA.aug[j+offset][i]);
    fi;
    i:=DATA.ct[j+offset][i];
  od;
  if Length(arg)>3 and arg[4]<>i then
    Error("Trace did not end at expected coset");
  fi;
  return c;
end );

DeclareGlobalName("NEWTC_ReplacedStringCyclic");
BindGlobal( "NEWTC_ReplacedStringCyclic", function(s,r,cyc)
local p,new,start,half;
  if Length(s)<Length(r) or Length(r)=0 then
    return s;
  fi;
  p:=PositionSublist(s,r);
  if p<>fail then
    new:=s{[1..p-1]};
    start:=p+Length(r);
    p:=PositionSublist(s,r,start);
    while p<>fail do
      if start>Length(s) or Length(new)=0 or new[Length(new)]<>-s[start] then
        Append(new,s{[start..p-1]});
      else
        new:=WordProductLetterRep(new,s{[start..p-1]});
      fi;
      start:=p+Length(r);
      p:=PositionSublist(s,r,start);
    od;
    if start>Length(s) or Length(new)=0 or new[Length(new)]<>-s[start] then
      Append(new,s{[start..Length(s)]});
    else
      new:=WordProductLetterRep(new,s{[start..Length(s)]});
    fi;
  else
    new:=s;
  fi;

  if Length(r)=1 or cyc=false then
    return new; # no overlap or so possible
  fi;

  # Now cyclic reduction means that r overlaps tail to front. Thus either
  # the second half of r occurs in the front or the front half of r occurs
  # in the end of s.

  half:=QuoInt(Length(r),2)+1;
  p:=PositionSublist(new,r{[half..Length(r)]});
  if p<>fail and p<half then
    if new{[1..p-1]}=r{[half-p+1..half-1]}
      and new{[Length(new)-half+p+1..Length(new)]}=r{[1..half-p]} then

      new:=new{[Length(r)-half+p+1..Length(new)-half+p]};
    fi;
  elif p<>fail then
    # second half arises later. Does also first half arise -- if so we need
    # to go through once more
    if new{[p-half+1..p-1]}=r{[1..half-1]} then
      new:=NEWTC_ReplacedStringCyclic(new,r,cyc);
      return new;
    fi;
  fi;

  p:=PositionSublist(new,r{[1..half-1]});
  if p<>fail and p>=Length(new)-Length(r)+1
    and new{[p..Length(new)]}=r{[1..Length(new)-p+1]}
    and p>Length(new)+p-1 and
    new{[1..Length(r)-Length(new)+p-1]}=r{[Length(new)-p+2..Length(r)]} then

    new:=new{[Length(r)-Length(new)+p..p-1]};
  fi;

  return new;
end );


InstallGlobalFunction(NEWTC_CyclicSubgroupOrder,function(DATA)
local rels,r,i,w;

  rels:=0;
  r:=NEWTC_Rewrite(DATA,1,DATA.subgword[1])-1;
  rels:=Gcd(rels,r);

  for i in [1..DATA.n] do
    for w in DATA.rels do
      r:=NEWTC_Rewrite(DATA,i,w);
      rels:=Gcd(rels,r);
    od;
  od;

  return rels;
end);

BindGlobal( "NEWTC_AbelianizedRelatorsSubgroup", function(DATA)
local rels,r,i,w,subnum;

  subnum:=Length(DATA.subgens);
  rels:=[];

  for i in [1..subnum] do
    r:=ShallowCopy(NEWTC_Rewrite(DATA,1,DATA.subgword[i]));
    r[i]:=r[i]-1;
    if not IsZero(r) and not r in rels and not -r in rels then
      AddSet(rels,r);
    fi;
  od;

  for i in [1..DATA.n] do
    CompletionBar(InfoFpGroup,2,"Coset Loop: ",i/DATA.n);
    for w in DATA.rels do
      r:=NEWTC_Rewrite(DATA,i,w);
      if not IsZero(r) and not r in rels and not -r in rels then
        AddSet(rels,r);
      fi;
    od;
  od;
  CompletionBar(InfoFpGroup,2,"Coset Loop: ",false);

  return rels;
end );

#############################################################################
##
#M  RelatorMatrixAbelianizedSubgroupMtc( <G>, <H> ) . . . . .  relator matrix
#M  . . . . . . . . . . . . . . . . . . . . . .   for an abelianized subgroup
##
##  'RelatorMatrixAbelianizedSubgroupMtc'   uses  the  Modified  Todd-Coxeter
##  coset representative enumeration method  to compute  a matrix of abelian-
##  ized defining relators for a subgroup H of a finitely presented group  G.
##
InstallGlobalFunction( RelatorMatrixAbelianizedSubgroupMtc,
function ( G, H )

    local aug,rels;

    # check the arguments to be a finitely presented group and a subgroup of
    # that group.
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # do a Modified Todd-Coxeter coset representative enumeration to
    # construct an augmented coset table of H.
    aug := NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(G),RelatorsOfFpGroup(G),GeneratorsOfGroup(H),true,false:abelian:=true);

    # determine a set of abelianized subgroup relators.
    rels:=NEWTC_AbelianizedRelatorsSubgroup(aug);
    return rels;

end );

# DATA, [parameter,string]
# parameter is:
# 0: Full reduction
# 1: Do a quick reduction without trying to eliminate all secondary gens.
# -1: No relators
InstallGlobalFunction(NEWTC_PresentationMTC,function(arg)
local DATA,rels,i,j,w,f,r,s,fam,ri,a,offset,rset,re,stack,pres,
  subnum,parameter,str,wordefs;

  DATA:=arg[1];
  if Length(arg)=1 then
    parameter:=0;
  else
    parameter:=arg[2];
  fi;
  if Length(arg)>2 then
    str:=arg[3];
  else
    str:="%";
  fi;


  offset:=DATA.offset;
  subnum:=Length(DATA.subgens);
  rels:=[];

  for i in [1..subnum] do
    r:=WordProductLetterRep(NEWTC_Rewrite(DATA,1,DATA.subgword[i]),[-i]);
    if Length(r)>0 then
      Add(rels,r);
    fi;
  od;

  stack:=[];

  if parameter<>-1 then

    for i in [1..DATA.n] do
      CompletionBar(InfoFpGroup,2,"Coset Loop: ",i/DATA.n);
      for w in DATA.rels do
        r:=NEWTC_Rewrite(DATA,i,w);
        MakeCanonical(r);

        ri:=Length(r);
        # reduce with others
        for j in rels do
          r:=NEWTC_ReplacedStringCyclic(r,j,true);
          r:=NEWTC_ReplacedStringCyclic(r,-Reversed(j),true);
        od;
        Info(InfoFpGroup,3,"Relatorlen ",ri,"->",Length(r));

        if Length(r)>0 then
          Add(stack,r);
          while Length(stack)>0 do
            r:=Remove(stack);
            ri:=-Reversed(r);
            rset:=Set([r,ri]);
            # reduce others
            j:=1;
            while j<=Length(rels) do
              s:=rels[j];
              for re in rset do;
                s:=NEWTC_ReplacedStringCyclic(s,re,true);
              od;
              if not IsIdenticalObj(s,rels[j]) then
                if Length(s)>0 then
                  Add(stack,s);
                fi;
                rels:=WordProductLetterRep(rels{[1..j-1]},rels{[j+1..Length(rels)]});
              else
                j:=j+1;
              fi;
            od;

            Add(rels,r);
            SortBy(rels,Length);

            # does it occur in the augmented table?
            for a in DATA.A do
              for j in [1..DATA.n] do
                s:=DATA.aug[a+offset][j];
                if Length(s)>=Length(r) then
                  for re in rset do
                    # NOT cyclic replace!
                    s:=NEWTC_ReplacedStringCyclic(s,re,false);
                  od;
                  DATA.aug[a+offset][j]:=s;
                fi;
              od;
            od;
          od;
        fi;
      od;
    od;
    CompletionBar(InfoFpGroup,2,"Coset Loop: ",false);
  fi;

  # add definitions of secondary generators
  wordefs:=[];
  for i in [subnum+1..DATA.secount] do
    r:=WordProductLetterRep(DATA.secondary[i],[-i]);
    Add(rels,r);
    wordefs[i]:=r;
  od;

  if ForAll(str,IsString) and DATA.secount >=Length(str) then
    r:=ShallowCopy(str);
    s:=0;
    while Length(r)<DATA.secount do
      s:=s+1;
      Add(r,Concatenation("__xtra__",String(s)));
    od;
    f:=FreeGroup(r);
  else
    f:=FreeGroup(DATA.secount,str);
  fi;
  fam:=FamilyObj(One(f));
  rels:=List(rels,x->AssocWordByLetterRep(fam,x));
  pres:=PresentationFpGroup(f/rels);
  TzOptions(pres).protected:=subnum;
  TzOptions(pres).printLevel:=InfoLevel(InfoFpGroup);
  if parameter=1 then
    TzSearch(pres);
    TzOptions(pres).lengthLimit:=pres!.tietze[TZ_TOTAL]+1;
  fi;
  TzOptions(pres).eliminationsLimit:=5;
  TzGoElim(pres,subnum,wordefs);
  if IsEvenInt(parameter) and Length(GeneratorsOfPresentation(pres))>subnum then
    Error("did not eliminate properly");
#    warn:=true;
#    # Help Tietze with elimination
#    bad:=Reversed(List(GeneratorsOfPresentation(pres)
#          {[subnum+1..Length(GeneratorsOfPresentation(pres))]},
#          x->LetterRepAssocWord(x)[1]));
#    for i in bad do
#      r:=DATA.secondary[i];
#      re:=true;
#      while re do
#        s:=[];
#        re:=false;
#        for j in r do
#          if AbsInt(j)>subnum then
#            re:=true;
#            if j>0 then
#              Append(s,DATA.secondary[j]);
#            else
#              Append(s,-Reversed(DATA.secondary[-j]));
#            fi;
#          else
#            Add(s,j);
#          fi;
#        od;
#        Info(InfoFpGroup,2,"Length =",Length(s));
#        r:=s;
#        if warn and Length(s)>100*Sum(rels,Length) then
#          warn:=false;
#          Error(
#            "Trying to eliminate all auxiliary generators might cause the\n",
#            "size of the presentation to explode. Proceed at risk!");
#        fi;
#      od;
#      r:=AssocWordByLetterRep(fam,Concatenation(r,[-i]));
#      AddRelator(pres,r);
#      #TzSearch(pres); Do *not* search, as this might kill the relator we
#      #just added.
#      TzEliminate(pres,i);
#    od;
#    Assert(0,Length(GeneratorsOfPresentation(pres))=subnum);

  fi;
  r:=List(GeneratorsOfPresentation(pres){[1..subnum]},
    x->LetterRepAssocWord(x)[1]);
  pres!.primarywords:=r;
  r:=List(GeneratorsOfPresentation(pres){
      [subnum+1..Length(GeneratorsOfPresentation(pres))]},
        x->LetterRepAssocWord(x)[1]);
  pres!.secondarywords:=r;
  return pres;
end);

#############################################################################
##
#M  PresentationSubgroupMtc(<G>, <H> [,<string>] [,<print level>] ) . . . . .
#M                                               Tietze record for a subgroup
##
##  'PresentationSubgroupMtc' uses the Modified Todd-Coxeter coset represent-
##  ative enumeration method  to compute a presentation  (i.e. a presentation
##  record) for a subgroup H of a finitely presented group G.  The generators
##  in the resulting presentation will be named   <string>1, <string>2, ... ,
##  the default string is `\"_x\"'.
##
InstallGlobalFunction( PresentationSubgroupMtc,function ( arg )
  local G,H,string,DATA,i;

  # check the first two arguments to be a finitely presented group and a
  # subgroup of that group.
  G := arg[1];
  if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
      Error( "<G> must be a finitely presented group" );
  fi;
  H := arg[2];
  if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
      Error( "<H> must be a subgroup of <G>" );
  fi;

  # initialize the generators name string and the print level.
  string := "_x";

  # get the optional parameters.
  for i in [ 3 .. 4 ] do
      if Length( arg ) >= i then
          if IsString( arg[i] ) then string := arg[i];
          else
              Error( "optional parameter must be a string or an integer" );
          fi;
      fi;
  od;

  DATA:=NEWTC_CosetEnumerator(FreeGeneratorsOfFpGroup(G),
          RelatorsOfFpGroup(G),
          List(GeneratorsOfGroup(H),UnderlyingElement),true,

          # for compatibility, do not try the optimization
          false);

  return NEWTC_PresentationMTC(DATA,0,string);
end);



#####################################
# The following code is not used any longer and is relics of the old Mtc
# implementation.
