#############################################################################
##
#W  rwspcclt.gi                 GAP Library                      Frank Celler
##
##  This file contains generic methods polycyclic rewriting systems.
##
Revision.rwspcclt_gi :=
    "@(#)$Id$";


#############################################################################
##

#F  IsIdenticalFamiliesColObjObj( <rws>, <obj>, <obj> )
##
IsIdenticalFamiliesColObjObj := function( a, b, c )
    return IsIdentical( a!.underlyingFamily, b )
       and IsIdentical( b, c );
end;


#############################################################################
##
#F  IsIdenticalFamiliesColObjObjObj( <rws>, <obj>, <obj>, <obj> )
##
IsIdenticalFamiliesColObjObjObj := function( a, b, c, d )
    return IsIdentical( a!.underlyingFamily, b )
       and IsIdentical( b, c )
       and IsIdentical( b, d );
end;


#############################################################################
##
#F  IsIdenticalFamiliesColXXXObj( <col>, <obj>, <obj> )
##
IsIdenticalFamiliesColXXXObj := function( a, b, c )
    return IsIdentical( a!.underlyingFamily, c );
end;


#############################################################################
##
#F  IsIdenticalFamiliesColXXXXXXObj( <rws>, <obj>, <obj>, <obj> )
##
IsIdenticalFamiliesColXXXXXXObj := function( a, b, c, d )
    return IsIdentical( a!.underlyingFamily, d );
end;


#############################################################################
##

#F  FinitePolycyclicCollector_IsConfluent( <col> )
##
FinitePolycyclicCollector_IsConfluent := function( col, failed )
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

end;


#############################################################################
##

#M  IsConfluent( <col> )
##


#############################################################################
InstallMethod( IsConfluent, 
    "method for finite polycylic rewriting systems",
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
    SetFeatureObj( col, IsUpToDatePolycyclicCollector, false );
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


#############################################################################
InstallMethod( PrintObj, true, [ IsPowerConjugateCollector ], 0,

function( col )
    Print( "<<polycyclic collector with conjugates>>");
end );


#############################################################################
InstallMethod( PrintObj, true, [ IsPowerCommutatorCollector ], 0,

function( col )
    Print( "<<polycyclic collector with commutators>>");
end );


#############################################################################
##

#M  CollectWord( <col>, <v>, <w> )
##
InstallMethod( CollectWord,
    IsIdenticalFamiliesColXXXObj,
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
    IsIdenticalFamiliesColXXXObj,
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
    IsIdenticalFamiliesColXXXObj, 
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
    IsIdenticalFamiliesRwsObj,
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
    IsIdenticalFamiliesRwsObjXXX,
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
            res := [ 1 .. NumberGeneratorsOfRws(col) ] * 0;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            if CollectWordOrFail( col, res, obj ) = fail  then
                return ReducedPower( col, obj, pow );
            fi;
            return ObjByExponents( col, res );
        elif pow = 3  then
            res := [ 1 .. NumberGeneratorsOfRws(col) ] * 0;
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
            res := [ 1 .. NumberGeneratorsOfRws(col) ] * 0;
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
            res := [ 1 .. NumberGeneratorsOfRws(col) ] * 0;
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
InstallMethod( SetCommutator,
    IsIdenticalFamiliesColObjObjObj,
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
InstallMethod( SetCommutatorNC, 
    IsIdenticalFamiliesColObjObjObj,
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
InstallMethod( SetCommutatorNC,
    IsIdenticalFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, i, j, rhs )
    SetConjugateNC( col, i, j, GeneratorsOfRws(col)[i]*rhs );
end );


#############################################################################
InstallMethod( SetCommutator,
    IsIdenticalFamiliesColXXXXXXObj,
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
    IsIdenticalFamiliesColObjObjObj,
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
    IsIdenticalFamiliesColObjObjObj,
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
    IsIdenticalFamiliesColXXXXXXObj,
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
    IsIdenticalFamiliesColXXXXXXObj,
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
    IsIdenticalFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsMultiplicativeElementWithInverse ],
    0,

function( col, gi, rhs )
    SetPower( col, Position(GeneratorsOfRws(col),gi), rhs );
end );


#############################################################################
InstallMethod( SetPowerNC,
    IsIdenticalFamiliesColObjObj,
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
    IsIdenticalFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsInt ],
    0,

function( col, gi, ord )
    SetRelativeOrder( col, Position(GeneratorsOfRws(col),gi), ord );
end );


#############################################################################
InstallMethod( SetRelativeOrderNC,
    IsIdenticalFamiliesColObjObj,
    [ IsPolycyclicCollector and IsMutable,
      IsMultiplicativeElementWithInverse,
      IsInt ],
    0,

function( col, gi, ord )
    SetRelativeOrderNC( col, Position(GeneratorsOfRws(col),gi), ord );
end );


#############################################################################
##

#E  rwspcclt.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
