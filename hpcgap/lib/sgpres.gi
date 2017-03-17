#############################################################################
##
#W  sgpres.gi                  GAP library                     Volkmar Felsch
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
  if Length(M)=0 then
    return [];
  else
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

InstallMethod( AugmentedCosetTableRrsInWholeGroup, "use Mtc table", true,
  [IsSubgroupFpGroup and HasAugmentedCosetTableMtcInWholeGroup], 0,
  AugmentedCosetTableMtcInWholeGroup);

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

    local   fgens,                  # generators of asscociated free group
            grels,                  # relators of G
            sgens,                  # subgroup generators of H
            fsgens,                 # preimages of subgroup generators in F
            involutions,            # indices of involutory gens of G
            next,  prev,            # next and previous coset on lists
            fact,                   # factor to previous coset rep
            firstFree,  lastFree,   # first and last free coset
            firstDef,   lastDef,    # first and last defined coset
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
            rel,                    # loop variable for relations
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
            numcols,                # number of columns in the tables
            numoccs,                # number of gens which occur in the table
            occur,                  #
            treeNums,               #
            exponent,               # order of subgroup in case type = 1
            convert,                # conversion list for subgroup generators
            aug,                    # augmented coset table
            field,                  # loop variable for record field names
	    silent;		    # do we want the algorithm to silently
	                            # return `fail' if the algorithm did not
				    # finish in the permitted size?

    # check the arguments
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    # get some local variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
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
    Info( InfoFpGroup, 2, "AugmentedCosetTableMtc called:" );
    Info( InfoFpGroup, 2, "    defined deleted alive   maximal");
    nrdef := 1;
    nrmax := 1;
    nrdel := 0;
    nrinf := 1000;

    # initialize size of the table
    limit := CosetTableDefaultLimit;
    maxlimit:=ValueOption("max");
    if maxlimit=fail or not IsInt(maxlimit) then
      maxlimit := CosetTableDefaultMaxLimit;
    fi;

    silent:=ValueOption("silent")=true;

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
    involutions := IndicesInvolutaryGenerators( G );
    table := [ ];                                           
    coFacTable := [ ];                                                    
    for i in [ 1 .. Length( fgens ) ] do           
        g := ListWithIdenticalEntries( limit, 0 );            
        f := ListWithIdenticalEntries( limit, 0 );                         
        Add( table, g );                                              
        Add( coFacTable, f );                                     
        if not i in involutions then
            g := ListWithIdenticalEntries( limit, 0 );            
            f := ListWithIdenticalEntries( limit, 0 );                
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
    relsGen := RelsSortedByStartGen( fgens, rels, table, true );

    # make the rows for the subgroup generators
    subgroup := [ ];
    for rel  in fsgens  do
      #T this code should use ExtRepOfObj -- its faster
      # cope with SLP elms
      if IsStraightLineProgElm(rel) then
        rel:=EvalStraightLineProgElm(rel);
      fi;
      length := Length( rel );
      nums := [ ]; 
      cols := [ ]; 
      if length>0 then
        length2 := 2 * length;
	nums[length2] := 0;
	cols[length2] := 0;

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
      fi;
      Add( subgroup, [ nums, cols ] );
    od;

    # define the primary subgroup generators.
    ngens := numgens;
    defs := fsgens;

    # initialize the tree of secondary generators.
    if type = 1 then
        treelength := 1;
        tree1 := [ 1 ];
        tree2 := [ 0 ];
    elif type = 0 then
        treelength := numgens;
        length := treelength + 100;
        tree1 := ListWithIdenticalEntries( length, 0 );
        for i in [ 1 .. numgens ] do
            tree1[i] := ListWithIdenticalEntries( i, 0 );
            tree1[i][i] := 1;
        od;
        tree2 := ListWithIdenticalEntries( numgens, 0 );
    else
        treelength := numgens;
        length := treelength + 100;
        tree1 := ListWithIdenticalEntries( length, 0 );
        tree2 := ListWithIdenticalEntries( length, 0 );
    fi;
    tree := [ tree1, tree2, treelength, numgens, type ];

    # add an empty deduction list
    deductions := [ ];

    # initialize the subgroup exponent (which is needed in case type = 1)
    exponent := 0;

    # check if the subgroup generator is an involution?
    if type = 1 and NumberSyllables(fsgens[1])=1 then
        i := Position( fgens, fsgens[1] );
        if i <> fail then
            if IsIdenticalObj( table[2*i-1], table[2*i] ) then
               exponent := 2;
            fi;

	    # do we have power relators for this generator?
	    i:=GeneratorSyllable(fsgens[1],1);
	    for j in rels do
	      if NumberSyllables(j)=1 and GeneratorSyllable(j,1)=i then
	        exponent:=Gcd(exponent,AbsInt(ExponentSyllable(j,1)));
	      fi;
	    od;
        fi;
    fi;

    # make the structure that is passed to 'MakeConsequences2'
    app := ListWithIdenticalEntries( 16, 0 );
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
			if silent then
			  return fail;
			fi;
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
                nrdel := nrdel + MakeConsequences2( app );
                firstFree := app[6];
                lastFree  := app[7];
                firstDef  := app[8];
                lastDef   := app[9];

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

    Info( InfoFpGroup, 2, "\t", nrdef, "\t", nrdel, "\t", nrdef-nrdel,
        "\t", nrmax );

    # In case of type = -1 return just index and exponent of the given cyclic
    # subroup.
    if ttype = -1 then
        index := nrdef - nrdel;
        SetIndexInWholeGroup( H, index );
        Info( InfoFpGroup, 1, "index = ", index, "  total = ", nrdef,
            "  max = ", nrmax );
        aug := rec( );
	aug.index := index;
        exponent := app[16];
        if exponent = 0 then
            exponent := infinity;
        elif exponent < 0 then
            exponent := - exponent;
        fi;
        aug.exponent := exponent;
        return aug;
    fi;

    # separate pairs of identical columns in the coset tables.
    for i in [ 1 .. Length( fgens ) ] do                         
        if i in involutions then
            table[2*i] := StructuralCopy( table[2*i-1] );       
            coFacTable[2*i] := StructuralCopy( coFacTable[2*i-1] );       
        fi;                                        
    od;

    # standardize the tables.
    StandardizeTable2( table, coFacTable );

    # save coset table and index in the group record of H.
    if not HasCosetTableInWholeGroup( H ) then
        SetCosetTableInWholeGroup( H, table );
    fi;
    index := IndexCosetTab( table );
    if not HasIndexInWholeGroup( H ) then
        SetIndexInWholeGroup( H, index );
        Info( InfoFpGroup, 1, "index = ", index, "  total = ", nrdef,
            "  max = ", nrmax );
    elif IndexInWholeGroup( H ) <> index then
        Error( "inconsistent values for the index of H in G" );
    fi;

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
        treeNums := [ 1 .. numoccs ];
        for j in [ numgens+1 .. treelength ] do
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
    aug.tableType := TABLE_TYPE_MTC;
    aug.groupGenerators := fgens;
    aug.groupRelators := grels;
    aug.cosetTable := table;
    aug.cosetFactorTable := coFacTable;
    aug.primaryGeneratorWords := defs;
    aug.numberOfSubgroupGenerators := ngens;
    aug.nameOfSubgroupGenerators := Immutable( string );
    aug.subgroupGenerators := gens;
    aug.tree := tree;

    if type = 1 then
        exponent := app[16];
        if exponent = 0 then
            aug.exponent := infinity;
            aug.subgroupRelators := [ [ ] ];
        else
            if exponent < 0 then  exponent := - exponent;  fi;
            aug.exponent := exponent;
            aug.subgroupRelators :=
                [ ListWithIdenticalEntries( exponent, 1 ) ];
        fi;

    elif type = 2 then
        aug.treeNumbers := treeNums;

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
    fi;

    # ensure that all components of the augmented coset table are immutable.
    for field in RecFields( aug ) do
      MakeImmutable( aug.(field) );
    od;

    # display a message
    if treelength > 0 then
        numgens := Length( defs );
        Info( InfoFpGroup, 1, "MTC defined ", numgens, " primary and ",
            treelength - numgens, " secondary subgroup generators" );
    fi;

    # return the augmented coset table.
    return aug;
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

    local   fgens,                  # generators of asscociated free group
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
    ApplyRel2( app2, triple[2], triple[1] );
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
    for field in RecFields( aug ) do
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
##  normal closure  N, say,  of a subgroup H of a finitely presented group G.
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
#M  PresentationSubgroupMtc(<G>, <H> [,<string>] [,<print level>] ) . . . . .
#M                                               Tietze record for a subgroup
##
##  'PresentationSubgroupMtc' uses the Modified Todd-Coxeter coset represent-
##  ative enumeration method  to compute a presentation  (i.e. a presentation
##  record) for a subgroup H of a finitely presented group G.  The generators
##  in the resulting presentation will be named   <string>1, <string>2, ... ,
##  the default string is `\"_x\"'.
##  The default print level is 1.
##  If the print level is set to 0, then the printout of the 'DecodeTree'
##  command will be suppressed.
##
InstallGlobalFunction( PresentationSubgroupMtc,
    function ( arg )

    local aug, G, gens, H, i, printlevel, ngens, string, T;

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
    printlevel := 1;

    # get the optional parameters.
    for i in [ 3 .. 4 ] do
        if Length( arg ) >= i then
            if IsInt( arg[i] ) then printlevel := arg[i];
            elif IsString( arg[i] ) then string := arg[i];
            else
                Error( "optional parameter must be a string or an integer" );
            fi;
        fi;
    od;

    # get a copy of an augmented MTC coset table of H in G.
    aug := CopiedAugmentedCosetTable(
        AugmentedCosetTableMtcInWholeGroup( H ) );

    # insert the required subgroup generator names if necessary.
    if aug.nameOfSubgroupGenerators <> string then
        aug.nameOfSubgroupGenerators := string;
        ngens := aug.numberOfSubgroupGenerators;
        gens := GeneratorsOfGroup( FreeGroup( ngens, string ) );
        aug.subgroupGenerators := gens;
    fi;

    # determine a set of subgroup relators.
    aug.subgroupRelators := RewriteSubgroupRelators( aug, aug.groupRelators);

    # create a Tietze record for the resulting presentation.
    T := PresentationAugmentedCosetTable( aug, string );
    if printlevel >= 1 then  TzPrintStatus( T, true );  fi;

    # decode the subgroup generators tree.
    Info( InfoFpGroup, 1, "calling DecodeTree" );
    TzOptions(T).printLevel := printlevel;
    DecodeTree( T );
    TzOptions(T).printLevel := 1;

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
#M  RelatorMatrixAbelianizedSubgroupMtc( <G>, <H> ) . . . . .  relator matrix
#M  . . . . . . . . . . . . . . . . . . . . . .   for an abelianized subgroup
##
##  'RelatorMatrixAbelianizedSubgroupMtc'   uses  the  Modified  Todd-Coxeter
##  coset representative enumeration method  to compute  a matrix of abelian-
##  ized defining relators for a subgroup H of a finitely presented group  G.
##
InstallGlobalFunction( RelatorMatrixAbelianizedSubgroupMtc,
    function ( G, H )

    local aug;

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
    aug := AugmentedCosetTableMtc( G, H, 0, "_x" );

    # determine a set of abelianized subgroup relators.
    aug.subgroupRelators := RewriteAbelianizedSubgroupRelators( aug,
			     aug.groupRelators);

    return aug.subgroupRelators;

end );


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

    local aug, table;

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
#	  p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#	  nneg:=ExponentSyllable(grel,si)>0;
#	  for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#	    i:=i+1;
#	    if nneg then
#	      nums[2*i]   := p-1;
#	      nums[2*i-1] := p;
#	      cols[2*i]   := cosTable[p-1];
#	      cols[2*i-1] := cosTable[p];
#	    else
#	      nums[2*i]   := p;
#	      nums[2*i-1] := p-1;
#	      cols[2*i]   := cosTable[p];
#	      cols[2*i-1] := cosTable[p-1];
#	    fi;
#	  od;
#	od;
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
            ApplyRel2( app2, cols, nums );

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
#	  p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#	  nneg:=ExponentSyllable(grel,si)>0;
#	  for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#	    i:=i+1;
#	    if nneg then
#	      nums[2*i]   := p-1;
#	      nums[2*i-1] := p;
#	      cols[2*i]   := cosTable[p-1];
#	      cols[2*i-1] := cosTable[p];
#	    else
#	      nums[2*i]   := p;
#	      nums[2*i-1] := p-1;
#	      cols[2*i]   := cosTable[p];
#	      cols[2*i-1] := cosTable[p-1];
#	    fi;
#	  od;
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
        ApplyRel2( app2, cols, nums );

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
#M  RewriteSubgroupRelators( <aug>, <prels> ) rewrite subgroup relators from
#M                                                   an augmented coset table
##
##  'RewriteSubgroupRelators'  is a subroutine  of the  Reduced Reidemeister-
##  Schreier and the  Modified Todd-Coxeter  routines.  It computes  a set of
##  subgroup relators from the coset factor table of an augmented coset table
##  and the  relators <prels> of the  parent  group.  It assumes  that  <aug>
##  is an augmented coset table of type 2.
##
InstallGlobalFunction( RewriteSubgroupRelators,
    function ( aug, prels )

    local app2, coFacTable, cols, convert, cosTable, factor, ggensi,
          greli,grel, i, index, j, last, length, nums, numgens, p, rel, rels,
          treelength, type,si,nneg,ei,word;

    # check the type.
    type := aug.type;
    if type <> 2 then  Error( "invalid type; it should be 2" );  fi;

    # initialize some local variables.
    ggensi := List(aug.groupGenerators,i->AbsInt(LetterRepAssocWord(i)[1]));
    cosTable := aug.cosetTable;
    coFacTable := aug.cosetFactorTable;
    index := Length( cosTable[1] );
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
#	  p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#	  nneg:=ExponentSyllable(grel,si)>0;
#	  for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#	    i:=i+1;
#	    if nneg then
#	      nums[2*i]   := p-1;
#	      nums[2*i-1] := p;
#	      cols[2*i]   := cosTable[p-1];
#	      cols[2*i-1] := cosTable[p];
#	    else
#	      nums[2*i]   := p;
#	      nums[2*i-1] := p-1;
#	      cols[2*i]   := cosTable[p];
#	      cols[2*i-1] := cosTable[p-1];
#	    fi;
#	  od;
#	od;
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
                    AddSet( rels, CopyRel( rel ) );
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
#	  p:=2*Position(ggensi,GeneratorSyllable(grel,si));
#	  nneg:=ExponentSyllable(grel,si)>0;
#	  for ei in [1..AbsInt(ExponentSyllable(grel,si))] do
#	    i:=i+1;
#	    if nneg then
#	      nums[2*i]   := p-1;
#	      nums[2*i-1] := p;
#	      cols[2*i]   := cosTable[p-1];
#	      cols[2*i-1] := cosTable[p];
#	    else
#	      nums[2*i]   := p;
#	      nums[2*i-1] := p-1;
#	      cols[2*i]   := cosTable[p];
#	      cols[2*i-1] := cosTable[p-1];
#	    fi;
#	  od;
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
                AddSet( rels, CopyRel( rel ) );
            fi;
        fi;
      else
        # trivial generator
	AddSet(rels,[j]);
      fi;
    od;
    CompletionBar(InfoFpGroup,2,"Generator Loop:",false);

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
local cft, ct, w,l,c,i,j,g,e,ind;

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
#	Add(w,cft[ind][c]); #cofactor
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
local tt;
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
local t;
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
  if IsBound(aug.secondaryWords) then
    t.secondaryWords:=Immutable(aug.secondaryWords);
  fi;
  return t;
end);

#############################################################################
##
#E  sgpres.gi  . . . . . . . . . . . . . . . . . . . . . . . . . .. ends here

