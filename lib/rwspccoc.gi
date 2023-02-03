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
##  This file implements a combinatorial collector as an extension of the
##  representation of a single collector as defined in rwspcsng.gi.
##


#############################################################################
##
#R  IsCombinatorialCollectorRep( <obj> )  . . . . . . . . . . . . declaration
##
DeclareRepresentation( "IsCombinatorialCollectorRep",
    IsSingleCollectorRep );


#############################################################################
##
#M  SetConjugate( <cc>, <j>, <i>, <rhs> ) . . . . combinatorial collector rep
##
##  required: <j> > <i>
##
InstallMethod( SetConjugate,
    "combinatorial collector rep",
    IsIdenticalObjFamiliesColXXXXXXObj,
    [ IsPowerConjugateCollector and IsFinite and IsCombinatorialCollectorRep
        and IsMutable,
      IsInt,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( cc, j, i, rhs )
    local   m,  n,  l;

    # check <j>
    if not 2 <= j then
        Error( "<j> must be at least 2" );
    fi;
    if not j <= cc![SCP_NUMBER_RWS_GENERATORS] then
        Error( "<j> must be at most ", cc![SCP_NUMBER_RWS_GENERATORS] );
    fi;

    if not 1 <= i  then
        Error( "<i> must be at least 1" );
    fi;
    if not i < j  then
        Error( "<i> must be at most ", j-1 );
    fi;

    # check that the rhs is non-trivial
    if 0 = NumberSyllables(rhs)  then
        Error( "right hand side is trivial" );
    fi;

    # check that the rhs lies underneath <j> and is collected.
    if GeneratorSyllable( rhs, 1 ) <> j then
        Error( "conjugate ", rhs, " must start with generator ", j );
    fi;
    m := j;
    for l  in [ 2 .. NumberSyllables(rhs) ]  do
        n := GeneratorSyllable( rhs, l );
        if not n > m  then
            Error( "conjugate ", rhs, " must be collected" );
        fi;
        m := n;
    od;

    # install the conjugate relator
    SingleCollector_SetConjugateNC( cc, j, i, rhs );

end );


#############################################################################
##
#M  SetPower( <cc>, <i>, <rhs> )  . . . . . . . . combinatorial collector rep
##
InstallMethod( SetPower,
    "combinatorial collector rep",
    IsIdenticalObjFamiliesColXXXObj,
    [ IsPowerConjugateCollector and IsFinite and
      IsCombinatorialCollectorRep and IsMutable,
      IsInt,
      IsMultiplicativeElementWithInverse ],
    0,

function( cc, i, rhs )
    local   fam,  m,  n,  l;

    # check the family (this cannot be done in install)
    fam := cc![SCP_UNDERLYING_FAMILY];
    if not IsIdenticalObj( FamilyObj(rhs), fam )  then
        Error( "<rhs> must lie in the group of <cc>" );
    fi;

    # check <i>
    if i <= 0  then
        Error( "<i> must be positive" );
    fi;
    if cc![SCP_NUMBER_RWS_GENERATORS] < i  then
        Error( "<i> must be at most ", cc![SCP_NUMBER_RWS_GENERATORS] );
    fi;

    # check that the rhs lies underneath <j> and is collected.
    m := i;
    for l  in [ 1 .. NumberSyllables(rhs) ]  do
        n := GeneratorSyllable( rhs, l );
        if not n > m  then
            Error( "conjugate ", rhs, " must be collected" );
        fi;
        m := n;
    od;

    # enter the rhs
    SingleCollector_SetPowerNC( cc, i, rhs );

end );


#############################################################################
##
#M  UpdatePolycyclicCollector( <cc> ) . . . . . . combinatorial collector rep
##
BindGlobal( "CombiCollector_MakeAvector2", function( cc )
    local   n,  cl,  wt,  avc2,  h,  g;

    # number of generators
    n := cc![SCP_NUMBER_RWS_GENERATORS];

    # class and weights of collector
    cl := cc![SCP_CLASS];
    wt := cc![SCP_WEIGHTS];

    avc2 := [1..n];
    for g in [1..n] do
        if 3*wt[g] > cl then
            break;
        fi;
        h := cc![SCP_AVECTOR][g];
        while g < h and 2*wt[h] + wt[g] > cl do h := h-1; od;
        avc2[g] := h;
    od;

    # set the avector
    cc![SCP_AVECTOR2] := avc2;
end );

InstallMethod( UpdatePolycyclicCollector,
    "combinatorial collector rep",
    true,
    [ IsPowerConjugateCollector and IsFinite and IsCombinatorialCollectorRep ],
    0,

function( cc )

    # update the avectors
    SingleCollector_MakeAvector(cc);
    CombiCollector_MakeAvector2(cc);

    # 'MakeInverses' is very careful
    SetFilterObj( cc, IsUpToDatePolycyclicCollector );

    # construct the inverses
    SingleCollector_MakeInverses(cc);

end );


#############################################################################
##
#M  CombinatorialCollector( <fgrp>, <orders> )  . . . . . . . . .  create one
##


#############################################################################
InstallMethod( CombinatorialCollector,
    true,
    [ IsFreeGroup and IsGroupOfFamily,
      IsList ],
    0,

function( fgrp, orders )
    local   gens;

    # check the orders
    gens := GeneratorsOfGroup(fgrp);
    if Length(orders) <> Length(gens)  then
        Error( "need ", Length(gens), " orders, not ", Length(orders) );
    fi;
    if ForAny( orders, x -> not IsInt(x) or x <= 0 )  then
        Error( "relative orders must be positive integers" );
    fi;

    # create a new single collector
    return CombinatorialCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, orders );

end );


#############################################################################
InstallMethod( CombinatorialCollector,
    true,
    [ IsFreeGroup and IsGroupOfFamily,
      IsInt ],
    0,

function( fgrp, order )
    local   gens;

    # check the order
    if order <= 0  then
        Error( "relative order must be a positive integers" );
    fi;
    order := List( GeneratorsOfGroup(fgrp), x -> order );
    gens  := GeneratorsOfGroup(fgrp);

    # create a new object
    return CombinatorialCollectorByGenerators(
        ElementsFamily(FamilyObj(fgrp)), gens, order );

end );


#############################################################################
InstallMethod( CombinatorialCollector,
    true,
    [ IsList,
      IsList ],
    0,

function( gens, orders )

    # check the orders
    if Length(orders) <> Length(gens)  then
        Error( "need ", Length(gens), " orders, not ", Length(orders) );
    fi;
    if ForAny( orders, x -> not IsInt(x) or x <= 0 )  then
        Error( "relative orders must be positive integers" );
    fi;

    # create a new object
    return CombinatorialCollectorByGenerators(
        ElementsFamily(FamilyObj(gens)), gens, orders );

end );


#############################################################################
InstallMethod( CombinatorialCollector,
    true,
    [ IsList,
      IsInt ],
    0,

function( gens, order )

    # check the orders
    if order <= 0  then
        Error( "relative orders must be positive integers" );
    fi;
    order := List( gens, x -> order );

    # create a new object
    return CombinatorialCollectorByGenerators(
        ElementsFamily(FamilyObj(gens)), gens, order );

end );


#############################################################################
##
#M  CombinatorialCollectorByGenerators( <fam>, <gens>, <orders> .  create one
##
InstallMethod( CombinatorialCollectorByGenerators,
    true,
    [ IsFamily,
      IsList,
      IsList ],
    0,

function( efam, gens, orders )
    local   co,  cc;

    co := Collected( orders );
    if Length( co ) <> 1 or not IsPrime( co[1][1] ) then
        Error( "only prime orders allowed in combinatorial collector" );
    fi;

    # create a single collector first
    cc := SingleCollectorByGenerators( efam, gens, orders );

    # change the collector number
    if Is8BitsSingleCollectorRep( cc ) then
        cc![SCP_COLLECTOR] := 8Bits_CombiCollector;
    elif Is16BitsSingleCollectorRep( cc ) then
        cc![SCP_COLLECTOR] := 16Bits_CombiCollector;
    elif Is32BitsSingleCollectorRep( cc ) then
        cc![SCP_COLLECTOR] := 32Bits_CombiCollector;
    else
        Error( "combinatorial infinite bits collector not yet implemented" );
    fi;

    # now add support for combinatorial collection
    cc![SCP_WEIGHTS] := [1..cc![SCP_NUMBER_RWS_GENERATORS]] * 0;
    cc![SCP_CLASS]   := 666666;

    SetFilterObj( cc, IsCombinatorialCollectorRep );

    # and return
    return cc;

end );


#############################################################################
##
#M  ShallowCopy( <cc> ) . . . . . . . . . . . .  of a combinatorial collector
##
InstallMethod( ShallowCopy,
    "combinatorial collector rep",
    true,
    [ IsPowerConjugateCollector and IsFinite and IsCombinatorialCollectorRep ],
    0,

function( comcol )
    local   copy;

    # First copy the single collector part
    copy := ShallowCopy_SingleCollector( comcol );

    # and the weight information
    copy![SCP_WEIGHTS] := comcol![SCP_WEIGHTS];
    copy![SCP_CLASS]   := comcol![SCP_CLASS];
    if IsBound(comcol![SCP_AVECTOR2])  then
        copy![SCP_AVECTOR2] := ShallowCopy(comcol![SCP_AVECTOR2]);
    fi;

    # it's a combinatorial collector now
    SetFilterObj( copy, IsCombinatorialCollectorRep );

    return copy;

end );

#############################################################################
##
#M  ViewObj( <cc> ) . . . . . . . . . . . . . .  of a combinatorial collector
##


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      IsCombinatorialCollectorRep and IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (8 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is8BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 8 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (8 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is8BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 8 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (16 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is16BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 16 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (16 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is16BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 16 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (32 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is32BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 32 Bits>>" );
end );


#############################################################################
InstallMethod( ViewObj,
    "combinatorial collector rep (32 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is32BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 32 Bits>>" );
end );


#############################################################################
##
#M  PrintObj( <cc> )  . . . . . . . . . . . . . for a combinatorial collector
##


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector (up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      IsCombinatorialCollectorRep and IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (8 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is8BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 8 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (8 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is8BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 8 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (16 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is16BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 16 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (16 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is16BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 16 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (32 Bits)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is32BitsSingleCollectorRep and IsCombinatorialCollectorRep ],
    0,

function( cc )
    Print( "<<combinatorial collector, 32 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
InstallMethod( PrintObj,
    "combinatorial collector rep (32 Bits, up to date)",
    true,
    [ IsPowerConjugateCollector and IsFinite and
      Is32BitsSingleCollectorRep and IsCombinatorialCollectorRep and
      IsUpToDatePolycyclicCollector ],
    0,

function( cc )
    Print( "<<up-to-date combinatorial collector, 32 Bits>>" );
end );
#T install a better `PrintObj' method!


#############################################################################
##

