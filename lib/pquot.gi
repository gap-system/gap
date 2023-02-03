#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Werner Nickel.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##

CHECK := false;
BindGlobal( "NumberOfCommutators", function( ranks )
    local   class,  hclass,  coranks,  ngens,  cl,  nofc;

    class := Length(ranks);
    hclass := Int( (class)/2 );

    ##  corank[cl] is the number of generators g of weight at least cl+1 such
    ##  that wt(g) + cl <= class.
    coranks := [];
    ngens := Sum( ranks );
    for cl in [1..hclass] do
        ngens := ngens - ranks[cl] - ranks[ class - cl + 1];
        coranks[ cl ] := ngens;
    od;

    nofc := 0;
    for cl in [1..hclass] do
        nofc := nofc + ranks[cl] * coranks[cl]
                     + (ranks[cl] * (ranks[cl]-1))/2;
    od;
    return nofc;
end );

#############################################################################
##
#F  PQStatistics  . . . . . . . . . . . . . . . . . . . p-quotient statistics
##
PQStatistics := rec(
                    TailCountBNA := 0,
                    TailCountBAN := 0,
                    TailCountCBA := 0,
                    ConsCountANA := 0,
                    ConsCountBNA := 0,
                    ConsCountBAN := 0,
                    ConsCountCBA := 0 );

MakeThreadLocal( "PQStatistics" );

BindGlobal( "IncreaseCounter", function( string )

    PQStatistics.(string) := PQStatistics.(string) + 1;
end );

BindGlobal( "PrintCounters", function()

    Print( "Number of consistency checks:\n" );
    Print( "a^p a   : ", PQStatistics.ConsCountANA, "\n" );
    Print( "b a^p   : ", PQStatistics.ConsCountBAN, "\n" );
    Print( "b^p a   : ", PQStatistics.ConsCountBNA, "\n" );
    Print( "c (b a) : ", PQStatistics.ConsCountCBA, "\n" );

    Print( "Number of tail computations:\n" );
    Print( "b a^p   : ", PQStatistics.TailCountBAN, "\n" );
    Print( "b^p a   : ", PQStatistics.TailCountBNA, "\n" );
    Print( "c (b a) : ", PQStatistics.TailCountCBA, "\n" );
end );

BindGlobal( "ClearPQuotientStatistics", function()

    PQStatistics.TailCountBNA := 0;
    PQStatistics.TailCountBAN := 0;
    PQStatistics.TailCountCBA := 0;
    PQStatistics.ConsCountANA := 0;
    PQStatistics.ConsCountBNA := 0;
    PQStatistics.ConsCountBAN := 0;
    PQStatistics.ConsCountCBA := 0;

end );

#############################################################################
##
##  The  following  functions work  with a lower trianguar matrix (LTM).  A
##  LTM may have the following shape where . (*) denotes a (non-) zero entry:
##
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      * * * * * * . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      * * * * * * * * . . . . . .
##                      * * * * * * * * * . . . . .
##                      . . . . . . . . . . . . . .
##                      * * * * * * * * * * * . . .
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##                      . . . . . . . . . . . . . .
##
##  Rows of zeroes are not stored in a LTM.  A  LTM has a  list of indices at
##  which non-zero rows are stored.  Other information stored in a LTM is the
##  zero and one of its coefficient domain, the number of  columns and a zero
##  vector of the correct length.
##

#############################################################################
##
#F  TrailingEntriesLTM  . . . . . . . . . .  return list of trailing of a LTM
##
##
BindGlobal( "TrailingEntriesLTM", function( LTM )

    return LTM.bound;
end );

#############################################################################
##
#F  ReducedVectorLTM  . . . . . . . . . . . . . a vector reduced modulo a LTM
##
BindGlobal( "ReducedVectorLTM", function( LTM, v )
    local   zero,  M,  i;

    if Length(v) <> LTM.dimension then
        Error( "vector has incompatible length" );
    fi;

    zero := LTM.zero;
    M    := LTM.matrix;

    for i in LTM.bound do
        if v[i] <> zero then
            v := v - v[i] * M[i];
        fi;
    od;

    return v;
end );

#############################################################################
##
#F  AddVectorLTM  . . . . . . . . . . . . . . . . . . . add a vector to a LTM
##
BindGlobal( "AddVectorLTM", function( LTM, v )
    local   M,  zero,  i,  trailingEntry;

    if Length(v) <> LTM.dimension then
        Error( "vector has incompatible length" );
    fi;

    M    := LTM.matrix;
    zero := LTM.zero;

    v := v + zero;

    if v = LTM.nullvector then return; fi;

    ##  Reduce vector modulo the matrix
    for i in LTM.bound do
        if v[i] <> zero then
            v := v - v[i] * M[i];
        fi;
    od;

    ##  Check if the vector is zero and, if not, normalize it, add it to the
    ##  lower triangular matrix.
    if v <> LTM.nullvector then
        for trailingEntry in Reversed([1..LTM.dimension]) do
            if v[ trailingEntry ] <> zero then
                break;
            fi;
        od;
        if v[ trailingEntry ] <> LTM.one then
            v := v / v[ trailingEntry ];
        fi;

        LTM.matrix[ trailingEntry ] := v;

        i := PositionSorted( LTM.bound, trailingEntry,
                     function( a,b ) return a > b; end );
        Add( LTM.bound, trailingEntry, i );
    fi;

end );

#############################################################################
##
#F  RowEchelonFormLTM . . . .  row echelon form of a lower triangular matrix
##
BindGlobal( "RowEchelonFormLTM", function( LTM )
    local   i,  j;

    for i in LTM.bound do
        for j in [i+1..LTM.dimension] do
            if IsBound(LTM.matrix[j]) then
                LTM.matrix[j] := LTM.matrix[j]
                                 - LTM.matrix[j][i] * LTM.matrix[i];
            fi;
        od;
    od;
end );

#############################################################################
##
#F  LowerTriangularMatrix . . . . . . .  initialize a lower triangular matrix
##
BindGlobal( "LowerTriangularMatrix", function( dim, field )
    local   LTM;

    LTM := rec( dimension  := dim,
                zero       := Zero( field ),
                one        := One( field ),
                matrix     := [],
                bound      := [],
                nullvector := [1..dim] * Zero(field)
                );

    return LTM;
end );

#############################################################################
##
#F  QuotSysDefinitionByIndex  . . . . . . . . . . convert index to definition
##
InstallGlobalFunction( QuotSysDefinitionByIndex,
function( qs, index )
    local   r,  j,  i;

    r := RanksOfDescendingSeries( qs )[1];

    if index <= r*(r-1)/2 then
        j := 0; while j*(j-1)/2 < index do j := j+1; od;
        i := index - (j-1)*(j-2)/2;
        return [j,i];
    else
        j := index - r*(r-1)/2;
        if j mod r = 0 then
            return [ j / r + r, r ];
        else
            return [ Int( j / r ) + 1 + r, j mod r ];
        fi;
    fi;

end );

#############################################################################
##
#F  QuotSysIndexByDefinition  . . . . . . . . . . convert definition to index
##
InstallGlobalFunction( QuotSysIndexByDefinition,
function( qs, def )
    local   r;

    r := RanksOfDescendingSeries( qs )[1];
    if def[1] <= r then
        return (def[1]-2) * (def[1]-1) / 2 + def[2];
    else
        return (r-1)*r/2 +  r * (def[1]-2 - (r-1)) + def[2];
    fi;
end );

#############################################################################
##
#M  GetDefinitionNC . . . . . . . . . . . . get the definition of a generator
##
InstallMethod( GetDefinitionNC, true, [IsPQuotientSystem, IsPosInt], 0,
function( qs , g )

    return qs!.definitions[ g ];
end );

#############################################################################
##
#M  SetDefinitionNC . . . . . . . . . . . . set the definition of a generator
##
InstallMethod( SetDefinitionNC, true,
        [ IsPQuotientSystem, IsPosInt, IsObject ], 0,
function( qs, g, def )

    qs!.definitions[g] := def;
    if IsPosInt( def ) then
        qs!.isDefiningPower[ def ] := true;
    elif IsInt( def ) then
        # set image
        return;
    else
       qs!.isDefiningConjugate[ QuotSysIndexByDefinition( qs, def ) ] := true;
    fi;
end );

#############################################################################
##
#M  ClearDefinitionNC . . . . . . . . . . clear the definition of a generator
##
InstallMethod( ClearDefinitionNC, true, [ IsPQuotientSystem, IsPosInt ], 0,
function( qs, g )
    local   def;

    def := GetDefinitionNC( qs, g );

    Unbind( qs!.definitions[g] );
    if IsPosInt( def ) then
        qs!.isDefiningPower[ def ] := false;
    elif IsInt( def ) then
        return;
    else
       qs!.isDefiningConjugate[ QuotSysIndexByDefinition( qs, def ) ] := false;
    fi;
end );

#############################################################################
##
#M  NumberOfNewGenerators . . . . . . number of generators in the next layer
##
BindGlobal( "NumberOfNewGenerators", function( qs )
    local   nong,  d,  cl,  i;

    nong := 0;

    ##  One new generator for each non-defining image, ...
    nong := nong + Length(qs!.images);
    qs!.numberOfEpimGenerators := Length( qs!.nonDefiningImages );

    ##  ... one new generator for each commutator of the form [c,1] ...
    d := qs!.RanksOfDescendingSeries[1];
    for cl in Reversed( [1..LengthOfDescendingSeries(qs)] ) do

        if cl = 1 then
            nong := nong + d * (d-1) / 2;
        else
            nong := nong + d * qs!.RanksOfDescendingSeries[ cl ];
        fi;

        ##  ... and one new generator for each p-th power whose generator is
        ##  itself a p-th power or an image ...
        for i in GeneratorsOfLayer( qs, cl ) do
            if IsInt( GetDefinitionNC( qs, i ) ) then
                nong := nong + 1;
            fi;
        od;

        ##  -- Note the number of p-cover generators --
        if cl = LengthOfDescendingSeries(qs) then
            qs!.numberOfNucleusGenerators :=
              nong - Length(qs!.images);
        fi;
    od;

    ##  ... which is not a definition.  Since each generator has a
    ##  definition,  we have to subtract the number of generators.
    nong := nong - qs!.numberOfGenerators;

    qs!.numberOfPseudoGenerators :=
      nong - qs!.numberOfEpimGenerators - qs!.numberOfNucleusGenerators;

    return nong;
end );

#############################################################################
##
#M  InitaliseCentralRelations . . . . . . . . . initialise central relations
##
BindGlobal( "InitialiseCentralRelations", function( qs )

    ##  We call the relations obtained by the consistency check and the
    ##  evaluation of relations `central relations'.  They are stored as a
    ##  (lower triangular) matrix over GF(p).
    qs!.centralRelations :=
      LowerTriangularMatrix( NumberOfNewGenerators( qs ), GF(qs!.prime) );
end );

#############################################################################
##
#M  ClearCentralRelations . . . . . . . . . . . . .  delete central relations
##
BindGlobal( "ClearCentralRelations", function( qs )

    Unbind( qs!.centralRelations );
end );

#############################################################################
##
#M  CentralRelations . . . . . . . . . . . . . . . . return central relations
##
BindGlobal( "CentralRelations", function( qs )

    if not IsBound( qs!.centralRelations ) then
        InitialiseCentralRelations( qs );
    fi;

    return qs!.centralRelations;
end );

#############################################################################
##
#M  IncorporateCentralRelations . . . . . . . . . . .  relations into pc pres
##
InstallMethod( IncorporateCentralRelations,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   M,  coll,  one,  type,  i,  pair,  g,  wt,  wth,
            h,  w;

    M := CentralRelations( qs );
    coll := qs!.collector;
    one := One( qs!.field );
    type := coll![SCP_DEFAULT_TYPE];


    ##  At first we run through the images.
    for i in qs!.nonDefiningImages do
        pair := SplitWordTail( qs, qs!.images[i] );
        pair[2] := ExtRepByTailVector( qs,
                           ReducedVectorLTM( M, pair[2] * one ));
        qs!.images[i] :=
          AssocWord( type, Concatenation( pair[1], pair[2] ) );
    od;

    ##  Run through the inverses.
    for g in [1..GeneratorNumberOfQuotient(qs)] do
        w := qs!.collector![SCP_INVERSES][g];
        pair := SplitWordTail( qs, w );
        pair[2] := ExtRepByTailVector( qs,
                           ReducedVectorLTM( M, pair[2] * one ) );
        qs!.collector![SCP_INVERSES][g] :=
                AssocWord( type, Concatenation( pair[1], pair[2] ) );
    od;

    ##  Run through the power relations.
    for g in [1..GeneratorNumberOfQuotient(qs)] do
        pair := SplitWordTail( qs, GetPowerNC( qs!.collector, g ) );
        pair[2] := ExtRepByTailVector( qs,
                           ReducedVectorLTM( M, pair[2] * one ) );
        SetPowerANC( qs!.collector, g,
                AssocWord( type, Concatenation( pair[1], pair[2] ) ) );
    od;

    ##  Run through the commutator relations.
    for wt in Reversed([2..LengthOfDescendingSeries(qs)+1]) do
        wth := wt-1;
        while 2*wth >= wt do
            for h in GeneratorsOfLayer( qs, wth ) do
                for g in GeneratorsOfLayer( qs, wt - wth ) do
                    if g >= h then break; fi;

                    pair := SplitWordTail( qs,
                                    GetConjugateNC( qs!.collector, h, g ) );
                    pair[2] := ExtRepByTailVector( qs,
                                       ReducedVectorLTM( M, pair[2] * one ) );
                    SetConjugateANC( qs!.collector, h, g,
                            AssocWord( type,
                                    Concatenation( pair[1], pair[2] ) ) );

                od;
            od;
            wth := wth - 1;
        od;
    od;

    ##  Update the definitions:  The relations and images defining generators
    ##  which have been eliminated are no longer definitions.
    for g in TrailingEntriesLTM( CentralRelations( qs ) ) do
        ClearDefinitionNC( qs, GeneratorNumberOfQuotient(qs) + g );
    od;

    ##  Keep the eliminated generators.
    qs!.eliminatedGens := Union( qs!.eliminatedGens,
             TrailingEntriesLTM( CentralRelations( qs ) ) );

    ##  Throw away the central relations.
    ClearCentralRelations( qs );

end );

#############################################################################
##
#F  UpdateWeightInfo  . . . . . . . . . . . . . update the weight information
##
BindGlobal( "UpdateWeightInfo", function( qs )
    local   n,  nhwg,  ranks,  class,  last_in_cl,  avector,  cl,  wt,
            avc2,  g,  h;

    n     := GeneratorNumberOfQuotient(qs);
    nhwg  := qs!.numberOfHighestWeightGenerators;
    ranks := RanksOfDescendingSeries(qs);
    class := LengthOfDescendingSeries(qs);

    ##  Update the a-vector.
    last_in_cl := n;
    avector    := [];
    for cl in [1..Int( (LengthOfDescendingSeries(qs)+1)/2 )] do
        Append( avector, [1..ranks[cl]] * 0 + last_in_cl );
        last_in_cl := last_in_cl - ranks[ class - cl + 1 ];
    od;
    Append( avector, [Length(avector)+1..n+nhwg] );
    qs!.collector![SCP_AVECTOR] := avector;

    ##  Update the weight informataion
    class := class + 1;
    qs!.collector![SCP_CLASS] := class;

    wt := qs!.collector![SCP_WEIGHTS];
    wt{n+[1..nhwg]} := [1..nhwg] * 0 + class;

    avc2 := [1..n]+0;
    for g in [1..n] do
        if 3*wt[g] > class then
            break;
        fi;
        h := avector[g];
        while g < h and 2*wt[h] + wt[g] > class do h := h-1; od;
        avc2[g] := h;
    od;
    qs!.collector![SCP_AVECTOR2] := avc2;

    SetFilterObj( qs!.collector, IsUpToDatePolycyclicCollector );
end );

#############################################################################
##
#M  DefineNewGenerators . . . . . . . . . . . .  generators of the next layer
##
InstallMethod( DefineNewGenerators,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   gens,  n,  g,  cl,  h;

    gens := GeneratorsOfRws( qs!.collector );
    n := GeneratorNumberOfQuotient(qs);

    if n + NumberOfNewGenerators( qs ) >
       qs!.collector![SCP_NUMBER_RWS_GENERATORS] then
        return fail;
    fi;

    ##  Add new generators to the p-quotient.
    for cl in Reversed([1..LengthOfDescendingSeries(qs)]) do

        ##  Each commutator relation of the form [c,1] which is not a
        ##  definition will get a new generator.
        for h in GeneratorsOfLayer( qs, cl ) do
            for g in GeneratorsOfLayer( qs, 1 ) do
                if g >= h then break; fi;
                if not [h,g] in qs!.definitions then
                    n := n+1;
                    SetConjugateANC( qs!.collector, h, g,
                            GetConjugateNC( qs!.collector, h, g )
                            * gens[n] );
                    SetDefinitionNC( qs, n, [h,g] );
                    Info( InfoQuotientSystem, 4, "    Defining ",
                          TraceDefinition( qs, n ), " = ", n );
                fi;
            od;
        od;

        ##  A p-th power of a generator defines a new generator if the
        ##  generator was itself defined by a p-th power.
        for g in GeneratorsOfLayer( qs, cl ) do
            if not g in qs!.definitions then
                if IsInt( GetDefinitionNC( qs , g ) ) then
                    n := n+1;
                    SetPowerANC( qs!.collector, g,
                            GetPowerNC( qs!.collector, g ) * gens[n] );
                    SetDefinitionNC( qs, n, g );
                    Info( InfoQuotientSystem, 4, "    Defining ",
                          TraceDefinition( qs, n ), " = ", n );
                else
                    qs!.isDefiningPower[ g ] := false;
                fi;
            fi;
        od;
    od;

    ##  Define a new generator for each non-defining image.
    for g in qs!.nonDefiningImages do
        n := n+1;
        qs!.images[g] := qs!.images[g] * gens[n];
        SetDefinitionNC( qs, n, -g );
    od;

    qs!.numberOfHighestWeightGenerators := n - GeneratorNumberOfQuotient(qs);
    Info( InfoQuotientSystem, 2, "  Defined ",
          qs!.numberOfHighestWeightGenerators, " new generators" );

    UpdateWeightInfo( qs );

    return true;

end );

#############################################################################
##
#M  SplitWordTail . . . . . . . . . . . . . . split a word in prefix and tail
##
InstallMethod( SplitWordTail,
        "p-quotient system, word",
        true,
        [ IsPQuotientSystem, IsAssocWord ], 0,
function( qs, w )
    local   n,  c,  one,  zero,  i,  h,  t;

    n := GeneratorNumberOfQuotient(qs);
    c := qs!.numberOfHighestWeightGenerators;
    one := One( qs!.field );
    zero := 0 * one;

    w := ExtRepOfObj( w );

    ##  Find the beginning of the tail.
    i := 1; while i <= Length(w) and w[i] <= n do i := i+2; od;

    ##  Chop off the head.
    h := w{[1..i-1]};

    ##  Convert the tail into an exponent vector.
    t := [1..c] * zero;
    while i <= Length(w) do
        t[ w[i] - n ] := w[i+1] * one;
        i := i+2;
    od;

    return [ h, t ];
end );

#############################################################################
##
#M  ExtRepByTailVector  . . . . .  ext repr from an exponent vector of a tail
##
InstallMethod( ExtRepByTailVector,
        "p-quotient system, vector",
        true,
        [ IsPQuotientSystem, IsVector ], 0,
function( qs, v )
    local   extrep,  i,  zero;

    extrep := [];
    if IsInt( v[1] ) then
        for i in [1..Length(v)] do
            if v[i] <> 0 then
                Add( extrep, GeneratorNumberOfQuotient(qs) + i );
                Add( extrep, v[i] mod qs!.prime );
            fi;
        od;
    else
        zero := Zero( qs!.field );
        for i in [1..Length(v)] do
            if v[i] <> zero then
                Add( extrep, GeneratorNumberOfQuotient(qs) + i );
                Add( extrep, IntFFE(v[i]) );
            fi;
        od;
    fi;
    return extrep;
end );


#############################################################################
##
#M  TailsInverses . . compute the tails of the inverses in a single collector
##
InstallMethod( TailsInverses,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   n,  h,  M,  type,  inverses,  v,  zeroes,  g,
            t;

    n := GeneratorNumberOfQuotient(qs);
    h := n + qs!.numberOfHighestWeightGenerators;
    M := CentralRelations( qs );

    type     := qs!.collector![SCP_DEFAULT_TYPE];
    inverses := qs!.collector![SCP_INVERSES];

    v      := ListWithIdenticalEntries( h, 0 );
    zeroes := v{[n+1..h]};
    for g in [1..n] do
        repeat
            v[g] := 1;
        until CollectWordOrFail( qs!.collector, v, inverses[g] ) = true;

        t := ExtRepByTailVector( qs, ReducedVectorLTM( M, -v{[n+1..h]} ) );

        inverses[g] :=
          AssocWord( type, Concatenation( ExtRepOfObj( inverses[g] ), t ) );

        v{[n+1..h]} := zeroes;
    od;

end );

#############################################################################
##
#M  ComputeTails  . . . . . . . . . . . . compute the tails of a presentation
##
InstallMethod( ComputeTails,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   S,  p,  type,  n,  m,  l,  r,  zeroes,  c,  g,
            def,  b,  a,  t,  u,  y,  z,  x;

    S := qs!.collector;
    p := qs!.prime;
    type := S![ SCP_DEFAULT_TYPE ];
    n := GeneratorNumberOfQuotient(qs);
    m := n + qs!.numberOfHighestWeightGenerators;

    l := ListWithIdenticalEntries( m, 0 );
    r := ListWithIdenticalEntries( m, 0 );
    zeroes := ListWithIdenticalEntries( m, 0 );

    for c in Reversed( [1..LengthOfDescendingSeries(qs)] ) do

        ##  Compute tails for the power relations.
        for g in GeneratorsOfLayer( qs, c ) do
            ## Does the p-th power of g define a generator?
            if not g in qs!.definitions then
                ##  No it does not, therefore we compute the tail for g^p.

                ##  The definition must be commutator.
                def := GetDefinitionNC( qs , g );
                b := def[1]; a := def[2];

                EvaluateOverlapBNA( S, l, r, b, p, a );

                IncreaseCounter( "TailCountBNA" );

                t := ExtRepByTailVector( qs, l{[n+1..m]} - r{[n+1..m]} );

                SetPowerANC( S, g, GetPowerNC( S,g ) * AssocWord( type,t ) );

                l{[1..m]} := zeroes;  r{[1..m]} := zeroes;
            fi;
        od;

        ##  The conjugate relations.
        ##  a is the weight of the first generator, b the weight of the
        ##  second generator in a commutator.  Their sum is c.
        a := c+1-2; b := 2;
        while a >= b do
            for u in GeneratorsOfLayer( qs, b ) do
                ##  How is u defined?
                def := GetDefinitionNC( qs, u );
                ##  Compute the tail for [ z, u ]
                if IsInt( def ) then
                    y := def;
                    for z in GeneratorsOfLayer( qs, a ) do
                        if z > u then
                            IncreaseCounter( "TailCountBAN" );
                            EvaluateOverlapBAN( S, l, r, z, y, p );
                            t := ExtRepByTailVector( qs,
                                         l{[n+1..m]} - r{[n+1..m]} );

                            SetConjugateANC( S, z, u,
                                    GetConjugateNC( S,z,u )
                                    * AssocWord( type,t ) );

                            l{[1..m]} := zeroes;  r{[1..m]} := zeroes;
                        fi;
                    od;
                else
                    y := def[1];  x := def[2];
                    for z in GeneratorsOfLayer( qs, a ) do
                        if z > u then
                            IncreaseCounter( "TailCountCBA" );
                            EvaluateOverlapCBA( S, l, r, z, y, x );

                            t := ExtRepByTailVector( qs,
                                         l{[n+1..m]} - r{[n+1..m]} );

                            SetConjugateANC( S, z, u,
                                    GetConjugateNC( S, z, u )
                                    * AssocWord( type,t ) );

                            l{[1..m]} := zeroes;  r{[1..m]} := zeroes;
                        fi;
                    od;
                fi;
            od;
            a := a - 1;  b := b + 1;
        od;
    od;
end );

#############################################################################
##
#M  EvaluateConsistency . . . . . . . . . . . . . . run the consistency tests
##
InstallMethod( EvaluateConsistency,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   S,  M,  n,  m,  p,  l,  r,  wt,  a,  wta,  wtb,  bs,
            b,  c,  zeroes, which,  pos;

    S := qs!.collector;
    n := GeneratorNumberOfQuotient(qs);
    m := n + qs!.numberOfHighestWeightGenerators;
    p := qs!.prime;

    l := ListWithIdenticalEntries( m, 0 );
    r := ListWithIdenticalEntries( m, 0 );

    M := CentralRelations( qs );

    zeroes := ListWithIdenticalEntries( m, 0 );

    ##
    ##                      a^p a = a a^p
    ##  The weight condition on the first type of consistency checks is
    ##  2 wt(a) < class.
    ##
    which := "ConsCountANA";
    wt := 1;
    while 2*wt < LengthOfDescendingSeries(qs)+1 do
        for a in GeneratorsOfLayer( qs, wt ) do
            EvaluateOverlapANA( S, l, r, a, p );
            if CHECK and l{[1..n]} - r{[1..n]} <> zeroes{[1..n]} then
                Error( "result not a tail" );
            fi;
            AddVectorLTM( M, l{[n+1..m]} - r{[n+1..m]} );
            IncreaseCounter( which );
            l{[1..m]} := zeroes; r{[1..m]} := zeroes;
        od;
        wt := wt + 1;
    od;

    ##
    ##  Check all overlaps  b a^p  for  b > a and  wt(b)+wt(a) < class.
    ##
    which := "ConsCountBAN";
    for wt in [2..LengthOfDescendingSeries(qs)] do
        ##  wt = wt(a) + wt(b)
        wta := 1; wtb := wt - 1;
        while wtb >= wta do
            for a in GeneratorsOfLayer( qs, wta ) do

                bs := GeneratorsOfLayer( qs, wtb );

                if qs!.isDefiningPower[a] then

                    c := GeneratorSyllable( GetPowerNC( S, a ), 1 );

                    ##  For c < b, [b,c] is a commutator for which we have
                    ##  computed its tail by EvaluateBAN( ... b, a, p )
                    ##  Therefore, we only want to invoke EvaluateBAN() for
                    ##  those b with b <= c.

                    if bs[ 1 ] > c then
                        bs := [];
                    elif c <= bs[ Length(bs) ] then
                        bs := [bs[1]..c];
                    fi;
                fi;

                for b in bs do
                    if a < b then
                        EvaluateOverlapBAN( S, l, r, b, a, p );
                        IncreaseCounter( which );

                        if CHECK and
                           l{[1..n]} - r{[1..n]} <> zeroes{[1..n]} then
                            Error( "result not a tail" );
                        fi;
                        AddVectorLTM( M, l{[n+1..m]} - r{[n+1..m]} );

                        l{[1..m]} := zeroes; r{[1..m]} := zeroes;
                    fi;
                od;
            od;
            wta := wta+1; wtb := wtb-1;
        od;
    od;
    ##
    ##  Check all overlaps b^p a for b > a, wt(a) = 1 and
    ##  wt(a) + wt(b) < class.  Hence wt(b) < class - 1.
    ##
    which := "ConsCountBNA";
    wtb := 1;
    while wtb < LengthOfDescendingSeries(qs)+1 - 1 do
        for b in GeneratorsOfLayer( qs, wtb ) do
            for a in GeneratorsOfLayer( qs, 1 ) do
                if a >= b then break; fi;

                pos := Position( qs!.definitions, [b,a] );
                if pos = fail or pos > qs!.numberOfGenerators then

                    EvaluateOverlapBNA( S, l, r, b, p, a );
                    IncreaseCounter( which );

                    if CHECK and l{[1..n]} - r{[1..n]} <> zeroes{[1..n]} then
                        Error( "result not a tail" );
                    fi;
                    AddVectorLTM( M, l{[n+1..m]} - r{[n+1..m]} );

                    l{[1..m]} := zeroes; r{[1..m]} := zeroes;
                fi;
            od;
        od;
        wtb := wtb + 1;
    od;


    ##
    ##  Check overlaps c b a with c > b > a and wt(a) = 1 and
    ##  wt(a) + wt(b) + wt(c) <= class.
    ##
    ##  Since wt(a) = 1 and wt(b) <= wt(c) we can reformulate the above
    ##  condition to
    ##
    ##          wt(b) <= wt(c) = wt - wt(b) - 1
    ##  where wt runs from 1 to class.
    ##  So we get 2 * wt(b) <= wt - 1.
    which := "ConsCountCBA";
    wt := 2;
    while wt <= LengthOfDescendingSeries(qs)+1 do
        wtb := 1;
        while 2 * wtb <= wt - 1 do
            for c in GeneratorsOfLayer( qs, wt - wtb - 1 ) do
                for b in GeneratorsOfLayer( qs, wtb ) do
                    if b >= c then break; fi;

                    for a in GeneratorsOfLayer( qs, 1 ) do
                        if a >= b then break; fi;

                        pos := Position( qs!.definitions, [b,a] );
                        if pos = fail or pos > qs!.numberOfGenerators
                           or pos >= c then
                            EvaluateOverlapCBA( S, l, r, c, b, a );

            if CHECK and l{[1..n]} - r{[1..n]} <> zeroes{[1..n]} then
                Error( "result not a tail" );
            fi;
                        AddVectorLTM( M, l{[n+1..m]} - r{[n+1..m]} );

                        IncreaseCounter( which );
                        l{[1..m]} := zeroes; r{[1..m]} := zeroes;
                        fi;
                    od;
                od;
            od;
            wtb := wtb + 1;
        od;
        wt := wt + 1;
    od;
end );

#############################################################################
##
#M  RenumberHighestWeightGenerators . . . . . . . . . . . renumber generators
##
InstallMethod( RenumberHighestWeightGenerators,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   n,  c,  gens,  surgens,  newgens,  g,
            i,  w,  h,  wt,  wth,  renumber;

    ##  Those generators which have been eliminated from the quotient system
    ##  don't occur anymore.  Now we replace the surviving generators by a
    ##  consecutive list of generators.
    n := GeneratorNumberOfQuotient(qs);
    c := qs!.numberOfHighestWeightGenerators;

       gens := GeneratorsOfRws( qs!.collector );
    surgens := n + DifferenceLists( [1..c], qs!.eliminatedGens );
    newgens := gens{[1..n+Length(surgens)]};

    renumber := [];
    renumber{Concatenation([1..n], surgens)} := [1..n+Length(surgens)];

    ##  Update the definitions of the surviving generators.
    for g in [1..Length(surgens)] do
        SetDefinitionNC( qs, n+g, GetDefinitionNC( qs, surgens[g] ) );
    od;
    qs!.definitions := qs!.definitions{[1..Length(newgens)]};

    ##  Run through all non-defining images.
    for i in qs!.nonDefiningImages do
        qs!.images[i] := RenumberedWord( qs!.images[i], renumber );
    od;

    ##  Run through all inverses
    for g in [1..GeneratorNumberOfQuotient(qs)] do
        w := qs!.collector![SCP_INVERSES][g];
        w := RenumberedWord( w, renumber );
        qs!.collector![SCP_INVERSES][g] := w;
    od;

    ##  Run through all power relations
    for g in [1..GeneratorNumberOfQuotient(qs)] do
        w := GetPowerNC( qs!.collector, g );
        w := RenumberedWord( w, renumber );
        SetPowerANC( qs!.collector, g, w );
    od;

    ##  Run through all conjugate relations
    for wt in Reversed([2..LengthOfDescendingSeries(qs)+1]) do
        wth := wt-1;
        while 2*wth >= wt do
            for h in GeneratorsOfLayer( qs, wth ) do
                for g in GeneratorsOfLayer( qs, wt - wth ) do
                    if g >= h then break; fi;

                    w := GetConjugateNC( qs!.collector, h, g );
                    w := RenumberedWord( w, renumber );
                    SetConjugateANC( qs!.collector, h, g, w );
                od;
            od;
            wth := wth - 1;
        od;
    od;

    Add( qs!.RanksOfDescendingSeries,
         qs!.numberOfHighestWeightGenerators - Length( qs!.eliminatedGens ) );

    qs!.numberOfGenerators := qs!.numberOfGenerators +
                             qs!.numberOfHighestWeightGenerators -
                             Length( qs!.eliminatedGens );

    qs!.numberOfHighestWeightGenerators := 0;
    qs!.eliminatedGens := [];
end );

#############################################################################
##
#M  EvaluateRelators  . . . . . . . evaluate relations of a p-quotient system
##
BindGlobal( "EvaluateRelation", function( sc, w, gens )
    local   v,  i,  g,  e,  j;

    v := ListWithIdenticalEntries( Length(gens), 0 );
    for i in [1..NumberSyllables(w)] do
        g := GeneratorSyllable( w, i );
        e := ExponentSyllable( w, i );
        if e > 0 then
            for j in [1..e] do
                if CollectWordOrFail( sc, v, gens[g] ) = fail then
                    return fail;
                fi;
            od;
        else
            for j in [1..-e] do
                if CollectWordOrFail( sc, v, sc![SCP_INVERSES][g] ) = fail then
                    return fail;
                fi;
            od;
        fi;
    od;
    return v;
end );


InstallMethod( EvaluateRelators,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )
    local   G,  S,  n,  c,  F,  Fgens,  LTM,  v, zeroes,  r,  rr;

    G := qs!.preimage;
    S := qs!.collector;

    n := GeneratorNumberOfQuotient(qs);
    c := qs!.numberOfHighestWeightGenerators;

    F     := FreeGroupOfFpGroup( G );
    Fgens := GeneratorsOfGroup( F );

    LTM := CentralRelations( qs );

    v := ListWithIdenticalEntries( n+c, 0 );
    zeroes := v{[n+1..n+c]};

    for r in RelatorsOfFpGroup( G ) do
        rr := MappedWord( r, Fgens, qs!.images );
#        v := EvaluateRelation( S, rr, gens );
#        while v = fail do
#            v := EvaluateRelation( S, rr, gens );
#        od;
        while CollectWordOrFail( S, v, rr ) = fail do
            Info( InfoQuotientSystem, 3,
                  "Warning: Collector failed in evaluating relator",
                  " and was restarted" );
        od;
        AddVectorLTM( LTM, v{[n+1..n+c]} );

        v{[n+1..n+c]} := zeroes;
    od;
end );

#############################################################################
##
#M  LiftEpimorphism . . . . . . . .  lift the epimorphism onto the p-quotient
##
InstallMethod( LiftEpimorphism,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )

    #  Compute tails for inverses of generators.
    TailsInverses( qs );

    #  Evaluate relations.
    EvaluateRelators( qs );

end );

#############################################################################
##
#M  QuotientSystem  . . . . . . . . . . . . .  initialize a p-quotient system
##
InstallMethod( QuotientSystem,
        "pquotient",
        true,
        [ IsGroup, IsPosInt, IsPosInt, IsString ],
        0,
function( G, p, n, collector )
    local   qs,  fam,  type;

    if not IsPrime(p) then
        return Error( "prime expected" );
    fi;

    qs := rec();

    ## The finitely presented group.
    qs.preimage := G;

    ## The p-quotient.
    qs.prime := p;
    qs.field := GF(p);

    ##  The p-rank of each factor in the p-central series.  The p-class is
    ##  the length of this list.
    qs.LengthOfDescendingSeries := 0;
    qs.RanksOfDescendingSeries  := [];

    ##     images of the generators in G.
    qs.images := [];

    ##     definitions of the generators in P.
    qs.isDefiningPower := [];
    qs.isDefiningConjugate := [];
    qs.definitions := [];
    qs.nonDefiningImages := [];


    ##  Create the collector.
    if collector = "combinatorial" then
        qs.collector := CombinatorialCollector(
          FreeGroup(IsSyllableWordsFamily, n, "a" ), p );
    else
        qs.collector := SingleCollector(
          FreeGroup(IsSyllableWordsFamily, n, "a" ), p );
    fi;

    qs.collector![SCP_INVERSES] :=
      List( qs!.collector![SCP_RWS_GENERATORS], g->g^(p-1) );
    qs.collector![SCP_CLASS]   := 0;
    qs.collector![SCP_WEIGHTS] := [];

    ##  Number of used generators in the collector not counting the highest
    ##  weight generators.
    qs.numberOfGenerators := 0;

    ##  Number of highest weight generators.
    qs.numberOfHighestWeightGenerators := 0;

    ##  Eliminated generators: contains those generators which have been
    ##  eliminated by applying central relations to the quotient system.
    ##  These are used when generators are renumbered.
    qs.eliminatedGens := [];

    ##  Now turn this into a new object.
    fam  := NewFamily( "QuotientSystem", IsQuotientSystem );
    type := NewType( fam, IsPQuotientSystem and IsMutable and IsComponentObjectRep );
    Objectify( type, qs );

    return qs;
end );

#############################################################################
##
#M  GeneratorNumberOfQuotient . . . . . . . .  generator number of p-quotient
##
InstallMethod( GeneratorNumberOfQuotient,
    "p-quotient system",
    true,
    [IsPQuotientSystem], 0,
function( qs )
    return qs!.numberOfGenerators;
end );

#############################################################################
##
#M  GeneratorsOfLayer . . . .  generators of a layer in the descending series
##
InstallMethod( GeneratorsOfLayer,
    "p-quotient system",
    true,
    [IsPQuotientSystem, IsPosInt], 0,
function( qs, cl )
    local   ranks,  s;

    ranks := RanksOfDescendingSeries( qs );
    s     := Sum( ranks{[1..cl-1]} );
    return s + [1..ranks[cl]];
end );


#############################################################################
##
#M  LengthOfDescendingSeries  . . . . . . . . length of the descending series
##
InstallMethod( LengthOfDescendingSeries,
    "p-quotient system",
    true,
    [IsPQuotientSystem], 0,
function( qs )
    return Length(RanksOfDescendingSeries(qs));
end );


#############################################################################
##
#M  RanksOfDescendingSeries . . ranks of the factors in the descending series
##
InstallMethod( RanksOfDescendingSeries,
    "p-quotient system",
    true,
    [IsPQuotientSystem], 0,
function( qs )
    return qs!.RanksOfDescendingSeries;
end );


#############################################################################
##
#M  CheckConsistencyOfDefinitions . . . . .  check consistency of definitions
##
InstallMethod( CheckConsistencyOfDefinitions,
        "p-quotient system",
        true,
        [IsPQuotientSystem], 0,
function( qs )
    local   g,  h,  def;

    ##  Is each generator marked as defining power contained in .definitions?
    for g in [1..GeneratorNumberOfQuotient(qs)
            -RanksOfDescendingSeries(qs)[LengthOfDescendingSeries(qs)]] do
        if qs!.isDefiningPower[g] and not g in qs!.definitions then
            Print( "#W  Generator number ", g );
            Print( " is marked as a defining power.\n" );
            Print( "#W  There is no corresponding definition.\n" );
            return fail;
        fi;
    od;

    ##  Is each pair of generators marked as defining conjugate contained in
    ##  .definitions?
    for h in [1..GeneratorNumberOfQuotient(qs)
            -RanksOfDescendingSeries(qs)[LengthOfDescendingSeries(qs)]] do
        for g in [1..Minimum( RanksOfDescendingSeries(qs)[1], h-1 )] do
            if qs!.isDefiningConjugate[
                       QuotSysIndexByDefinition( qs, [h,g] ) ] and
               not [h,g] in qs!.definitions then
                Print( "#W  Generator pair ", [h,g] );
                Print( " is marked as a defining conjugate.\n" );
                Print( "#W  There is no corresponding definition.\n" );
                return fail;
            fi;
        od;
    od;

    ##  Is each definition marked in .definingPower or .definingConjugate?
    for def in qs!.definitions do
        if IsPosInt( def ) then
            if not qs!.isDefiningPower[ def ] then
                Print( "#W  The power of generator number ", def );
                Print( " defines a generator.\n" );
                Print( "#W  The generator is not marked as defining.\n" );
                return fail;
            fi;
        elif IsInt( def ) then
            ## check defining images
        else
            if not qs!.isDefiningConjugate[
                       QuotSysIndexByDefinition( qs, def ) ] then
                Print( "#W  The conjugate pair ", def );
                Print( " defines a generator.\n" );
                Print( "#W  The pair is not marked as defining.\n" );
                return fail;
            fi;
        fi;
    od;

end );

#############################################################################
##
#F  AbelianPQuotient  . . . . . . . . . . .  initialize an abelian p-quotient
##
InstallGlobalFunction( AbelianPQuotient,
function( qs )
    local   G,  n,  gens,  LTM,  trailers,  d,
            generators,  i,  r,  l;

    # Setup some variables.
    G    := qs!.preimage;
    n    := Length( GeneratorsOfGroup( G ) );
    gens := GeneratorsOfRws( qs!.collector );

    LTM := LowerTriangularMatrix( n, qs!.field );
    for r in RelatorsOfFpGroup( G ) do
        AddVectorLTM( LTM, ExponentSums( r ) );
    od;

    RowEchelonFormLTM( LTM );
    trailers := TrailingEntriesLTM( LTM );

    ##  Each row in LTM corresponds to a generator that can be expressed in
    ##  terms of earlier generators.  The column of the trailing entry is the
    ##  generator number.
    qs!.nonDefiningImages := trailers;

    ##  The p-rank.
    d := n - Length( trailers );

    ##  The generator numbers of the p-quotient
    generators := DifferenceLists( [1..n], trailers );

    ##  Their images are the first d generators.
    qs!.images{ generators } := gens{[1..d]};

    ##  Fix their definitions.
    qs!.definitions{[1..d]} := -generators;

    ##  Now we have to compute the images of the non defining generators.
    l := 0;
    for i in Reversed([1..Length(LTM.matrix)]) do
        if IsBound( LTM.matrix[i] ) then
            l := l+1;
            r := ShallowCopy(-LTM.matrix[i]);
            r[ trailers[l] ] := 0;
            qs!.images[ trailers[l] ] :=
              ObjByExponents( qs!.collector, List( r{generators}, Int ) );
        fi;
    od;

    qs!.numberOfGenerators := Length( qs!.definitions );
    qs!.RanksOfDescendingSeries[1] := Length( qs!.definitions );

    ##  Update the weight information
    qs!.collector![SCP_CLASS] := 1;
    qs!.collector![SCP_WEIGHTS]{[1..qs!.numberOfGenerators]} :=
      [1..qs!.numberOfGenerators] * 0 + 1;

end );

#############################################################################
##
#F  PQuotient . . . . . . . . . . .  p-quotient of a finitely presented group
##
InstallGlobalFunction( PQuotient,
function( arg )

    local   G,  p,  cl,  ngens,  collector,  qs,  t,noninteractive;


    ##  First we parse the arguments to this function
    if Length( arg ) < 2 or Length( arg ) >= 6 then
        Error( "PQuotient( <G>, <p>, <cl>",
               " [, <ngens>] [, \"single\" | \"combinatorial\" ] )" );
    fi;

    G := arg[1];
    if not IsFpGroup( G ) then
        Error( "The first argument must be a finitely presented group" );
    fi;

    p := arg[2];
    if not (IsInt(p) and p > 0 and IsPrime( p )) then
        Error( "The second argument must be a positive prime" );
    fi;

    ##  defaults for the optional parameters
    cl        := 666;
    ngens     := 256;
    collector := "combinatorial";

    if Length( arg ) >= 3 then
        cl := arg[3];
        if not (IsInt(3) and cl > 0) then
            Error( "The third argument (if present) is the p-class and",
                   " must be a positive integer" );
        fi;
    fi;

    if Length( arg ) >= 4 then
        if IsInt(arg[4]) then
            ngens := arg[4];
            if not ngens > 0 then
                Error( "If the fourth argument is present and an integer,",
                       " then it is the initial number of generators in the",
                       " collector and must be a positive integer" );
            fi;
        elif IsString( arg[4] ) then
            collector := arg[4];
            if not (collector = "single" or collector = "combinatorial") then
                Error( "If the fourth argument is present and a string",
                       " then it is the collector that is used during the",
                       " p-quotient algorithm and must be either ",
                       " \"single\" or \"combinatorial\"" );
            fi;
        fi;
    fi;

    if Length( arg ) >= 5 then
        collector := arg[5];
        if not (IsString( collector ) and
                (collector = "single" or collector = "combinatorial")) then
                Error( "If the fifth argument is present and a string",
                       " then it is the collector that is used during the",
                       " p-quotient algorithm and must be either ",
                       " \"single\" or \"combinatorial\"" );
        fi;
    fi;

    # do we call the routine within code (and want a `fail' returned if not
    # enough generators can be created, instead of an error message.
    noninteractive:=ValueOption("noninteractive")=true;

    ClearPQuotientStatistics();
    qs := QuotientSystem( G, p, ngens, collector );

    ##
    ## First do the abelian p-quotient.  This might later on become a special
    ## case of the general step.
    ##
    Info( InfoQuotientSystem, 1, "Class ",
          LengthOfDescendingSeries(qs)+1, " quotient" );

    t := Runtime();
    AbelianPQuotient( qs );

    Info( InfoQuotientSystem, 1, "  rank of this layer: ",
          RanksOfDescendingSeries(qs)[LengthOfDescendingSeries(qs)],
          " (runtime: ", Runtime()-t, " msec)" );

    while LengthOfDescendingSeries(qs) < cl do

        t := Runtime();
        Info( InfoQuotientSystem, 1,
              "Class ", LengthOfDescendingSeries(qs)+1, " quotient" );

        Info( InfoQuotientSystem, 2, "  Define new generators." );
        if DefineNewGenerators( qs ) = fail then
          if noninteractive then
            return fail;
          else
            Error( "Collector not large enough ",
                   "to define generators for the next class.\n",
                   "To return the current quotient (of class ",
                   LengthOfDescendingSeries(qs), ") type `return;' ",
                   "and `quit;' otherwise.\n" );

            return qs;
          fi;
        fi;

        Info( InfoQuotientSystem, 2, "  Compute tails." );
        ComputeTails( qs );

        Info( InfoQuotientSystem, 2, "  Enforce consistency." );
        EvaluateConsistency( qs );

        Info( InfoQuotientSystem, 2, "  Lift epimorphism." );
        LiftEpimorphism( qs );

        Info( InfoQuotientSystem, 2, "  Incorporate relations." );
        IncorporateCentralRelations( qs );

        if qs!.numberOfHighestWeightGenerators
           > Length(qs!.eliminatedGens) then
            RenumberHighestWeightGenerators( qs );

        else
            qs!.numberOfHighestWeightGenerators := 0;
            qs!.eliminatedGens := [];
            return qs;
        fi;

        Info( InfoQuotientSystem, 1, "  rank of this layer: ",
              RanksOfDescendingSeries(qs)[LengthOfDescendingSeries(qs)],
              " (runtime: ", Runtime()-t, " msec)" );
    od;
    return qs;
end );


#############################################################################
##
#M  EpimorphismPGroup . . . . . . . . . . . . . .  epimorphism onto a p-group
##
InstallMethod( EpimorphismPGroup,
        "for finitely presented groups",
        true,
        [IsSubgroupFpGroup and IsWholeFamily, IsPosInt],
        0,
        function( G, p )

    return EpimorphismPGroup( G, p, 1000 );
end );

InstallMethod( EpimorphismPGroup,
        "for finitely presented groups, class bound", true,
        [IsSubgroupFpGroup and IsWholeFamily, IsPosInt, IsPosInt], 0,
function( G, p, c )
local ngens,pq;
  ngens:=32;
  repeat
    ngens:=ngens*8;
    pq:=PQuotient(G,p,c,ngens:noninteractive);
  until pq<>fail;
  return EpimorphismQuotientSystem(pq);
end );


InstallMethod( EpimorphismPGroup,
        "for subgroups of finitely presented groups",
        true,
        [IsSubgroupFpGroup, IsPosInt ],
        0,
function( U, p )
    return EpimorphismPGroup( U, p, 1000 );
end );

InstallMethod( EpimorphismPGroup,
  "for subgroups of finitely presented groups, class bound",true,
  [IsSubgroupFpGroup, IsPosInt, IsPosInt ],0,
function( U, p, c )
local phi, ngens, qs, psi, images, eps;

    phi:=IsomorphismFpGroup( U );

    ngens:=32;
    repeat
      ngens:=ngens*8;
      qs:=PQuotient(Image(phi),p,c,ngens:noninteractive );
    until qs<>fail;

    psi:=EpimorphismQuotientSystem( qs );

#    images := GeneratorsOfGroup( U );
#    images := List( images , g->Image( phi, g ) );

    images:=MappingGeneratorsImages(phi)[2];
    images:=List( images , g->Image( psi, g ) );

    eps:=CompositionMapping2(psi,phi);

    SetIsSurjective( eps, true );

    return eps;
end);

InstallMethod( EpimorphismPGroup,"finite groups",true,
        [IsFinite and IsGroup, IsPosInt ],0,
function( U, p )
  return EpimorphismPGroup( U, p, LogInt(Size(U),p) );
end );

InstallMethod( EpimorphismPGroup,"finite group, class bound",true,
  [IsFinite and IsGroup, IsPosInt, IsPosInt ],0,
function( U, p, c )
local ser;
  if IsSubgroupFpGroup(U) or IsFreeGroup(U) then
    TryNextMethod(); # fp groups *use* the PQ for the central series.
  fi;
  ser:=PCentralSeries(U,p);
  c:=Minimum(c+1,Length(ser));
  return NaturalHomomorphismByNormalSubgroupNC(U,ser[c]);
end);


#############################################################################
##
#M  GroupByQuotientSystem . . . . . . . . . . .  group from a quotient system
##
InstallMethod( GroupByQuotientSystem,
        "p-group from a p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
        function( qs )
    local   n,  coll,  i;

    n := qs!.numberOfGenerators + qs!.numberOfHighestWeightGenerators;

    coll := ShallowCopy(qs!.collector);

    coll![ SCP_NUMBER_RWS_GENERATORS ] := n;

    for i in
      [ SCP_RWS_GENERATORS,
        SCP_POWERS,
        SCP_INVERSES,
        SCP_CONJUGATES,
        SCP_AVECTOR,
        SCP_AVECTOR2,
        SCP_RELATIVE_ORDERS,
        SCP_WEIGHTS ] do

        if not IsBound( coll![ i ] ) then
            continue;
        fi;
        if Length( coll![ i ] ) > n then
            # truncate the collector to the correct number of generators
            coll![ i ] := coll![ i ]{[1..n]};
        else
            # make a shallow copy, so that modifications made to coll do not
            # modify qs!.collector (e.g. in HPC-GAP, GroupByRwsNC makes all
            # members of the given collector readonly; if it shares e.g. its
            # SCP_WEIGHTS with qs!.collector, then this would cause errors
            # later on when extending the quotient system.
            coll![ i ] := ShallowCopy( coll![ i ] );
        fi;
    od;
    return GroupByRwsNC( coll );
end );

#############################################################################
##
#F  PCover  . . . . . . . . . . . . . . . . . .  p-cover of a quotient system
##
BindGlobal( "PCover", function( qs )
    local   G,  range,  defByEpim,  g;

    if DefineNewGenerators( qs ) = fail then
        Error( "Collector not large enough ",
               "to define generators for the next class.\n" );
        return fail;
    fi;

    ComputeTails( qs );
    EvaluateConsistency( qs );
    IncorporateCentralRelations( qs );

    G := GroupByQuotientSystem( qs );

    range := [1..qs!.numberOfHighestWeightGenerators];

    ##  Construct the subgroup generated by generators which have not been
    ##  eliminated.
    range := DifferenceLists( range, qs!.eliminatedGens );

    range := range + GeneratorNumberOfQuotient(qs);

    ##  We do not want to include highestweight generators that are defined
    ##  as images of the epimorphism.
    defByEpim := [];
    for g in range do
        if IsNegRat( GetDefinitionNC(qs, g) ) then Add( defByEpim, g ); fi;
    od;
    range := DifferenceLists( range, defByEpim );

    ##
    ##  Add all the other generators
    ##
    range := Concatenation( [1..GeneratorNumberOfQuotient(qs)], range );

    return Group( GeneratorsOfGroup(G){range}, One(G) );
end );

#############################################################################
##
#F  PMultiplicator  . . . . . . . . . . . . . .  p-multiplicator of a p-cover
##
BindGlobal( "PMultiplicator", function( qs, G )
    local   n,  gens;

    n    := GeneratorNumberOfQuotient( qs );
    gens := GeneratorsOfGroup( G );

    return Subgroup( G, gens{[n+1..Length(gens)]} );
end );

#############################################################################
##
#F  Nucleus . . . . . . . . . . . . . . . . . . . .  the nucleus of a p-cover
##
InstallMethod(Nucleus, "for a p-quotient system and a group",
    [IsPQuotientSystem,IsGroup],
    function( qs, G )
    local   n,  gens,  m;

    n    := GeneratorNumberOfQuotient( qs );
    gens := GeneratorsOfGroup( G );

    ##  The first highest weight generators generate the nucleus.  Find those
    ##  which have not been eliminated.
    m := Length( DifferenceLists( [1..qs!.numberOfNucleusGenerators],
                              qs!.eliminatedGens ) );

    return Subgroup( G, gens{[n+1..n+m]} );

end);

#############################################################################
##
#F  AllowableSubgroup . . . .  return the subgroup generated by the relations
##
BindGlobal( "AllowableSubgroup", function( qs, G )
    local   LTM,  gens,  fam,  n,  i,  extrep,  j;

    LiftEpimorphism( qs );

    ##  convert central relations to words in G and return the result.
    LTM := CentralRelations( qs );

    gens := [];
    fam := ElementsFamily( FamilyObj(G) );
    n := GeneratorNumberOfQuotient( qs );

    for i in LTM.bound do
        ##  skip central relations that express generators defined by the
        ##  epimorphism in terms of earlier generators.  Those generators are
        ##  the last generators among the highest weight generators.
        if i <= qs!.numberOfHighestWeightGenerators
           - qs!.numberOfEpimGenerators  then

            ##  convert the vector into an external representation
            extrep := [];
            for j in [1..LTM.dimension] do
                if LTM.matrix[i][j] <> LTM.zero then
                    Add( extrep, n+j );
                    Add( extrep, Int( LTM.matrix[i][j] ) );
                fi;
            od;
            Add( gens, ObjByExtRep( fam, extrep ) );

        fi;
    od;

    return Subgroup( G, gens );
end );

#############################################################################
##
#M  ViewObj . . . . . . . . . . . . . . . . . . . .  view a p-quotient system
##
InstallMethod( ViewObj,
        "p-quotient system",
        true,
        [ IsPQuotientSystem ], 0,
function( qs )

    Print( "<",
           qs!.prime,
           "-quotient system of ",
           qs!.prime,
           "-class ",
           LengthOfDescendingSeries( qs ),
           " with ",
           GeneratorNumberOfQuotient( qs ),
           " generators" );

    if qs!.numberOfHighestWeightGenerators > 0 then
        Print( " and ",
               qs!.numberOfHighestWeightGenerators,
               " highest weight generators" );
    fi;
    Print( ">" );
end );


#############################################################################
##
#M  EpimorphismQuotientSystem
##
InstallMethod(EpimorphismQuotientSystem,
    "for p-quotient systems",
    true,
    [IsPQuotientSystem],
    0,  function(qs)

    local   H,  l,  hom;

    H := GroupByQuotientSystem( qs );
    SetIsPGroup( H, true );
    SetPrimePGroup( H, qs!.prime );

    # now we write the images of the generators of G in H from qs:
    l := List(qs!.images,x->ObjByExtRep(FamilyObj(One(H)),ExtRepOfObj(x)));

    hom:=GroupHomomorphismByImagesNC(qs!.preimage,H,
                 GeneratorsOfGroup(qs!.preimage),l);

    # The homomorphism is surjective.
    SetIsSurjective(hom,true);

    return hom;
end );

#############################################################################
##
#M  EpimorphismNilpotentQuotient
##
##  This function does not belong here
##
InstallGlobalFunction("EpimorphismNilpotentQuotient",function(arg)
local g,n;
  g:=arg[1];
  if Length(arg)>1 then
    n:=arg[2];
  else
    n:=fail;
  fi;
  return EpimorphismNilpotentQuotientOp(g,n);
end);

InstallMethod( EpimorphismNilpotentQuotientOp,"subgroup fp group",
        true, [ IsSubgroupFpGroup,IsObject],0,
function(G,n)
local iso;
  iso:=IsomorphismFpGroup(G);
  return iso*EpimorphismNilpotentQuotient(Image(iso),n);
end);

InstallMethod( EpimorphismNilpotentQuotientOp,"full fp group",
        true, [ IsSubgroupFpGroup and IsWholeFamily,IsObject],0,
function(g,n)
local a,h,i,q,d,img,geni,gen,hom,lcs,c,sqa,cnqs,genum;

    a:=Set( Flat( List( AbelianInvariants(g), Factors ) ) );
    if 0 in a then
        Error("infinite quotients currently impossible");
    fi;
    if Length(a) = 0 then
        return NaturalHomomorphismByNormalSubgroup(g,g);
    fi;

    h:=[];
    for i in a do
        if n <> fail then
          # caveat: The PQ gives p-class. We might have to go to a higher
          # p-class to get the corresponding nilpotency class
          c:=n;
          cnqs:=1;
          #T the way we run the pq iteratively is a bit stupid. Once the
          #T interface is documented it would be better to run it iteratively
          repeat
            sqa:=cnqs;
            c:=c+1;
            genum:=Minimum(8192,(c*Length(GeneratorsOfGroup(g)))^2);
            q := PQuotient(g,i,c,genum);

            # try to increase the number of generators in time
            if q!.numberOfGenerators*8>genum then
              genum:=genum*16;
            fi;

            q := EpimorphismQuotientSystem( q );
            lcs:=LowerCentralSeriesOfGroup(Image(q));
            # size of the class-n quotient bit so far
            cnqs:=Index(lcs[1],lcs[Minimum(Length(lcs),n+1)]);
          until cnqs=sqa; # the class-n-quotient did not grow
          if Length(lcs)>n+1 then
            # take only the top bit
            q:=q*NaturalHomomorphismByNormalSubgroupNC(lcs[1],lcs[n+1]);
          fi;
        else
          q := PQuotient(g,i,1000,
            Maximum(256,(40*Length(GeneratorsOfGroup(g)))^2));
          q := EpimorphismQuotientSystem( q );
        fi;
        Add(h,q);
    od;

    d := DirectProduct( List( h, ImagesSource ) );
    geni:=[];
    for gen in GeneratorsOfGroup(g) do
        img := One(d);
        for i in [1..Length(a)] do
            img:=img * Image( Embedding(d,i), Image(h[i],gen) );
        od;
        Add( geni, img );
    od;

    hom:=GroupHomomorphismByImagesNC(g,d,GeneratorsOfGroup(g),geni);

    # The homomorphism is surjective.
    SetIsSurjective(hom,true);

    return hom;
end);



#############################################################################
##
#M  TraceDefinition . . . . . . trace a generator back to defining generators
##
InstallMethod( TraceDefinition,
        "p-quotient system",
        true,
        [ IsPQuotientSystem, IsPosInt ], 0,
        function( qs, g )

    local   def,  trace;

    def := GetDefinitionNC( qs, g );
    trace := [];
    while IsList( def ) or IsPosInt( def ) do
        if IsList( def ) then
            g := def[1];
            Add( trace, def[2] );
        else
            g := def;
            Add( trace, '^' );
        fi;
        def := GetDefinitionNC( qs, g );
    od;
    Add( trace, g );
    return Reversed( trace );
end );

#############################################################################
##
#E  Emacs . . . . . . . . . . . . . . . . . . . . . . . . . . emacs variables
##
##  Local Variables:
##  mode:               outline
##  tab-width:          4
##  outline-regexp:     "#[ACEFHMOPRWY]"
##  fill-column:        77
##  fill-prefix:        "##  "
##  eval:               (hide-body)
##  End:
