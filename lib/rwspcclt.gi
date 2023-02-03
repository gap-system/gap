#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods polycyclic rewriting systems.
##


#############################################################################
##
#F  IsIdenticalObjFamiliesColObjObj( <rws>, <obj>, <obj> )
##
BindGlobal( "IsIdenticalObjFamiliesColObjObj", function( a, b, c )
    return IsIdenticalObj( a!.underlyingFamily, b )
       and IsIdenticalObj( b, c );
end );


#############################################################################
##
#F  IsIdenticalObjFamiliesColObjObjObj( <rws>, <obj>, <obj>, <obj> )
##
BindGlobal( "IsIdenticalObjFamiliesColObjObjObj", function( a, b, c, d )
    return IsIdenticalObj( a!.underlyingFamily, b )
       and IsIdenticalObj( b, c )
       and IsIdenticalObj( b, d );
end );


#############################################################################
##
#F  IsIdenticalObjFamiliesColXXXObj( <col>, <obj>, <obj> )
##
BindGlobal( "IsIdenticalObjFamiliesColXXXObj", function( a, b, c )
    return IsIdenticalObj( a!.underlyingFamily, c );
end );


#############################################################################
##
#F  IsIdenticalObjFamiliesColXXXXXXObj( <rws>, <obj>, <obj>, <obj> )
##
BindGlobal( "IsIdenticalObjFamiliesColXXXXXXObj", function( a, b, c, d )
    return IsIdenticalObj( a!.underlyingFamily, d );
end );


#############################################################################
##
#F  FinitePolycyclicCollector_IsConfluent( <col> )
##
BindGlobal( "FinitePolycyclicCollector_IsConfluent", function( col, failed )
    local   gens,  rods,  k,  gk,  j,  gj,  i,  gi,  r1,  r2;

    gens := GeneratorsOfRws(col);
    rods := RelativeOrders(col);

    # be verbose for debugging
    #Print( "#I  'IsConfluent' part 1\n" );
    #R := Runtime();

    # consistency relations: gk * ( gj * gi ) = ( gk * gj ) * gi
    for k  in [ 1 .. Length(gens) ]  do
        gk := gens[k];
        for j  in [ 1 .. k - 1 ]  do
            gj := gens[j];
            for i  in [ 1 .. j - 1 ]  do
                gi := gens[i];
                r1 := ReducedProduct(col, gk, ReducedProduct(col, gj, gi));
                r2 := ReducedProduct(col, ReducedProduct(col, gk, gj), gi);
                if r1 <> r2  then
                    if failed = false  then
                        return false;
                    else
                        Add( failed, [ 1, gk, gj, gi ] );
                    fi;
                fi;
            od;
        od;
    od;

    # be verbose for debugging
    #Print( "#I  'IsConfluent' part 2, ", Runtime()-R, "\n" );
    #R := Runtime();

    # consistency relations: gj^ej-1 * ( gj * gi ) = ( gj^ej-1 * gj ) * gi
    for j  in [ 1 .. Length(gens) ]  do
        gj := gens[j];
        for i  in [ 1 .. j - 1 ]  do
            gi := gens[i];
            r1 := ReducedProduct( col, ReducedPower( col, gj, rods[j]-1 ),
                      ReducedProduct( col, gj, gi ) );
            r2 := ReducedProduct( col, ReducedProduct( col,
                      ReducedPower( col, gj, rods[j]-1 ), gj ), gi );
            if r1 <> r2  then
                if failed = false  then
                    return false;
                else
                    Add( failed, [ 2, gj, rods[j]-1, gj, gi ] );
                fi;
            fi;
        od;
    od;

    # be verbose for debugging
    #Print( "#I  'IsConfluent' part 3, ", Runtime()-R, "\n" );
    #R := Runtime();

    # consistency relations: gj * ( gi^ei-1 * gi ) = ( gj * gi^ei-1 ) * gi
    for j  in [ 1 .. Length( gens ) ]  do
        gj := gens[j];
        for i  in [ 1 .. j - 1 ]  do
            gi := gens[i];
            r1 := ReducedProduct( col, gj, ReducedProduct( col,
                      ReducedPower( col, gi, rods[i]-1 ), gi ) );
            r2 := ReducedProduct( col, ReducedProduct( col, gj,
                      ReducedPower( col, gi, rods[i]-1 ) ), gi );
            if r1 <> r2  then
                if failed = false  then
                    return false;
                else
                    Add( failed, [ 3, gj, gi, rods[i]-1, gi ] );
                fi;
            fi;
        od;
    od;

    # be verbose for debugging
    #Print( "#I  'IsConfluent' part 4, ", Runtime()-R, "\n" );
    #R := Runtime();

    # consistency relations: gi * ( gi^ei-1 * gi ) = ( gi * gi^ei-1 ) * gi
    for i  in [ 1 .. Length( gens ) ]  do
        gi := gens[i];
        r1 := ReducedProduct( col, gi, ReducedProduct( col,
                  ReducedPower( col, gi, rods[i]-1 ), gi ) );
        r2 := ReducedProduct( col, ReducedProduct( col, gi,
                  ReducedPower( col, gi, rods[i]-1 ) ), gi );
        if r1 <> r2  then
            if failed = false  then
                return false;
            else
                Add( failed, [ 4, gi, gi, rods[i]-1, gi ] );
            fi;
        fi;
    od;
    #Print( "#I  'IsConfluent' done, ", Runtime()-R, "\n" );

    # we passed all consistency checks
    if failed = false  then
        return true;
    else
        return IsEmpty(failed);
   fi;

end );


#############################################################################
##
#M  IsConfluent( <col> )
##


#############################################################################
InstallMethod( IsConfluent,
    "method for finite polycyclic rewriting systems",
    true,
    [ IsPolycyclicCollector and IsFinite ],
    0,

function( col )
    return FinitePolycyclicCollector_IsConfluent( col, false );
end );


#############################################################################
InstallMethod( IsConfluent,
        "generic method for polycyclic rewriting systems",
        true,
        [ IsPolycyclicCollector ],
        0,
        function( pcp )
    local   n,  k,  j,  i,  ev1,  ev2, g, orders;

    n := NumberGeneratorsOfRws(pcp);
    g := GeneratorsOfRws(pcp);
    orders := RelativeOrders(pcp);

    # k (j i) = (k j) i
    for k in [n,n-1..1] do
        for j in [k-1,k-2..1] do
            for i in [j-1,j-2..1] do
                Info( InfoConfluence, 2, "check ", k, " ", j, " ", i, "\n" );
                ev1 := ReducedProduct( pcp, g[k],
                                       ReducedProduct( pcp, g[j], g[i] ) );
                ev2 := ReducedProduct( pcp, ReducedProduct( pcp, g[k], g[j] ),
                                       g[i]   );
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", k, " ", j, " ", i, "\n" );
                    return false;
                fi;
            od;
        od;
    od;

    # j^m i = j^(m-1) (j i)
    for j in [n,n-1..1] do
        for i in [j-1,j-2..1] do
            if  orders[j] <> 0  then
                Info( InfoConfluence, 2, "check ", j, "^m ", i, "\n" );
                ev1 := ReducedProduct( pcp, ReducedPower(pcp, g[j], orders[j]),
                                       g[i]   );
                ev2 := ReducedProduct( pcp,
                                       ReducedPower( pcp, g[j], orders[j]-1 ),
                                       ReducedProduct( pcp, g[j], g[i] )  );
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, "^m ", i, "\n" );
                    return false;
                fi;
            fi;
        od;
    od;

    # j * i^m = (j i) * i^(m-1)
    for j in [n,n-1..1] do
        for i in [j-1,j-2..1] do
            if  orders[i] <> 0  then
                Info( InfoConfluence, 2, "check ", j, " ", i, "^m\n" );
                ev1 := ReducedProduct( pcp, g[j],
                                       ReducedPower(pcp, g[i], orders[i])  );
                ev2 := ReducedProduct( pcp,
                                       ReducedProduct( pcp, g[j], g[i] ),
                                       ReducedPower(pcp, g[i], orders[i]-1)  );
                if ev1 <> ev2 then
                    Print( "Inconsistency at ", j, " ", i, "^m\n" );
                    return false;
                fi;
            fi;
        od;
    od;

    # i^m i = i i^m
    for i in [n,n-1..1] do
        if  orders[i] <> 0 then
            ev1 := ReducedProduct( pcp, g[i],
                                   ReducedPower( pcp, g[i], orders[i] )  );
            ev2 := ReducedProduct( pcp,
                                   ReducedPower( pcp, g[i], orders[i] ),
                                   g[i]     );
            if ev1 <> ev2 then
                Print( "Inconsistency at ", i, "^(m+1)\n" );
                return false;
            fi;
        fi;
    od;

    # j = (j -i) i
    for i in [n,n-1..1] do
        if  orders[i] = 0  then
            for j in [i+1..n] do
                Info(InfoConfluence, 2, "check ", j, " ", -i, " ", i, "\n");
                ev1 := ReducedProduct( pcp,
                                       ReducedProduct( pcp, g[j],
                                                       ReducedInverse( pcp,
                                                                     g[i] )),
                                       g[i] );
                if ev1 <> g[j] then
                    Print( "Inconsistency at ", j, " ", -i, " ", i, "\n" );
                    return false;
                fi;
            od;
        fi;
    od;

    # i = -j (j i)
    for j in [n,n-1..1] do
        if  orders[j] = 0  then
            for i in [j-1,j-2..1] do
                Info(InfoConfluence, 2, "check ", -j, " ", j, " ", i, "\n");
                ev1 := ReducedProduct( pcp, ReducedInverse( pcp, g[j] ),
                                       ReducedProduct( pcp, g[j], g[i] )  );
                if  ev1 <> g[i]  then
                    Print( "Inconsistency at ", -j, " ", j, " ", i, "\n" );
                    return false;
                fi;

                if  orders[i] = 0  then
                    Info(InfoConfluence,2,"check ",-j," ",j," ",-i,"\n");
                    ev1 := ReducedProduct( pcp, ReducedInverse( pcp, g[j] ),
                                  ReducedProduct( pcp, g[j],
                                         ReducedInverse( pcp, g[i] ) ) );
                    if  ev1 <> ReducedInverse( pcp, g[i] )  then
                        Print( "Inconsistency at ", -j, " ", j, " ", -i, "\n" );
                        return false;
                    fi;
                fi;
            od;
        fi;
    od;
    return true;
end );


#############################################################################
InstallOtherMethod( IsConfluent,
    true,
    [ IsPolycyclicCollector and IsFinite,
      IsList ],
    0,
    FinitePolycyclicCollector_IsConfluent );


#############################################################################
##
#M  OutdatePolycyclicCollector( <col> )
##


#############################################################################
InstallMethod( OutdatePolycyclicCollector,
    true,
    [ IsPolycyclicCollector and IsMutable ],
    0,

function( col )
    ResetFilterObj( col, IsUpToDatePolycyclicCollector );
end );


#############################################################################
##
#M  ViewObj( <col> )
##


#############################################################################
InstallMethod( ViewObj, true, [ IsPolycyclicCollector ], 0,

function( col )
    Print( "<<polycyclic collector>>");
end );


#############################################################################
InstallMethod( ViewObj, true, [ IsPowerConjugateCollector ], 0,

function( col )
    Print( "<<polycyclic collector with conjugates>>");
end );


#############################################################################
InstallMethod( ViewObj, true, [ IsPowerCommutatorCollector ], 0,

function( col )
    Print( "<<polycyclic collector with commutators>>");
end );


#############################################################################
##
#M  PrintObj( <col> )
##


#############################################################################
InstallMethod( PrintObj, true, [ IsPolycyclicCollector ], 0,

function( col )
    Print( "<<polycyclic collector>>");
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj, true, [ IsPowerConjugateCollector ], 0,

function( col )
    Print( "<<polycyclic collector with conjugates>>");
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj, true, [ IsPowerCommutatorCollector ], 0,

function( col )
    Print( "<<polycyclic collector with commutators>>");
end );
#T install a better `PrintObj' method!


#############################################################################
##
#M  CollectWord( <col>, <v>, <w> )
##
InstallMethod( CollectWord,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPolycyclicCollector,
      IsList,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, v, w )
    local   vv,  i;

    vv := ShallowCopy(v);
    while CollectWordOrFail( col, v, w ) = fail  do
        for i  in [ 1 .. Length(v) ]  do
            v[i] := vv[i];
        od;
    od;
    return true;
end );


#############################################################################
##
#M  CollectWordOrFail( <col>, <v>, <w> )
##
##  NOTE: you  must  install  a method   for  your collector *and*   the flag
##  'IsUpToDatePolycyclicCollector'.
##


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPolycyclicCollector,
      IsList,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, v, w )
    if not IsUpToDatePolycyclicCollector(col)  then
        UpdatePolycyclicCollector(col);
        if not IsUpToDatePolycyclicCollector(col)  then
            Error( "'UpdatePolycyclicCollector' must set the feature ",
                   "'IsUpToDatePolycyclicCollector'" );
        fi;
    fi;
    return CollectWordOrFail( col, v, w );
end );


#############################################################################
InstallMethod( CollectWordOrFail,
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPolycyclicCollector and IsUpToDatePolycyclicCollector,
      IsList,
      IsMultiplicativeElementWithInverse ], 0,

function( col, v, w )
    Error( "no generic method for 'CollectWordOrFail' is known" );
end );


#############################################################################
##
#M  ReducedForm( <col>, <word> )
##
InstallMethod( ReducedForm,
    "CollectWordOrFail",
    IsIdenticalObjFamiliesRwsObj,
    [ IsPolycyclicCollector,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, word )
    local   l;

    # collect <word> into the empty list
    l := ListWithIdenticalEntries( NumberGeneratorsOfRws(col), 0);
    if CollectWordOrFail( col, l, word ) = fail  then
        return ReducedForm( col, word );
    fi;

    # and construct the corresponding word
    return ObjByExponents( col, l );

end );


#############################################################################
##
#M  ReducedPower( <col>, <obj>, <pow> )
##
InstallMethod( ReducedPower,
    "ReducedInverse/CollectWordOrFail",
    IsIdenticalObjFamiliesRwsObjXXX,
    [ IsPolycyclicCollector,
      IsMultiplicativeElementWithInverse,
      IsInt ],
    0,

function( col, obj, pow )
    local   res,  tmp;

    # if <pow> is negative invert <obj> first
    if pow < 0  then
        obj := ReducedInverse( col, obj );
        pow := -pow;
    fi;

    # if <pow> is zero, reduce the identity
    if pow = 0  then
        return ReducedOne(col);

    # catch some trivial cases
    elif pow <= 5  then
        if pow = 1  then
            return obj;
        elif pow = 2  then
            res := ListWithIdenticalEntries( NumberGeneratorsOfRws(col), 0 );
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            return ObjByExponents( col, res );
        elif pow = 3  then
            res := ListWithIdenticalEntries( NumberGeneratorsOfRws(col), 0 );
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            return ObjByExponents( col, res );
        elif pow = 4  then
            res := ListWithIdenticalEntries( NumberGeneratorsOfRws(col), 0 );
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            tmp := ObjByExponents( col, res );
            if CollectWordOrFail( col, res, tmp ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            return ObjByExponents( col, res );
        elif pow = 5  then
            res := ListWithIdenticalEntries( NumberGeneratorsOfRws(col), 0 );
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            tmp := ObjByExponents( col, res );
            if CollectWordOrFail( col, res, tmp ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            return ObjByExponents( col, res );
        fi;
    fi;

    # divide et impera (this is slightly faster then repeated squaring r2l)
    if RemInt( pow, 2 ) = 1  then
        res := ReducedPower( col, obj, QuoInt(pow-1,2) );
        res := ReducedProduct( col, res, res );
        return ReducedProduct( col, obj, res );
    else
        res := ReducedPower( col, obj, QuoInt(pow,2) );
        return ReducedProduct( col, res, res );
    fi;

end );


#############################################################################
##
#M  SetCommutator( <col>, <i>, <j>, <rhs> )
##


#############################################################################
InstallMethod( SetCommutator,"elements",
    IsIdenticalObjFamiliesColObjObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, gj, rhs )
    local   g;
    g := GeneratorsOfRws( col );
    SetCommutator( col, Position( g, gi ), Position( g, gj ), rhs );
end );


#############################################################################
InstallMethod( SetCommutatorNC,"elements",
    IsIdenticalObjFamiliesColObjObjObj,
    [ IsPowerConjugateCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, gj, rhs )
    local   g;
    g := GeneratorsOfRws( col );
    SetCommutatorNC( col, Position( g, gi ), Position( g, gj ), rhs );
end );


#############################################################################
InstallMethod( SetCommutatorNC,"integers",
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, i, j, rhs )
    SetConjugateNC( col, i, j, GeneratorsOfRws(col)[i]*rhs );
end );


#############################################################################
InstallMethod( SetCommutator,"integers",
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsMutable,
      IsInt,
      IsInt,
      IsObject ],
    0,

function( col, i, j, rhs )
    SetConjugate( col, i, j, GeneratorsOfRws(col)[i]*rhs );
end );


#############################################################################
##
#M  SetConjugate( <col>, <i>, <j>, <rhs> )
##


#############################################################################
InstallMethod( SetConjugate,
    IsIdenticalObjFamiliesColObjObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, gj, rhs )
    local   g;
    g := GeneratorsOfRws( col );
    SetConjugate( col, Position( g, gi ), Position( g, gj ), rhs );
end );


#############################################################################
InstallMethod( SetConjugateNC,
    IsIdenticalObjFamiliesColObjObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, gj, rhs )
    local   g;
    g := GeneratorsOfRws( col );
    SetConjugateNC( col, Position( g, gi ), Position( g, gj ), rhs );
end );


#############################################################################
InstallMethod( SetConjugate,
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerCommutatorCollector and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, i, j, rhs )
    SetCommutator( col, i, j, GeneratorsOfRws(col)[i]^-1*rhs );
end );


#############################################################################
InstallMethod( SetConjugateNC,
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerCommutatorCollector and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, i, j, rhs )
    SetCommutatorNC( col, i, j, GeneratorsOfRws(col)[i]^-1*rhs );
end );


#############################################################################
##
#M  SetPower( <col>, <i>, <rhs> )
##


#############################################################################
InstallMethod( SetPower,
    IsIdenticalObjFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, rhs )
    SetPower( col, Position(GeneratorsOfRws(col),gi), rhs );
end );


#############################################################################
InstallMethod( SetPowerNC,
    IsIdenticalObjFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, rhs )
    SetPowerNC( col, Position(GeneratorsOfRws(col),gi), rhs );
end );


#############################################################################
##
#M  SetRelativeOrder( <col>, <i>, <ord> )
##


#############################################################################
InstallMethod( SetRelativeOrder,
    IsIdenticalObjFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsInt ],
    0,

function( col, gi, ord )
    SetRelativeOrder( col, Position(GeneratorsOfRws(col),gi), ord );
end );


#############################################################################
InstallMethod( SetRelativeOrderNC,
    IsIdenticalObjFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsInt ],
    0,

function( col, gi, ord )
    SetRelativeOrderNC( col, Position(GeneratorsOfRws(col),gi), ord );
end );


#############################################################################
##
#M  EvaluateOverlapCBA  . . . . . . . . . . . . . evaluate a consistency test
##
InstallMethod( EvaluateOverlapCBA,
        "polyc. collector, 2 hom. lists, 3 pos. integers",
        true,
        [ IsPolycyclicCollector,
          IsHomogeneousList, IsHomogeneousList,
          IsPosInt, IsPosInt, IsPosInt ], 0,
function( coll, l, r, z, y, x )
    local   status;

    ##  if this routine is used for computing tails, then the tail t is
    ##                            t = l-r

    ##  (z y) x = y z^y x
    repeat
        l[y] := 1;
        status := CollectWordOrFail( coll, l, GetConjugateNC( coll, z, y ) );
        if status = true then
            status := CollectWordOrFail( coll, l,
                              coll![SCP_RWS_GENERATORS][x] );
        fi;
    until status = true;

    ##  z (y x) = x z^x y^x
    repeat
        r[x] := 1;
        status := CollectWordOrFail( coll, r, GetConjugateNC( coll, z, x ) );
        if status = true then
            status := CollectWordOrFail( coll, r,
                              GetConjugateNC( coll, y, x ) );
        fi;
    until status = true;
end );

#############################################################################
##
#M  EvaluateOverlapBNA  . . . . . . . . . . . . . evaluate a consistency test
##
InstallMethod( EvaluateOverlapBNA,
        "polyc. collector, 2 hom. lists, 3 pos. integers",
        true,
        [ IsPolycyclicCollector,
          IsHomogeneousList, IsHomogeneousList,
          IsPosInt, IsPosInt, IsPosInt ], 0,
function( coll, l, r, b, n, a )
    local   status;

    ##  if this routine is used for computing tails, then the tail t is
    ##                            t = l-r

    ##  b^n a
    repeat
        status := CollectWordOrFail( coll, l, GetPowerNC( coll, b ) );
        if status = true then
            status := CollectWordOrFail( coll, l,
                              coll![SCP_RWS_GENERATORS][a] );
        fi;
    until status = true;

    ##  b^(n-1) (b a) = b^(n-1) a b^a
    repeat
        r[b] := n-1;
        status := CollectWordOrFail( coll, r,
                          coll![SCP_RWS_GENERATORS][a] );
        if status = true then
            status := CollectWordOrFail( coll, r,
                              GetConjugateNC( coll, b, a ) );
        fi;
    until status = true;
end );


#############################################################################
##
#M  EvaluateOverlapBAN  . . . . . . . . . . . . . evaluate a consistency test
##
InstallMethod( EvaluateOverlapBAN,
        "polyc. collector, 2 hom. lists, 3 pos. integers",
        true,
        [ IsPolycyclicCollector,
          IsHomogeneousList, IsHomogeneousList,
          IsPosInt, IsPosInt, IsPosInt ], 0,
function( coll, l, r, z, y, n )
    local   status;

    ##  if this routine is used for computing tails, then the tail t is
    ##                            t = l-r

    ##  (z y) y^(n-1) = y z^y y^(n-1)
    repeat
        l[y] := 1;
        status := CollectWordOrFail( coll, l, GetConjugateNC( coll, z, y ) );
        if status = true then
            status := CollectWordOrFail( coll, l,
                              coll![SCP_RWS_GENERATORS][y]^(n-1) );
        fi;
    until status = true;

    ##  z * y^n
    repeat
        r[z] := 1;
    until CollectWordOrFail( coll, r, GetPowerNC( coll, y ) ) = true;
end );

#############################################################################
##
#M  EvaluateOverlapANA  . . . . . . . . . . . . . evaluate a consistency test
##
InstallMethod( EvaluateOverlapANA,
        "polyc. collector, 2 hom. lists, 3 pos. integers",
        true,
        [ IsPolycyclicCollector,
          IsHomogeneousList, IsHomogeneousList,
          IsPosInt, IsPosInt ], 0,
function( coll, l, r, a, n )
    local   status;

    ##  (a^n) a
    repeat
        status := CollectWordOrFail( coll, l, GetPowerNC( coll, a ) );
        if status = true then
            status := CollectWordOrFail( coll, l,
                              coll![SCP_RWS_GENERATORS][a] );
        fi;
    until status = true;

    ##  a (a^n)
    repeat
        r[a] := 1;
        status := CollectWordOrFail( coll, r, GetPowerNC( coll, a ) );
    until status = true;
end );
