#############################################################################
##
#W  grpfp.gi                    GAP library                    Volkmar Felsch
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareRepresentation( "IsPackedWordDefaultRep",
    IsPositionalObjectRep, [ 1 ] );


#############################################################################
##
#M  ElementOfFpGroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpGroup,
    "for a family of f.p. group elements, and an assoc. word",
    true,
    [ IsElementOfFpGroupFamily, IsAssocWordWithInverse ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  PrintObj( <elm> ) . . . . . . . for packed word in default representation
##
InstallMethod( PrintObj,
    "for an element of an f.p. group (default repres.)",
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
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( ExtRepOfObj,
    "for an element of an f.p. group (default repres.)",
    true,
    [ IsElementOfFpGroup and IsPackedWordDefaultRep ],
    0,
    obj -> ExtRepOfObj( obj![1] ) );


#############################################################################
##
#M  Inverse( <elm> )  . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( Inverse,
    "for an element of an f.p. group",
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
    "for a family of f.p. group elements",
    true,
    [ IsElementOfFpGroupFamily ],
    0,
    fam -> ElementOfFpGroup( fam, One( fam!.freeGroup ) ) );


#############################################################################
##
#M  One( <elm> )  . . . . . . . . . . . . . . . . . for element of f.p. group
##
InstallMethod( One,
    "for an f.p. group element",
    true,
    [ IsElementOfFpGroup ],
    0,
    obj -> One( FamilyObj( obj ) ) );


#############################################################################
##
#M  \*( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \*,
    "for two f.p. group elements",
    IsIdenticalObj,
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
InstallMethod( \=, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ], 0,
function( left, right )
local hom;
  hom:=IsomorphismPermGroup(FamilyObj(left));
  return Image(hom,left)=Image(hom,right);
end );

#############################################################################
##
#M  \<( <elm1>, <elm2> )  . . . . . . . . .  for two elements of a f.p. group
##
InstallMethod( \<, "for two f.p. group elements", IsIdenticalObj,
    [ IsElementOfFpGroup, IsElementOfFpGroup ],0,
# this is the only method that may ever be called!
function( left, right )
  return FpElmComparisonMethod(FamilyObj(left))(left,right);
end );

InstallMethod( FpElmComparisonMethod, "via perm rep.", true,
  [IsElementOfFpGroupFamily],0,
function( fam )
local hom;
  hom:=IsomorphismPermGroup(fam);
  return function(left,right);
	   return Image(hom,left)<Image(hom,right);
	 end;
end );


#############################################################################
##
#M  \in ( <elm>, <U> )  in subgroup of fp group
##
InstallMethod( \in,
  "subgroup of fp group",
  IsElmsColls,
  [ IsElementOfFpGroup,
    IsSubgroupFpGroup ],
  0,
function(elm,U)
local t,fg,i,p;
  t:=CosetTableInWholeGroup(U);
  elm:=UnderlyingElement(elm);
  # build up generator list corresponding to coset table
  fg:=[];
  for i in FreeGeneratorsOfFpGroup(U) do
    Add(fg,i);Add(fg,i^-1);
  od;
  p:=1;
  for i in [1..Length(elm)] do
    p:=t[Position(fg,Subword(elm,i,i))][p];
  od;
  return p=1;
end);


#############################################################################
##
#M  \=( <U>, <V> )  . . . . . . . . .  for two subgroups of a f.p. group
##
InstallMethod( \=,
    "subgroups of fp group",
    IsIdenticalObj,
    [ IsSubgroupFpGroup,
      IsSubgroupFpGroup ],
    0,
    function( left, right )
      return ForAll(GeneratorsOfGroup(left),i->i in right)
             and ForAll(GeneratorsOfGroup(right),i->i in left);
    end );


#############################################################################
##
#M  GeneratorsOfGroup( <F> )  . . . . . . . . . . . . . . .  for a f.p. group
##
InstallMethod( GeneratorsOfGroup,
    "for whole family f.p. group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,
    function( F )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( F ) );
    return List( FreeGeneratorsOfFpGroup( F ),
                 g -> ElementOfFpGroup( Fam, g ) );
    end );


#############################################################################
##
##  2. methods for f.p. groups
##

#############################################################################
##
#M  AbelianInvariants(<G>) . . . .  abelian invariants of an abelian fp group
##
InstallMethod( AbelianInvariants,
    "for abelian invariants of an abelian finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
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
    gens := FreeGeneratorsOfFpGroup( G );

    # handle groups with no relators
    if IsEmpty( RelatorsOfFpGroup( G ) ) then
        return [ 1 .. Length( gens ) ] * 0;
    fi;

    # make the relator matrix
    mat := [];
    for rel  in RelatorsOfFpGroup( G ) do
        row := [];
        for i  in [ 1 .. Length( gens ) ]  do
            row[i] := 0;
        od;
        for i  in [ 1 .. Length( rel ) ]  do
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
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   C,          # commutator factor group of <G>, result
            F,          # associated free group
            gens,       # generators of <F>
            grels,      # relators of <G>
            rels,       # relators of <C>
            g, h,       # two generators of <F>
            i, k;       # loop variables

    # get the arguments
    F     := FreeGroupOfFpGroup( G );
    gens  := GeneratorsOfGroup( F );
    grels := RelatorsOfFpGroup( G );

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
#M  CosetTable( <G>, <H> )  . . . . coset table of a finitely presented group
##
InstallMethod( CosetTable,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
    0,

function( G, H );

    if G <> FamilyObj( H )!.wholeGroup then
        Error( "<H> must be a subgroup of <G>" );
    fi;

    return CosetTableInWholeGroup( H );

end );


#############################################################################
##
#M  CosetTableFromGensAndRels( <fgens>, <grels>, <fsgens> ) . . . . . . . . .
#M                                                     do a coset enumeration
##
##  'CosetTableFromGensAndRels'  is the working horse  for computing  a coset
##  table of H in G where G is a finitley presented group, H is a subgroup of
##  G,  and  G  is the whole group of  H.  It applies a Felsch strategy Todd-
##  Coxeter coset enumeration. The expected parameters are
##
##    fgens  = generators of the free group F associated to G,
##    grels  = relators of G,
##    fsgens = preimages of the subgroup generators of H in F.
##
InstallGlobalFunction( CosetTableFromGensAndRels,
    function ( fgens, grels, fsgens )
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
        g := ListWithIdenticalEntries( limit, 0 );
        Add( table, g );
	g := ListWithIdenticalEntries( limit, 0 );
        Add( table, g );
    od;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fsgens  do
        length := Length( rel );
        length2 := 2 * length;
        nums := [ ]; nums[length2] := 0;
        cols := [ ]; cols[length2] := 0;

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
end );


#############################################################################
##
#M  CosetTableInWholeGroup( <H> )  . . . . . .  coset table of an fp subgroup
#M                                                         in its whole group
##
InstallMethod( CosetTableInWholeGroup,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup ],
    0,

function( H )
    local   G,          # whole group of <H>
            fgens,      # generators of the free group F asscociated to G
            grels,      # relators of G
            sgens,      # subgroup generators of H
            fsgens,     # preimages of subgroup generators in F
            T;          # coset table

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # get some variables
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    sgens := GeneratorsOfGroup( H );
    fsgens := List( sgens, gen -> UnderlyingElement( gen ) );

    # Construct the coset table of <G> by <H>.
    T := CosetTableFromGensAndRels( fgens, grels, fsgens );

    return T;

end );


#############################################################################
##
#M  Display( <G> ) . . . . . . . . . . . . . . . . . . .  display an fp group
##
InstallMethod( Display,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   gens,       # generators o the free group
            rels,       # relators of <G>
            nrels,      # number of relators
            i;          # loop variable

    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
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
    "for a finitely presented group with a subgroup",
    IsIdenticalObj,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsSubgroupFpGroup ],
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
    "for a finitely presented group with a list of elements",
    IsIdenticalObj,
    [ IsSubgroupFpGroup and IsGroupOfFamily, IsHomogeneousList ],
    0,

function( G, elts )
    local   F,          # free group associated to G and to G/N
            grels,      # relators of G
            words,      # representative words in F for the elements in elts
            rels,       # relators of G/N
            g;          # loop variable

    # get some local variables
    F     := FreeGroupOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    words := List( elts, g -> UnderlyingElement( g ) );

    # get relators for G/N
    rels := Concatenation( grels, words );

    # return the resulting factor group G/N
    return F / rels;
end );


#############################################################################
##
#M  FactorFreeGroupByRelators(<F>,<rels>) .  factor of free group by relators
##
FactorFreeGroupByRelators := function( F, rels )
    local G, fam, gens;

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

    # Mark <G> to be the 'whole group' of its later subgroups.
    FamilyObj( G )!.wholeGroup := G;
    SetFilterObj(G,IsGroupOfFamily);

    # Create generators of the group.
    gens:= List( GeneratorsOfGroup( F ), g -> ElementOfFpGroup( fam, g ) );
    SetGeneratorsOfGroup( G, gens );
    if IsEmpty( gens ) then
      SetOne( G, ElementOfFpGroup( fam, One( F ) ) );
    fi;

    return G;
end;


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . . . . for free group and list of relators
##
InstallOtherMethod( \/,
    "for free groups and relators",
    IsIdenticalObj,
    [ IsFreeGroup, IsCollection ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  \/( <F>, <rels> ) . . . . . . . for free group and empty list of relators
##
InstallOtherMethod( \/,
    "for a free group and an empty list of relators",
    true,
    [ IsFreeGroup, IsEmpty ],
    0,
    FactorFreeGroupByRelators );


#############################################################################
##
#M  FreeGeneratorsOfFpGroup( F )  . . generators of the underlying free group
##
InstallMethod( FreeGeneratorsOfFpGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> GeneratorsOfGroup( FreeGroupOfFpGroup( G ) ) );

#############################################################################
##
#M  FreeGroupOfFpGroup( F ) . . . . . .  underlying free group of an fp group
##
InstallMethod( FreeGroupOfFpGroup,
    "for a finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.freeGroup );

#############################################################################
##
#M  ImagesRepresentative( <hom>, <elm> )
##
InstallMethod( ImagesRepresentative,
  "map from fp group or free group, use 'MappedWord'",
  FamSourceEqFamElm, [ IsFromFpGroupStdGensGeneralMappingByImages,
          IsMultiplicativeElementWithInverse ], 0,
function( hom, elm )
  return MappedWord(elm,hom!.generators,hom!.genimages);
end);


#############################################################################
##
#M  Index( <G>,<H> )
##
InstallMethod( IndexOp,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup, IsSubgroupFpGroup ],
    0,
function(G,H)
  if not IsSubset(G,H) then
    Error("<H> must be a subset of <G>");
  fi;
  return IndexInWholeGroup(H)/IndexInWholeGroup(G);
end);


#############################################################################
##
#M  IndexInWholeGroup( <H> )  . . . . . .  index of a subgroup in an fp group
##
InstallMethod( IndexInWholeGroup,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup ],
    0,

function( H )
    local T;

    # Get the coset table of <H> in its whole group.
    T := CosetTableInWholeGroup( H );
    return Length( T[1] );

end );


#############################################################################
##
#M  Intersection2(<G>,<H>)  . intersection of two fin. pres. groups
##
InstallMethod(Intersection2,"subgroups of fp group",IsIdenticalObj,
  [IsSubgroupFpGroup,IsSubgroupFpGroup],0,
function ( G, H )
    local   I,          # intersection of <G> and <H>, result
    	    Fam,	# group family
            rels,       # representatives for the relators
            table,      # coset table for <I> in its parent
            nrcos,      # number of cosets of <I>
            tableG,     # coset table of <G>
            nrcosG,     # number of cosets of <G>
            tableH,     # coset table of <H>
            nrcosH,     # number of cosets of <H>
	    pargens,	# generators of Parent(G)
	    freegens,	# free generators of Parent(G)
            nrgens,     # number of generators of the parent of <G> and <H>
            ren,        # if 'ren[<i>]' is 'nrcosH * <iG> + <iH>' then the
                        # coset <i> of <I> corresponds to the intersection
                        # of the pair of cosets <iG> of <G> and <iH> of <H>
            ner,        # the inverse mapping of 'ren'
            cos,        # coset loop variable
            gen,        # generator loop variable
            img;        # image of <cos> under <gen>

    Fam:=FamilyObj(G);
    # handle trivial cases
    if IsIdenticalObj(G,Fam!.wholeGroup) then
        return H;
    elif IsIdenticalObj(H,Fam!.wholeGroup) then
        return G;
    fi;

    tableG := CosetTableInWholeGroup(G);
    nrcosG := Length( tableG[1] ) + 1;
    tableH := CosetTableInWholeGroup(H);
    nrcosH := Length( tableH[1] ) + 1;

    if nrcosG<nrcosH then
      if ForAll(GeneratorsOfGroup(H),i->i in G) then
        return G;
      fi;
    elif nrcosH<nrcosG then
      if ForAll(GeneratorsOfGroup(G),i->i in H) then
        return H;
      fi;
    fi;

    pargens:=GeneratorsOfGroup(Fam!.wholeGroup);
    freegens:=FreeGeneratorsOfFpGroup(G);
    # initialize the table for the intersection
    rels := RelatorRepresentatives( RelatorsOfFpGroup( G ) );
    nrgens := Length(freegens);
    table := [];
    for gen  in [ 1 .. nrgens ]  do
        table[ 2*gen-1 ] := [];
	table[ 2*gen ] := [];
    od;

    # set up the renumbering
    ren := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ner := ListWithIdenticalEntries(nrcosG*nrcosH,0);
    ren[ 1*nrcosH + 1 ] := 1;
    ner[ 1 ] := 1*nrcosH + 1;
    nrcos := 1;

    # the coset table for the intersection is the transitive component of 1
    # in the *tensored* permutation representation
    cos := 1;
    while cos <= nrcos  do

        # loop over all entries in this row
        for gen  in [ 1 .. nrgens ]  do

            # get the coset pair
            img := nrcosH * tableG[ 2*gen-1 ][ QuoInt( ner[ cos ], nrcosH ) ]
                          + tableH[ 2*gen-1 ][ ner[ cos ] mod nrcosH ];

            # if this pair is new give it the next available coset number
            if ren[ img ] = 0  then
                nrcos := nrcos + 1;
                ren[ img ] := nrcos;
                ner[ nrcos ] := img;
            fi;

            # and enter it into the coset table
            table[ 2*gen-1 ][ cos ] := ren[ img ];
            table[ 2*gen   ][ ren[ img ] ] := cos;

        od;

        cos := cos + 1;
    od;

    # now make the subgroup
    I:=SubgroupGeneratorsCosetTable(freegens,rels, table );
    I:=List(I,i->MappedWord(i,freegens,pargens));
    I:=Subgroup(Fam!.wholeGroup,I);
    SetCosetTableInWholeGroup(I,table);

    # and return it
    return I;
end);


#############################################################################
##
#M  IsAbelian( <G> )  . . . . . . . . . . . .  test if an fp group is abelian
##
InstallMethod( IsAbelian,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   isAbelian,  # result
            gens,       # generators of <G>
            fgens,      # generators of the associated free group
            rels,       # relators of <G>
            one,        # identity element of <G>
            g, h,       # two generators of <G>
            i, k;       # loop variables

    gens  := GeneratorsOfGroup( G );
    fgens := FreeGeneratorsOfFpGroup( G );
    rels  := RelatorsOfFpGroup( G );
    one   := One( G );
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
#M  IsSingleValued
##
InstallMethod( IsSingleValued,
  "map from fp group or free group, given on std. gens: test relators",
  true,
  [IsFromFpGroupStdGensGeneralMappingByImages],0,
function(hom)
local s,sg,o;
  s:=Source(hom);
  if IsFreeGroup(s) then
    return true;
  fi;
  sg:=FreeGeneratorsOfFpGroup(s);
  o:=One(Range(hom));
  return ForAll(RelatorsOfFpGroup(s),i->MappedWord(i,sg,hom!.genimages)=o);
end);


#############################################################################
##
#M  IsTrivial( <G> ) . . . . . . . . . . . . . . . . . test if <G> is trivial
##
InstallMethod( IsTrivial,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
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
               "for perm groups",
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
               "for permutation groups",
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
    gensH := SmallGeneratingSet( H );
    # if IsPrime( Size( H ) ) then
    #     gensH := Filtered( GeneratorsOfGroup( H ),
    #                        x -> Order(x)=Size(H) ){[1]};
    # else
    #     gensH := Set( GeneratorsOfGroup( H ) );
    #     gensH := Filtered( gensH, x -> x <> One(H) );
    # fi;
    iso := IsomorphismFpGroupByGenerators( H, gensH, str );
    F := FreeGroupOfFpGroup( Image( iso ) );
    gensF := GeneratorsOfGroup( F );
    imgsF := iso!.generators;
    relatorsF := RelatorsOfFpGroup( Image( iso ) );
    free := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
    n := Length( gensF );

    # loop over series upwards
    for k in Reversed( [1..l-2] ) do

        # get composition factor
        N := series[k];
        M := series[k+1];
        hom := NaturalHomomorphismByNormalSubgroupInParent( M );
        H := Image( hom );
        gensH := SmallGeneratingSet( H );
        # if IsPrime( Size( H ) ) then
        #     gensH := Filtered( GeneratorsOfGroup( H ),
        #                        x -> Order(x)=Size(H) ){[1]};
        # else
        #     gensH := Set( GeneratorsOfGroup( H ) );
        #     gensH := Filtered( gensH, x -> x <> One(H) );
        # fi;
        preiH := List( gensH, x -> PreImagesRepresentative( hom, x ) );
        c     := Length( gensH );

        # compute presentation of H
        new := IsomorphismFpGroupByGenerators( H, gensH, "g" );
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
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByCompositionSeries,
                    "for perm groups",
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
               "for perm groups",
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
        hom := GroupHomomorphismByImagesNC( G, F, gens, gensF );
        relators := CoKernelGensPermHom( hom );
        S := F / relators;
    fi;
    gensS := GeneratorsOfGroup( S );
    iso := GroupHomomorphismByImagesNC( G, S, gens, gensS );
    SetIsSurjective( iso, true );
    SetIsInjective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ));
    return iso;
end );

InstallOtherMethod( IsomorphismFpGroupByGenerators,
               "for perm groups",
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
               "for groups",
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
    free  := GroupHomomorphismByImagesNC( F, series[l-1], gensF, imgsF );
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
        new := IsomorphismFpGroupByGenerators( H, gensH, "g" );
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
        free :=  GroupHomomorphismByImagesNC( F, N, gensF, imgsF );
        n := n + c;
    od;

    # set up
    F     := F / relatorsF;
    gensF := GeneratorsOfGroup( F );
    iso   := GroupHomomorphismByImagesNC( G, F, imgsF, gensF );
    SetIsBijective( iso, true );
    SetKernelOfMultiplicativeGeneralMapping( iso, TrivialSubgroup( G ) );
    return iso;
end);

InstallOtherMethod( IsomorphismFpGroupBySubnormalSeries,
               "for groups",
               true,
               [IsPermGroup, IsList],
               0,
function( G, series )
    return IsomorphismFpGroupBySubnormalSeries( G, series, "F" );
end);


#############################################################################
##
#M  KernelOfMultiplicativeGeneralMapping( <hom> )
##
InstallMethod( KernelOfMultiplicativeGeneralMapping,
  "map from fp group or free group",
  true, [ IsFromFpGroupStdGensGeneralMappingByImages
	  and IsToPermGroupGeneralMappingByImages ],0,
function(hom)
local f,p,t,orbs,o,cor,i,j,k,u,e,frg;

  f:=Source(hom);
  frg:=FreeGeneratorsOfFpGroup(f);
  p:=Range(hom);
  # construct coset table
  t:=[];
  orbs:=Orbits(p,MovedPoints(p));
  cor:=f;

  for o in orbs do
    # form coset table
    for i in hom!.genimages do
      for j in [1,-1] do
	e:=i^j;
	Add(t,List(o,k->Position(o,k^e)));
      od;
    od;
    StandardizeTable(t);

    # get subgroup generators
    u:=SubgroupGeneratorsCosetTable(frg,
               ElementsFamily(RelatorsOfFpGroup(f)),t);

    # map them to f
    u:=List(u,i->MappedWord(i,frg,hom!.generators));

    u:=Subgroup(f,u);
    SetCosetTableInWholeGroup(u,t);
    cor:=Intersection(cor,u);
  od;
  cor:=Core(f,cor);
  return cor;
end);


#############################################################################
##
#M  LowIndexSubgroupsFpGroup(<G>,<H>,<index>[,<excluded>]) . . find subgroups
#M                               of small index in a finitely presented group
##
InstallGlobalFunction( LowIndexSubgroupsFpGroup, function ( arg )
    local   G,          # parent group
            ggens,      # generators of G
            fgens,      # generators of associated free group
            grels,      # relators of G
            hgens,      # generators of H
            fhgens,     # their preimages in the free group of G
            H,          # subgroup to be included in all resulting subgroups
            index,      # maximal index of subgroups to be determined
            excludeList, # representatives of element classes to be excluded
            exclude,    # true, if element classes to be excluded are given
            excludeGens, # table columns corresponding to gens to be excluded
            excludeWords, # words to be excluded, sorted by start generator
            subs,       # subgroups of <G>, result
            sub,        # one subgroup
            gens,       # generators of <sub>
            indexInWholeGroup, # index of <sub> in G
            tableInWholeGroup, # coset table of <sub> in G
            table,      # coset table
            nrgens,     # 2*(number of generators)+1
            nrcos,      # number of cosets in the coset table
            definition, # "definition"
            choice,     # "choice"
            deduction,  # "deduction"
            action,     # 'action[<i>]' is definition or choice or deduction
            actgen,     # 'actgen[<i>]' is the gen where this action was
            actcos,     # 'actcos[<i>]' is the coset where this action was
            nract,      # number of actions
            nrded,      # number of deductions already handled
            coinc,      # 'true' if a coincidence happened
            gen,        # current generator
            cos,        # current coset
            rels,       # representatives for the relators
            relsGen,    # relators sorted by start generator
            subgroup,   # rows for the subgroup gens
            nrsubgrp,   # number of subgroups
            app,        # arguments list for 'ApplyRel'
            later,      # 'later[<i>]' is <> 0 if <i> is smaller than 1
            nrfix,      # index of a subgroup in its normalizer
            pair,       # loop variable for subgroup generators as pairs
            rel,        # loop variable for relators
            triple,     # loop variable for relators as triples
            r, s,       # renumbering lists
            x, y,       # loop variables
            g, c, d,    # loop variables
            p, p1, p2,  # generator position numbers
            length,     # relator length
            length2,    # twice a relator length
            cols,
            nums,
            ngens,      # number of generators of G
            word,       # loop variable for words to be excluded
            numgen,
            numcos,
            i, j;       # loop variables

    # give some information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup called" );

    # check the arguments
    G := arg[1];
    H := arg[2];
    if not ( IsSubgroupFpGroup( G ) and IsGroupOfFamily( G ) ) then
        Error( "<G> must be a finitely presented group" );
    fi;
    if not IsSubgroupFpGroup( H ) or FamilyObj( H ) <> FamilyObj( G ) then
        Error( "<H> must be a subgroup of <G>" );
    fi;
    index := arg[3];

    # get some local variables
    ggens := GeneratorsOfGroup( G );
    fgens := FreeGeneratorsOfFpGroup( G );
    grels := RelatorsOfFpGroup( G );
    hgens := GeneratorsOfGroup( H );
    fhgens := List( hgens, gen -> UnderlyingElement( gen ) );

    # initialize the exclude lists, if elements to be excluded are given
    exclude := Length( arg ) > 3;
    if exclude then
        excludeList := arg[4];
    fi;

    # initialize the subgroup list
    subs := [];

    # handle the special case index = 1.
    if index = 1 then
        if not exclude or excludeList = [] then  subs := [ G ];  fi;
        return subs;
    fi;

    # initialize table
    rels := RelatorRepresentatives( grels );
    nrgens := 2 * Length( fgens ) + 1;
    nrcos := 1;
    table := [];
    for gen  in fgens  do
        g := ListWithIdenticalEntries( index, 0 );
        Add( table, g );
	g := ListWithIdenticalEntries( index, 0 );
        Add( table, g );
    od;

    # prepare the exclude lists
    if exclude then

        # mark the column numbers of the generators to be excluded
        ngens := Length( fgens );
        excludeGens := ListWithIdenticalEntries( 2 * ngens, 0 );
        for i in [ 1 .. ngens ] do
            gen := fgens[i];
            if gen in excludeList or gen^-1 in excludeList then
                excludeGens[2*i-1] := 1;
                excludeGens[2*i] := 1;
            fi;
        od;

        # make the rows for the words of length > 1 to be excluded
        excludeWords := [];
        for word in excludeList do
            if Length( word ) > 1 then
                Add( excludeWords, word );
            fi;
        od;
        excludeWords := RelsSortedByStartGen( fgens, excludeWords, table );
    fi;

    # make the rows for the relators and distribute over relsGen
    relsGen := RelsSortedByStartGen( fgens, rels, table );

    # make the rows for the subgroup generators
    subgroup := [];
    for rel  in fhgens  do
        length := Length( rel );
        length2 := 2 * length;
        nums := [ ]; nums[length2] := 0;
        cols := [ ]; cols[length2] := 0;

        # compute the lists.
        i := 0;  j := 0;
        while i < length do
            i := i + 1;  j := j + 2;
            gen := Subword( rel, i, i );
            p := Position( fgens, gen );
            if p = false then
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
    nrsubgrp := Length( subgroup );

    # make an structure that is passed to 'ApplyRel'
    app := ListWithIdenticalEntries( 4, 0 );

    # set up the action stack
    definition := 1;
    choice := 2;
    deduction := 3;
    nract := 1;
    action := [ choice ];
    gen := 1;
    actgen := [ gen ];
    cos := 1;
    actcos := [ cos ];

    # set up the lexicographical information list
    later := ListWithIdenticalEntries( index, 0 );

    # initialize the renumbering lists
    r := [ ]; r[index] := 0;
    s := [ ]; s[index] := 0;

    # do an exhaustive backtrack search
    while 1 < nract  or table[1][1] < 2  do

        # find the next choice that does not already appear in this col.
        c := table[ gen ][ cos ];
        repeat
            c := c + 1;
        until index < c  or table[ gen+1 ][ c ] = 0;

        # if there is a further choice try it
        if action[nract] <> definition  and c <= index  then

            # remove the last choice from the table
            d := table[ gen ][ cos ];
            if d <> 0  then
                table[ gen+1 ][ d ] := 0;
            fi;

            # enter it in the table
            table[ gen ][ cos ] := c;
            table[ gen+1 ][ c ] := cos;

            # and put information on the action stack
            if c = nrcos + 1  then
                nrcos := nrcos + 1;
                action[ nract ] := definition;
            else
                action[ nract ] := choice;
            fi;

            # run through the deduction queue until it is empty
            nrded := nract;
            coinc := false;
            while nrded <= nract and not coinc  do

                # check given exclude elements to be excluded
                if exclude then
                    numgen := actgen[nrded];
                    numcos := actcos[nrded];
                    if excludeGens[numgen] = 1 and
                        numcos = table[numgen][numcos] then
                        coinc := true;
                    else
                        length := Length( excludeWords[actgen[nrded]] );
                        i := 1;
                        while i <= length and not coinc do
                            triple := excludeWords[actgen[nrded]][i];
                            app[1] := triple[3];
                            app[2] := actcos[ nrded ];
                            app[3] := -1;
                            app[4] := app[2];
                            if not ApplyRel( app, triple[2] ) and
                                app[1] = app[3] + 1 then
                                coinc := true;
                            fi;
                            i := i + 1;
                        od;
                    fi;
                fi;

                # if there are still subgroup generators apply them
                i := 1;
                while i <= nrsubgrp and not coinc do
                    pair := subgroup[i];
                    app[1] := 2;
                    app[2] := 1;
                    app[3] := Length(pair[2])-1;
                    app[4] := 1;
                    if ApplyRel( app, pair[2] )  then
                        if   pair[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif pair[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            pair[2][app[1]][app[2]] := app[4];
                            pair[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := pair[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                # apply all relators that start with this generator
                length := Length( relsGen[actgen[nrded]] );
                i := 1;
                while i <= length and not coinc do
                    triple := relsGen[actgen[nrded]][i];
                    app[1] := triple[3];
                    app[2] := actcos[ nrded ];
                    app[3] := -1;
                    app[4] := app[2];
                    if ApplyRel( app, triple[2] )  then
                        if   triple[2][app[1]][app[2]] <> 0  then
                            coinc := true;
                        elif triple[2][app[3]][app[4]] <> 0  then
                            coinc := true;
                        else
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nract := nract + 1;
                            action[ nract ] := deduction;
                            actgen[ nract ] := triple[1][app[1]];
                            actcos[ nract ] := app[2];
                        fi;
                    fi;
                    i := i + 1;
                od;

                nrded := nrded + 1;
            od;

            # unless there was a coincidence check lexicography
            if not coinc then
              nrfix := 1;
              x := 1;
              while x < nrcos and not coinc do
                x := x + 1;

                # set up the renumbering
                for i in [1..nrcos] do
                    r[i] := 0;
                    s[i] := 0;
                od;
                r[x] := 1;  s[1] := x;

                # run through the old and the new table in parallel
                c := 1;  y := 1;
                while c <= nrcos  and not coinc  and later[x] = 0  do

                    # get the corresponding coset for the new table
                    d := s[c];

                    # loop over the entries in this row
                    g := 1;
                    while   g < nrgens
                        and c <= nrcos  and not coinc  and later[x] = 0  do

                        # if either entry is missing we cannot decide yet
                        if table[g][c] = 0  or table[g][d] = 0  then
                            c := nrcos + 1;

                        # if old and new both contain a definition
                        elif r[ table[g][d] ] = 0 and table[g][c] = y+1  then
                            y := y + 1;
                            r[ table[g][d] ] := y;
                            s[ y ] := table[g][d];

                        # if only new is a definition
                        elif r[ table[g][d] ] = 0  then
                            later[x] := nract;

                        # if new is the smaller one we have a coincidence
                        elif r[ table[g][d] ] < table[g][c]  then

                            # check that <x> fixes <H>
                            coinc := true;
                            for pair in subgroup  do
                                app[1] := 2;
                                app[2] := x;
                                app[3] := Length(pair[2])-1;
                                app[4] := x;
                                if ApplyRel( app, pair[2] )  then

                                    # coincidence: <x> does not fix <H>
                                    if   pair[2][app[1]][app[2]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;
                                    elif pair[2][app[3]][app[4]] <> 0  then
                                        later[x] := nract;
                                        coinc := false;

                                    # non-closure (ded): <x> may not fix <H>
                                    else
                                        coinc := false;
                                    fi;

                                # non-closure (not ded): <x> may not fix <H>
                                elif app[1] <= app[3]  then
                                    coinc := false;
                                fi;

                            od;

                        # if old is the smaller one very good
                        elif table[g][c] < r[ table[g][d] ]  then
                            later[x] := nract;

                        fi;

                        g := g + 2;
                    od;

                    c := c + 1;
                od;

                if c = nrcos + 1  then
                    nrfix := nrfix + 1;
                fi;

              od;
            fi;

            # if there was no coincidence
            if not coinc  then

                # look for another empty place
                c := cos;
                g := gen;
                while c <= nrcos  and table[ g ][ c ] <> 0  do
                    g := g + 2;
                    if g = nrgens  then
                        c := c + 1;
                        g := 1;
                    fi;
                od;

                # if there is an empty place, make this a new choice point
                if c <= nrcos  then

                    nract := nract + 1;
                    action[ nract ] := choice; # necessary?
                    gen := g;
                    actgen[ nract ] := gen;
                    cos := c;
                    actcos[ nract ] := cos;
                    table[ gen ][ cos ] := 0; # necessary?

                # otherwise we found a subgroup
                else

                    # give some information
                    Info( InfoFpGroup, 2,  " class ", Length(subs)+1,
                                  " of index ", nrcos,
                                  " and length ", nrcos / nrfix );

                    # find a generating system for the subgroup
                    gens := ShallowCopy( hgens );
                    for i  in [ 1 .. nract ]  do
                        if action[ i ] = choice  then
                            x := One( ggens[1] );
                            c := actcos[i];
                            while c <> 1  do
                                g := nrgens - 1;
                                y := nrgens - 1;
                                while 0 < g  do
                                    if table[g][c] <= table[y][c]  then
                                        y := g;
                                    fi;
                                    g := g - 2;
                                od;
                                x := ggens[ y/2 ] * x;
                                c := table[y][c];
                            od;
                            x := x * ggens[ (actgen[i]+1)/2 ];
                            c := table[ actgen[i] ][ actcos[i] ];
                            while c <> 1  do
                                g := nrgens - 1;
                                y := nrgens - 1;
                                while 0 < g  do
                                    if table[g][c] <= table[y][c]  then
                                        y := g;
                                    fi;
                                    g := g - 2;
                                od;
                                x := x * ggens[ y/2 ]^-1;
                                c := table[y][c];
                            od;
                            Add( gens, x );
                        fi;
                    od;

                    # add the coset table
                    sub := Subgroup( G, gens );
                    tableInWholeGroup := [];
                    for g  in [ 1 .. Length( fgens ) ]  do
                        tableInWholeGroup[2*g-1]
                                := table[2*g-1]{ [1..nrcos] };
			tableInWholeGroup[2*g]
			    := table[2*g]{ [1..nrcos] };
                    od;
                    SetCosetTableInWholeGroup( sub, tableInWholeGroup );
		    indexInWholeGroup := Length( tableInWholeGroup[1] );
		    SetIndexInWholeGroup( sub, indexInWholeGroup );
		    if HasSize( G ) then
		      SetSize( sub, Size( G ) / indexInWholeGroup );
		    fi;

                    # add this subgroup to the list of subgroups
                    #N  05-Feb-92 martin should be 'ConjugacyClassSubgroup'
                    Add( subs, sub );

                    # undo all deductions since the previous choice point
                    while action[ nract ] = deduction  do
                        g := actgen[ nract ];
                        c := actcos[ nract ];
                        d := table[ g ][ c ];
                        if g mod 2 = 1  then
                            table[ g   ][ c ] := 0;
                            table[ g+1 ][ d ] := 0;
                        else
                            table[ g   ][ c ] := 0;
                            table[ g-1 ][ d ] := 0;
                        fi;
                        nract := nract - 1;
                    od;
                    for x  in [2..index]  do
                        if nract <= later[x]  then
                            later[x] := 0;
                        fi;
                    od;

                fi;

            # if there was a coincendence go back to the current choice point
            else

                # undo all deductions since the previous choice point
                while action[ nract ] = deduction  do
                    g := actgen[ nract ];
                    c := actcos[ nract ];
                    d := table[ g ][ c ];
                    if g mod 2 = 1  then
                        table[ g   ][ c ] := 0;
                        table[ g+1 ][ d ] := 0;
                    else
                        table[ g   ][ c ] := 0;
                        table[ g-1 ][ d ] := 0;
                    fi;
                    nract := nract - 1;
                od;
                for x  in [2..index]  do
                    if nract <= later[x]  then
                        later[x] := 0;
                    fi;
                od;

            fi;

        # go back to the previous choice point if there are no more choices
        else

            # undo the choice point
            if action[ nract ] = definition  then
                nrcos := nrcos - 1;
            fi;
            g := actgen[ nract ];
            c := actcos[ nract ];
            d := table[ g ][ c ];
            if g mod 2 = 1  then
                table[ g   ][ c ] := 0;
                table[ g+1 ][ d ] := 0;
            else
                table[ g   ][ c ] := 0;
                table[ g-1 ][ d ] := 0;
            fi;
            nract := nract - 1;

            # undo all deductions since the previous choice point
            while action[ nract ] = deduction  do
                g := actgen[ nract ];
                c := actcos[ nract ];
                d := table[ g ][ c ];
                if g mod 2 = 1  then
                    table[ g   ][ c ] := 0;
                    table[ g+1 ][ d ] := 0;
                else
                    table[ g   ][ c ] := 0;
                    table[ g-1 ][ d ] := 0;
                fi;
                nract := nract - 1;
            od;
            for x  in [2..index]  do
                if nract <= later[x]  then
                    later[x] := 0;
                fi;
            od;

            cos := actcos[ nract ];
            gen := actgen[ nract ];

        fi;

    od;

    # give some final information
    Info( InfoFpGroup, 1, "LowIndexSubgroupsFpGroup returns ",
                 Length(subs), " classes" );

    # return the subgroups
    return subs;
end );


#############################################################################
##
#M  MappedWord( <x>, <gens1>, <gens2> )
##
InstallOtherMethod( MappedWord, true,
    [ IsElementOfFpGroup, IsList, IsList ], 0,
    MappedWordForAssocWord );


#############################################################################
##
#F  MostFrequentGeneratorFpGroup( <G> ) . . . . . . . most frequent generator
##
##  'MostFrequentGeneratorFpGroup'  returns the  first of those generators of
##  the given finitely  presented group  which occurs most frequently  in the
##  relators.
##
InstallGlobalFunction( MostFrequentGeneratorFpGroup, function ( G )

    local altered, gens, gens2, i, i1, i2, k, max, j, num, numgens,
          numrels, occur, power, rel, relj, rels, set;

#@@ # check the first argument to be a finitely presented group.
#@@ if not ( IsRecord( G ) and IsBound( G.isFpGroup ) and G.isFpGroup ) then
#@@     Error( "argument must be a finitely presented group" );
#@@ fi;

    # Get some local variables.
    gens := FreeGeneratorsOfFpGroup( G );
    rels := RelatorsOfFpGroup( G );
    numgens := Length( gens );
    numrels := Length( rels );

    # Initialize a counter.
    occur := ListWithIdenticalEntries( numgens, 0 );
    power := ListWithIdenticalEntries( numgens, 0 );

    # initialize a list of the generators and their inverses
    gens2 := [ ]; gens2[numgens] := 0;
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
        i2 := Length( relj );
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
end );


#############################################################################
##
#M  PreImagesRepresentative
##
InstallMethod( PreImagesRepresentative,
  "hom. to standard generators of fp group, using 'MappedWord'",
  FamRangeEqFamElm,
  [IsToFpGroupHomomorphismByImages,IsMultiplicativeElementWithInverse],0,
function(hom,elm)
  if not IsIdenticalObj(hom!.genimages,GeneratorsOfGroup(Range(hom))) then
    # check, whether we map to the standard generators
    TryNextMethod();
  fi;
  return MappedWord(elm,hom!.genimages,hom!.generators);
end);


#############################################################################
##
#F  RelatorRepresentatives(<rels>) . set of representatives of a list of rels
##
##  'RelatorRepresentatives' returns a set of  relators,  that  contains  for
##  each relator in the list <rels> its minimal cyclical  permutation  (which
##  is automatically cyclically reduced).
##
InstallGlobalFunction( RelatorRepresentatives, function ( rels )
    local   cyc, fam, i, j, length, list, min, rel, reversed, reps;

    reps := [ ];

    # loop over all nontrivial relators
    for rel in rels  do
        length := Length( rel );
        if length > 0  then

            # invert the exponents to their negative values in order to get
            # an appropriate lexicographical ordering of the relators.
            fam := FamilyObj( rel );
            list := ExtRepOfObj( rel );
            for i in [ 2, 4 .. Length( list ) ] do
                list[i] := -list[i];
            od;

            # find the minimal cyclic permutation
            reversed := ObjByExtRep( fam, list );
            cyc := reversed;
            min := cyc;
            if cyc^-1 < min  then min := cyc^-1;  fi;
            for i  in [ 1 .. length - 1 ]  do
                cyc := cyc ^ Subword( reversed, i, i );
                if cyc    < min  then min := cyc;     fi;
                if cyc^-1 < min  then min := cyc^-1;  fi;
            od;

            # if the relator is new, add it to the representatives
            if not min in reps  then
                AddSet( reps, [ Length( min ), min ] );
            fi;

        fi;
    od;

    # reinvert the exponents.
    for i in [ 1 .. Length( reps ) ]  do
        rel := reps[i][2];
        fam := FamilyObj( rel );
        list := ExtRepOfObj( rel );
        for j in [ 2, 4 .. Length( list ) ] do
            list[j] := -list[j];
        od;
        reps[i] := ObjByExtRep( fam, list );
    od;

    # return the representatives
    return reps;
end );


#############################################################################
##
#M  RelatorsOfFpGroup( F )
##
InstallMethod( RelatorsOfFpGroup,
    "for finitely presented group",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
    G -> ElementsFamily( FamilyObj( G ) )!.relators );


#############################################################################
##
#M  IndicesInvolutaryGenerators( F )
##
InstallMethod( IndicesInvolutaryGenerators, "for finitely presented group",
  true, [ IsSubgroupFpGroup and IsGroupOfFamily ], 0,
function(G)
local g,r;
  g:=FreeGeneratorsOfFpGroup(G);
  r:=RelatorsOfFpGroup(G);
  r:=Filtered(r,i->NumberSyllables(i)=1);
  return Filtered([1..Length(g)],i->g[i]^2 in r or g[i]^-2 in r);
end);

#############################################################################
##
#F  RelsSortedByStartGen( <gens>, <rels>, <table> )
#F                                         relators sorted by start generator
##
##  'RelsSortedByStartGen'  is a  subroutine of the  Felsch Todd-Coxeter  and
##  the  Reduced Reidemeister-Schreier  routines. It returns a list which for
##  each  generator or  inverse generator  contains a list  of all cyclically
##  reduced relators,  starting  with that element,  which can be obtained by
##  conjugating or inverting given relators.  The relators are represented as
##  lists of the coset table columns corresponding to the generators and,  in
##  addition, as lists of the respective column numbers.
##
InstallGlobalFunction( RelsSortedByStartGen, function ( arg )
    local   gens,                       # group generators
            rels,                       # relators
            table,                      # coset table
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

    # check that the table has the right number of columns
    if 2 * Length(gens) <> Length(table) then
        Error( "table length is inconsistent with number of generators" );
    fi;

    # initialize the list to be constructed
    relsGen := [ ]; relsGen[2*Length(gens)] := 0;
    for i  in [ 1 .. Length(gens) ]  do
        relsGen[ 2*i-1 ] := [];
	relsGen[ 2*i ] := [];
    od;

    # now loop over all parent group relators
    for rel  in rels  do

        # get the length and the basic length of relator rel
        length := Length( rel );
        base := 1;
        cyc := rel ^ Subword( rel, base, base );
        while cyc <> rel do
            base := base + 1;
            cyc := cyc ^ Subword( rel, base, base );
        od;

	# initialize the columns and numbers lists corresponding to the
	# current relator
	base2 := 2 * base;
	extleng := 2 * ( base + length ) - 1;
	nums    := [ ]; nums[extleng]    := 0;
	cols    := [ ]; cols[extleng]    := 0;
	invnums := [ ]; invnums[extleng] := 0;
	invcols := [ ]; invcols[extleng] := 0;

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
    od;

    # return the list
    return relsGen;
end );


#############################################################################
##
#M  Size( <G> )  . . . . . . . . . . . . . size of a finitely presented group
##
InstallMethod( Size,
    "for finitely presented groups",
    true,
    [ IsSubgroupFpGroup and IsGroupOfFamily ],
    0,

function( G )
    local   fgens,      # generators of the free group
            rels,       # relators of <G>
            H,          # subgroup of <G>
            T;          # coset table of <G> by <H>

        fgens := FreeGeneratorsOfFpGroup( G );
        rels  := RelatorsOfFpGroup( G );

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
#M  Size( <H> )  . . . . . . size of s subgroup of a finitely presented group
##
InstallMethod( Size,
    "for subgroups of finitely presented groups",
    true,
    [ IsSubgroupFpGroup ],
    0,

function( H )
    local G;

    # Get whole group <G> of <H>.
    G := FamilyObj( H )!.wholeGroup;

    # Compute the size of <G> and the index of <H> in <G>.
    return Size( G ) / IndexInWholeGroup( H );

end );


#############################################################################
##
#M  IsomorphismPermGroup(<G>)
##
InstallMethod(IsomorphismPermGroup,"for full finitely presented groups",
    true, [ IsSubgroupFpGroup and IsGroupOfFamily ],
    # as this method may be called to compare elements we must get higher
    # than a method for finite groups (via right multiplication).
    SIZE_FLAGS(FLAGS_FILTER(IsFinite)),
function(G)
local t,p,H,gens;

  # handle free and trivial group
  if 0 = Length( FreeGeneratorsOfFpGroup( G )) then
    return GroupHomomorphismByImagesNC(G,Group(),[],[]);
  fi;

  # try action on cosets of cyclic subgroups
  gens:=GeneratorsOfGroup(G);
  # get most frequent first
  t:=MostFrequentGeneratorFpGroup(G);
  gens:=Concatenation([t],Filtered(gens,i->not IsIdenticalObj(i,t)));

  repeat
    t:=AugmentedCosetTableMtc(G,Subgroup(G,[MostFrequentGeneratorFpGroup(G)]),
			      1, "@" );
    if t.exponent=infinity then
      Error("<G> must be finite");
    fi;

    p:=List(t.cosetTable{[1,3..Length(t.cosetTable)-1]},PermList);

    H:=Group(p);
    # compute stabilizer chain with size info.
    StabChain(H,rec(limit:=t.exponent*Length(t.cosetTable)));

    gens:=gens{[2..Length(gens)]};
  until Size(H)=t.exponent*Length(t.cosetTable) or Length(gens)=0;

  if Size(H)<t.exponent*Length(t.cosetTable) then
    # we will need the regular action
    t:=CosetTableFromGensAndRels(FreeGeneratorsOfFpGroup(G),
				RelatorsOfFpGroup(G),[]);
    p:=List(t{[1,3..Length(t)-1]},PermList);
    H:=Group(p);
    SetSize(H,Length(t[1]));
  fi;

  p:=SmallerDegreePermutationRepresentation(H);
  return GroupHomomorphismByImagesNC(G,Image(p),GeneratorsOfGroup(G),
			List(GeneratorsOfGroup(H),i->Image(p,i)));
end);

InstallOtherMethod(IsomorphismPermGroup,"for family of fp words",true,
  [IsElementOfFpGroupFamily],0,
function(fam)
  # use the full group
  return IsomorphismPermGroup(CollectionsFamily(fam)!.wholeGroup);
end);

#############################################################################
##
#M  FactorCosetOperation(<G>)
##
InstallMethod(FactorCosetOperation,"for full fp group on subgroup cosets",
  IsIdenticalObj,[IsSubgroupFpGroup and IsGroupOfFamily,IsSubgroupFpGroup],0,
function(G,U)
local t;
  t:=CosetTableFromGensAndRels(FreeGeneratorsOfFpGroup(G),
                               RelatorsOfFpGroup(G),
			       List(GeneratorsOfGroup(U),UnderlyingElement));
  t:=List(t{[1,3..Length(t)-1]},PermList);
  return GroupHomomorphismByImagesNC(G,Group(t),GeneratorsOfGroup(G),t);
end);


#############################################################################
##
#F  SubgroupGeneratorsCosetTable(<freegens>,<fprels>,<table>)
##     determines subgroup generators from free generators, relators and
##     coset table. It returns elements of the free group!
##
InstallGlobalFunction( SubgroupGeneratorsCosetTable,
    function ( freegens, fprels, table )
    local   gens,               # generators for the subgroup
            rels,               # representatives for the relators
            relsGen,            # relators sorted by start generator
            deductions,         # deduction queue
            ded,                # index of current deduction in above
            nrdeds,             # current number of deductions in above
            nrgens,
            cos,                # loop variable for coset
            i, gen, inv,        # loop variables for generator
            g,                  # loop variable for generator col
            rel,                # loop variable for relation
            p, p1, p2,          # generator position numbers
            triple,             # loop variable for relators as triples
            app,                # arguments list for 'ApplyRel'
            x, y, c;

    nrgens := 2 * Length( freegens ) + 1;
    gens := [];

    # make all entries in the table negative
    for cos  in [ 1 .. Length( table[1] ) ]  do
        for gen  in table  do
            if 0 < gen[cos]  then
                gen[cos] := -gen[cos];
            fi;
        od;
    od;

    # make the rows for the relators and distribute over relsGen
    rels := RelatorRepresentatives( fprels );
    relsGen := RelsSortedByStartGen( freegens, rels, table );

    # make the structure that is passed to 'ApplyRel'
    app := ListWithIdenticalEntries(4,0);

    # run over all the cosets
    cos := 1;
    while cos <= Length( table[1] )  do

        # run through all the rows and look for undefined entries
        for i  in [1..Length(freegens)]  do
            gen := table[2*i-1];

            if gen[cos] < 0  then

                inv := table[2*i];

                # make the Schreier generator for this entry
                x := One(freegens[1]);
                c := cos;
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := freegens[ y/2 ] * x;
                    c := AbsInt(table[y][c]);
                od;
                x := x * freegens[ i ];
                c := AbsInt( gen[ cos ] );
                while c <> 1  do
                    g := nrgens - 1;
                    y := nrgens - 1;
                    while 0 < g  do
                        if AbsInt(table[g][c]) <= AbsInt(table[y][c])  then
                            y := g;
                        fi;
                        g := g - 2;
                    od;
                    x := x * freegens[ y/2 ]^-1;
                    c := AbsInt(table[y][c]);
                od;
                if x <> One(x)  then
                    Add( gens, x );
                fi;

                # define a new coset
                gen[cos]   := - gen[cos];
                inv[ gen[cos] ] := cos;

                # set up the deduction queue and run over it until it's empty
                deductions := [ [i,cos] ];
                nrdeds := 1;
                ded := 1;
                while ded <= nrdeds  do

                    # apply all relators that start with this generator
                    for triple in relsGen[deductions[ded][1]] do
                        app[1] := triple[3];
                        app[2] := deductions[ded][2];
                        app[3] := -1;
                        app[4] := app[2];
                        if ApplyRel( app, triple[2] ) then
                            triple[2][app[1]][app[2]] := app[4];
                            triple[2][app[3]][app[4]] := app[2];
                            nrdeds := nrdeds + 1;
                            deductions[nrdeds] := [triple[1][app[1]],app[2]];
                        fi;
                    od;

                    ded := ded + 1;
                od;

            fi;
        od;

        cos := cos + 1;
    od;

    # return the generators
    return gens;
end );


#############################################################################
##
#M  ViewObj(<G>)
##
InstallMethod(ViewObj,"fp group",true,[IsSubgroupFpGroup],
 10,# to override the pure `Size' method
function(G)
  if IsFreeGroup(G) then TryNextMethod();fi;
  if IsGroupOfFamily(G) then
    Print("<fp group");
    if HasSize(G) then
      Print(" of size ",Size(G));
    fi;
    if Length(GeneratorsOfGroup(G))>VIEWLEN*10 then
      Print(" with ",Length(GeneratorsOfGroup(G))," generators>");
    else
      Print(" on the generators ",GeneratorsOfGroup(G),">");
    fi;
  else
    Print("Group(");
    if HasGeneratorsOfGroup(G) then
      if not IsBound(G!.gensWordLengthSum) then
	G!.gensWordLengthSum:=Sum(List(GeneratorsOfGroup(G),
	         i->Length(UnderlyingElement(i))));
      fi;
      if G!.gensWordLengthSum<=VIEWLEN*30 then
        Print(GeneratorsOfGroup(G));
      else
        Print("<",Length(GeneratorsOfGroup(G))," generators>");
      fi;
    else
      Print("<fp, no generators known>");
    fi;
    Print(")");
  fi;
end);


#############################################################################
##
#E  grpfp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

